//
//  ViewController.swift
//  BLEProofPeripheral
//
//  Created by Alexander Lavrushko on 22/03/2021.
//

import UIKit
import CoreBluetooth

class BLEPeripheralViewController: UIViewController {
    
    // BLE related properties
    let uuidService = CBUUID(string: "25AE1441-05D3-4C5B-8281-93D4E07420CF")
    let uuidCharForRead = CBUUID(string: "25AE1442-05D3-4C5B-8281-93D4E07420CF")
    let uuidCharForWrite = CBUUID(string: "25AE1443-05D3-4C5B-8281-93D4E07420CF")
    let uuidCharForIndicate = CBUUID(string: "25AE1444-05D3-4C5B-8281-93D4E07420CF")
    
    var blePeripheral: CBPeripheralManager!
    var charForIndicate: CBMutableCharacteristic?
    var subscribedCentrals = [CBCentral]()
    
    // UI related properties
    var textViewStatus = "textviewStatus"
    var textViewLog = "UITextView!"
    var textFieldAdvertisingData = "UITextField!"
    var textFieldDataForRead = "UITextField!"
    var textFieldDataForWrite = "UITextField!"
    var textFieldDataForIndicate = "UITextField!"
    var labelSubscribersCount = "UILabel!"
    var switchAdvertising = "UISwitch!"
    
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
    override func viewDidLoad() {
        super.viewDidLoad()

       
        print("app start")

        initBLE()
    }

    @IBAction func onSwitchChangeAdvertising(_ sender: Bool) {
        if sender == true {
            bleStartAdvertising("Nadajemy")
        } else {
            bleStopAdvertising()
        }
    }

    @IBAction func onTapSendIndication(_ sender: Any) {
        bleSendIndication(textFieldDataForIndicate ?? "")
    }

    @IBAction func onTapOpenSettings(_ sender: Any) {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }

    @IBAction func onTapClearLog(_ sender: Any) {
        textViewLog = "Logs:"
        print("log cleared")
    }
}

// MARK: - UI related methods
extension BLEPeripheralViewController {
    func appendLog(_ message: String) {
        let logLine = "\(timeFormatter.string(from: Date())) \(message)"
        self.channel.invokeMethod("logs",arguments: logLine)
        print("DEBUG: \(logLine)")


        updateUIStatus()
    }

     func updateUIStatus() {
        textViewStatus = bleGetStatusString()
         print(textViewStatus)
         self.channel.invokeMethod("getStatus",arguments: textViewStatus)
         print("invoked")
         //     var param
    }

    func updateUIAdvertising() {
        let isAdvertising = blePeripheral?.isAdvertising ?? false
      //  switchAdvertising.isOn = isAdvertising
    }

    func updateUISubscribers() {
       print("\(subscribedCentrals.count)")
    }
}

extension BLEPeripheralViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - BLE related methods
extension BLEPeripheralViewController {

    private func initBLE() {
        // using DispatchQueue.main means we can update UI directly from delegate methods
        blePeripheral = CBPeripheralManager(delegate: self, queue: DispatchQueue.main)

        // BLE service must be created AFTER CBPeripheralManager receives .poweredOn state
        // see peripheralManagerDidUpdateState
    }

    private func buildBLEService() -> CBMutableService {

        // create characteristics
        let charForRead = CBMutableCharacteristic(type: uuidCharForRead,
                                                  properties: .read,
                                                  value: nil,
                                                  permissions: .readable)
        let charForWrite = CBMutableCharacteristic(type: uuidCharForWrite,
                                                   properties: .write,
                                                   value: nil,
                                                   permissions: .writeable)
        let charForIndicate = CBMutableCharacteristic(type: uuidCharForIndicate,
                                                      properties: .indicate,
                                                      value: nil,
                                                      permissions: .readable)
        self.charForIndicate = charForIndicate

        // create service
        let service = CBMutableService(type: uuidService, primary: true)
        service.characteristics = [charForRead, charForWrite, charForIndicate]
        return service
    }

