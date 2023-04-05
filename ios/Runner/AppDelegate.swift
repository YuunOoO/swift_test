import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      let METHOD_CHANNEL_ADVERTISE = "com.exampleDL.swiftTest/advertise"
      let METHOD_CHANNEL_SCAN = "com.exampleDL.swiftTest/scan"
      
      let advertiseChannel = FlutterMethodChannel(
        name: METHOD_CHANNEL_ADVERTISE,
        binaryMessenger: controller.binaryMessenger
      )
      let scanChannel = FlutterMethodChannel(
        name: METHOD_CHANNEL_SCAN,
        binaryMessenger: controller.binaryMessenger
      )
      
      let adv = BLEPeripheralViewController(channel: advertiseChannel)
      let scan = BLECentralViewController(channel: scanChannel)
      
      adv.viewDidLoad()
      
      advertiseChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method{
          case "sendMessage":
              guard let args = call.arguments as? [String: String] else{return}
              let message = args["message"]!
              adv.bleSendIndication(message)
          case "getState":
              result("\(adv.blePeripheral.state)")
          case "advertise":
              adv.onSwitchChangeAdvertising(true)
              result("\(adv.bleGetStatusString())")      
          default: result(FlutterMethodNotImplemented)
          }
      })
      
      scanChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method{
          case "sendMessage":
              guard let args = call.arguments as? [String: String] else{return}
              let message = args["message"]!
              scan.onTapWriteCharacteristic("XD", text: message)
          case "getState":
              result("\(scan.bleCentral.state)")
          case "init":
              scan.viewDidLoad()
          case "scan":
              scan.bleScan()
              result("\(scan.textViewStatus)")
          default: result(FlutterMethodNotImplemented)
          }
      })


      
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
}
