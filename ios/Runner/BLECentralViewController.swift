//
//  ViewController.swift
//  BLEProofCentral
//
//  Created by Alexander Lavrushko on 22/03/2021.
//

import UIKit
import CoreBluetooth

class BLECentralViewController: UIViewController {

    // BLE related properties
    let uuidService = CBUUID(string: "25AE1441-05D3-4C5B-8281-93D4E07420CF")
    let uuidCharForRead = CBUUID(string: "25AE1442-05D3-4C5B-8281-93D4E07420CF")
    let uuidCharForWrite = CBUUID(string: "25AE1443-05D3-4C5B-8281-93D4E07420CF")
    let uuidCharForIndicate = CBUUID(string: "25AE1444-05D3-4C5B-8281-93D4E07420CF")

    var bleCentral: CBCentralManager!
    var connectedPeripheral: CBPeripheral?

    enum BLELifecycleState: String {
        case bluetoothNotReady
        case disconnected
        case scanning
        case connecting
        case connectedDiscovering
        case connected
    }

    var lifecycleState = BLELifecycleState.bluetoothNotReady {
        didSet {
            guard lifecycleState != oldValue else { return }
            appendLog("state = \(lifecycleState)")
            if oldValue == .connected {
                labelSubscription = "Not subscribed"
            }
        }
    }

    //  UI related properties
    var textViewStatus = "String"
    var textViewLog = "String"
    var switchConnect = "String"
    var textFieldDataForRead = "String"
    var textFieldDataForWrite = "String"
    var textFieldDataForIndicate = "String"
    var labelSubscription = "String"

    let timeFormatter = DateFormatter()
    
    //flutter channel 2
    let channel: FlutterMethodChannel
    
    public init(channel:FlutterMethodChannel) {
           self.channel = channel
           super.init(nibName: nil, bundle: nil)
       }
    required init?(coder decoder: NSCoder) {
        fatalError()
    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        initBLE()
    }

    @IBAction func onChangeSwitchConnect(_ sender: UISwitch) {
        bleRestartLifecycle()
    }

    @IBAction func onTapReadCharacteristic(_ sender: Any) {
        bleReadCharacteristic(uuid: uuidCharForRead)
    }

    public func onTapWriteCharacteristic(_ sender: Any, text: String) {
        appendLog("writing '\(text)'")
        let data = text.data(using: .utf8) ?? Data()
        bleWriteCharacteristic(uuid: uuidCharForWrite, data: data)
    }

    @IBAction func onTapOpenSettings(_ sender: Any) {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }

    @IBAction func onTapClearLog(_ sender: Any) {
        textViewLog = "Logs:"
        appendLog("log cleared")
    }
}

// MARK: - UI related methods
extension BLECentralViewController {
    func appendLog(_ message: String) {
        let logLine = "\(timeFormatter.string(from: Date())) \(message)"
        print("DEBUG: \(logLine)")
        
        self.channel.invokeMethod("logs",arguments: logLine)

        updateUIStatus()
    }

    func updateUIStatus() {
        textViewStatus = bleGetStatusString()
        self.channel.invokeMethod("getStatus",arguments: textViewStatus)
        print("invoked")    }

    var userWantsToScanAndConnect: Bool {
        false
    }
}

