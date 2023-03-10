import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      let METHOD_CHANNEL_NAME = "com.exampleDL.swiftTest/battery"
      let METHOD_CHANNEL_NAME2 = "com.exampleDL.swiftTest/scan"
      
      let batteryChannel = FlutterMethodChannel(
        name: METHOD_CHANNEL_NAME,
        binaryMessenger: controller.binaryMessenger
      )
      let scanChannel = FlutterMethodChannel(
        name: METHOD_CHANNEL_NAME2,
        binaryMessenger: controller.binaryMessenger
      )
      let adv = BLEPeripheralViewController(channel: batteryChannel)
      let scan = BLECentralViewController(channel: scanChannel)
      
      adv.viewDidLoad()
      
      batteryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method{
          case "send":
              guard let args = call.arguments as? [String: String] else{return}
              let message = args["message"]!
              adv.bleSendIndication(message)
          case "getState":
              result("\(adv.blePeripheral.state)")
          case "getBatteryLevel":
              adv.viewDidLoad()
              result("\(self.reciveBatteryLevel())")
          case "advertise":
              adv.onSwitchChangeAdvertising(true)
              result("\(adv.bleGetStatusString())")
              
          default: result(FlutterMethodNotImplemented)
          }
      })
      
      scanChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method{
          case "send":
              guard let args = call.arguments as? [String: String] else{return}
              let message = args["message"]!
            //  adv.bleSendIndication(message)
              scan.onTapWriteCharacteristic("XD", text: message)
          case "getState":
              result("\(scan.bleCentral.state)")
          case "init":
              scan.viewDidLoad()
         //     result("\(self.reciveBatteryLevel())")
          case "scan":
              scan.bleScan()
              result("\(scan.textViewStatus)")
              
          default: result(FlutterMethodNotImplemented)
          }
      })


      
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func reciveBatteryLevel()->Int{
  let device = UIDevice.current
  device.isBatteryMonitoringEnabled = true
  if device.batteryState == UIDevice.BatteryState.unknown{
      return -1
  }else{
      return Int(device.batteryLevel*100)
  }
}
}
