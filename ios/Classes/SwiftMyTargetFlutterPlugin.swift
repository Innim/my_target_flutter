import Flutter
import UIKit
import MyTargetSDK

/// Plugin methods.
enum PluginMethod: String {
    case initialize, load, show
}

/// Arguments for method `PluginMethod.initialize`
enum InitializeArg: String {
    case useDebugMode, testDevices
}

public class SwiftMyTargetFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "my_target_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMyTargetFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = PluginMethod(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        switch (method) {
        case .initialize:
             guard
                let args = call.arguments as? [String: Any],
                let useDebugMode = args[InitializeArg.useDebugMode.rawValue] as? Bool
                else {
                    result(FlutterError(code: "INVALID_ARGS",
                                        message: "Arguments is invalid",
                                        details: nil))
                    return
            }
            
            let testDevices = args[InitializeArg.testDevices.rawValue] as? [String]
            initialize(result: result, useDebugMode: useDebugMode, testDevices: testDevices)
        case .load:
            load(result: result)
        case .show:
            show(result: result)
        }
    }
    
    
    private func initialize(result: @escaping FlutterResult, useDebugMode: Bool, testDevices: [String]?) {
        MTRGManager.setDebugMode(useDebugMode)
        
        if testDevices != nil {
            MTRGManager.sdkConfig = MTRGConfig.newBuilder().withTestDevices(testDevices).build()
        }
        result(nil)
    }
    
    private func load(result: @escaping FlutterResult) {
        // TODO:
    }
    
    private func show(result: @escaping FlutterResult) {
        // TODO:
    }
}