extension BLECentralViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - BLE related methods
extension BLECentralViewController {
    private func initBLE() {
        // using DispatchQueue.main means we can update UI directly from delegate methods
        bleCentral = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    func bleRestartLifecycle() {
        guard bleCentral.state == .poweredOn else {
            connectedPeripheral = nil
            lifecycleState = .bluetoothNotReady
            return
        }

        if userWantsToScanAndConnect {
            if let oldPeripheral = connectedPeripheral {
                bleCentral.cancelPeripheralConnection(oldPeripheral)
            }
            connectedPeripheral = nil
            bleScan()
        } else {
            bleDisconnect()
        }
    }

    func bleScan() {
        lifecycleState = .scanning
        bleCentral.scanForPeripherals(withServices: [uuidService], options: nil)
    }

    func bleConnect(to peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        lifecycleState = .connecting
        bleCentral.connect(peripheral, options: nil)
    }

    func bleDisconnect() {
        if bleCentral.isScanning {
            bleCentral.stopScan()
        }
        if let peripheral = connectedPeripheral {
            bleCentral.cancelPeripheralConnection(peripheral)
        }
        lifecycleState = .disconnected
    }

    func bleReadCharacteristic(uuid: CBUUID) {
        guard let characteristic = getCharacteristic(uuid: uuid) else {
            appendLog("ERROR: read failed, characteristic unavailable, uuid = \(uuid.uuidString)")
            return
        }
        connectedPeripheral?.readValue(for: characteristic)
    }

    func bleWriteCharacteristic(uuid: CBUUID, data: Data) {
        guard let characteristic = getCharacteristic(uuid: uuid) else {
            appendLog("ERROR: write failed, characteristic unavailable, uuid = \(uuid.uuidString)")
            return
        }
        connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    func getCharacteristic(uuid: CBUUID) -> CBCharacteristic? {
        guard let service = connectedPeripheral?.services?.first(where: { $0.uuid == uuidService }) else {
            return nil
        }
        return service.characteristics?.first { $0.uuid == uuid }
    }

    public func bleGetStatusString() -> String {
        guard let bleCentral = bleCentral else { return "not initialized" }
        switch bleCentral.state {
        case .unauthorized:
            return bleCentral.state.stringValue + " (allow in Settings)"
        case .poweredOff:
            return "Bluetooth OFF"
        case .poweredOn:
            return "ON, \(lifecycleState)"
        default:
            return bleCentral.state.stringValue
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLECentralViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        appendLog("central didUpdateState: \(central.state.stringValue)")
        bleRestartLifecycle()
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        appendLog("didDiscover {name = \(peripheral.name ?? String("nil"))}")

        guard connectedPeripheral == nil else {
            appendLog("didDiscover ignored (connectedPeripheral already set)")
            return
        }

        bleCentral.stopScan()
        bleConnect(to: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        appendLog("didConnect")

        lifecycleState = .connectedDiscovering
        peripheral.delegate = self
        peripheral.discoverServices([uuidService])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if peripheral === connectedPeripheral {
            appendLog("didFailToConnect")
            connectedPeripheral = nil
            bleRestartLifecycle()
        } else {
            appendLog("didFailToConnect, unknown peripheral, ingoring")
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral === connectedPeripheral {
            appendLog("didDisconnect")
            connectedPeripheral = nil
            bleRestartLifecycle()
        } else {
            appendLog("didDisconnect, unknown peripheral, ingoring")
        }
    }
}

extension BLECentralViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == uuidService }) else {
            appendLog("ERROR: didDiscoverServices, service NOT found\nerror = \(String(describing: error)), disconnecting")
            bleCentral.cancelPeripheralConnection(peripheral)
            return
        }

        appendLog("didDiscoverServices, service found")
        peripheral.discoverCharacteristics([uuidCharForRead, uuidCharForWrite, uuidCharForIndicate], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        appendLog("didModifyServices")
        // usually this method is called when Android application is terminated
        if invalidatedServices.first(where: { $0.uuid == uuidService }) != nil {
            appendLog("disconnecting because peripheral removed the required service")
            bleCentral.cancelPeripheralConnection(peripheral)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        appendLog("didDiscoverCharacteristics \(error == nil ? "OK" : "error: \(String(describing: error))")")

        if let charIndicate = service.characteristics?.first(where: { $0.uuid == uuidCharForIndicate }) {
            peripheral.setNotifyValue(true, for: charIndicate)
        } else {
            appendLog("WARN: characteristic for indication not found")
            lifecycleState = .connected
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            appendLog("didUpdateValue error: \(String(describing: error))")
            return
        }

        let data = characteristic.value ?? Data()
        let stringValue = String(data: data, encoding: .utf8) ?? ""
        if characteristic.uuid == uuidCharForRead {
            textFieldDataForRead = stringValue
        } else if characteristic.uuid == uuidCharForIndicate {
            textFieldDataForIndicate = stringValue
        }
        appendLog("didUpdateValue '\(stringValue)'")
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        appendLog("didWrite \(error == nil ? "OK" : "error: \(String(describing: error))")")
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil else {
            appendLog("didUpdateNotificationState error\n\(String(describing: error))")
            lifecycleState = .connected
            return
        }

        if characteristic.uuid == uuidCharForIndicate {
            let info = characteristic.isNotifying ? "Subscribed" : "Not subscribed"
            labelSubscription = info
            appendLog(info)
        }
        lifecycleState = .connected
    }
}