    private func bleStartAdvertising(_ advertisementData: String) {
        let dictionary: [String: Any] = [CBAdvertisementDataServiceUUIDsKey: [uuidService],
                                         CBAdvertisementDataLocalNameKey: advertisementData]
        print("startAdvertising")
        blePeripheral.startAdvertising(dictionary)
    }

    private func bleStopAdvertising() {
        print("stopAdvertising")
        blePeripheral.stopAdvertising()
    }

    public func bleSendIndication(_ valueString: String) {
        guard let charForIndicate = charForIndicate else {
            appendLog("cannot indicate, characteristic is nil")
            return
        }
        let data = valueString.data(using: .utf8) ?? Data()
        let result = blePeripheral.updateValue(data, for: charForIndicate, onSubscribedCentrals: nil)
        let resultStr = result ? "true" : "false"
        appendLog("updateValue result = '\(resultStr)' value = '\(valueString)'")
    }

     func bleGetStatusString() -> String {
        guard let blePeripheral = blePeripheral else { return "not initialized" }
        switch blePeripheral.state {
        case .unauthorized:
            return blePeripheral.state.stringValue + " (allow in Settings)"
        case .poweredOff:
            return "Bluetooth OFF"
        case .poweredOn:
            let advertising = blePeripheral.isAdvertising ? "advertising" : "not advertising"
            return "ON, \(advertising)"
        default:
            return blePeripheral.state.stringValue
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BLEPeripheralViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        appendLog("didUpdateState: \(peripheral.state.stringValue)")

        if peripheral.state == .poweredOn {
            appendLog("adding BLE service")
            blePeripheral.add(buildBLEService())
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("didStartAdvertising: error: \(error.localizedDescription)")
        } else {
            print("didStartAdvertising: success")
        }
        //updateUIAdvertising()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("didAddService: error: \(error.localizedDescription)")
        } else {
            print("didAddService: success: \(service.uuid.uuidString)")
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic) {
        appendLog("didSubscribeTo UUID: \(characteristic.uuid.uuidString)")
        if characteristic.uuid == uuidCharForIndicate {
            subscribedCentrals.append(central)
            updateUISubscribers()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didUnsubscribeFrom characteristic: CBCharacteristic) {
        appendLog("didUnsubscribeFrom UUID: \(characteristic.uuid.uuidString)")
        if characteristic.uuid == uuidCharForIndicate {
            subscribedCentrals.removeAll { $0.identifier == central.identifier }
            updateUISubscribers()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        var log = "didReceiveRead UUID: \(request.characteristic.uuid.uuidString)"
        log += "\noffset: \(request.offset)"

        switch request.characteristic.uuid {
        case uuidCharForRead:
            let textValue = textFieldDataForRead
            log += "\nresponding with success, value = '\(textValue)'"
            request.value = textValue.data(using: .utf8)
            blePeripheral.respond(to: request, withResult: .success)
        default:
            log += "\nresponding with attributeNotFound"
            blePeripheral.respond(to: request, withResult: .attributeNotFound)
        }
        appendLog(log)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        var log = "didReceiveWrite requests.count = \(requests.count)"
        requests.forEach { (request) in
            log += "\nrequest.offset: \(request.offset)"
            log += "\nrequest.char.UUID: \(request.characteristic.uuid.uuidString)"
            switch request.characteristic.uuid {
            case uuidCharForWrite:
                let data = request.value ?? Data()
                let textValue = String(data: data, encoding: .utf8) ?? ""
                textFieldDataForWrite = textValue
                log += "\nresponding with success, value = '\(textValue)'"
                blePeripheral.respond(to: request, withResult: .success)
            default:
                log += "\nresponding with attributeNotFound"
                blePeripheral.respond(to: request, withResult: .attributeNotFound)
            }
        }
        appendLog(log)
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        appendLog("isReadyToUpdateSubscribers")
    }
}

// MARK: - Other extensions
extension CBManagerState {
    var stringValue: String {
        switch self {
        case .unknown: return "unknown"
        case .resetting: return "resetting"
        case .unsupported: return "unsupported"
        case .unauthorized: return "unauthorized"
        case .poweredOff: return "poweredOff"
        case .poweredOn: return "poweredOn"
        @unknown default: return "\(rawValue)"
        }
    }
}
