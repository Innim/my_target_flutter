import Flutter
import UIKit
import MyTargetSDK

/// Plugin methods.
enum PluginMethod: String {
    case initialize, createInterstitialAd, load, show
}

/// Arguments for method `PluginMethod.initialize`
enum InitializeArg: String {
    case useDebugMode, testDevices
}

/// Arguments for method `PluginMethod.createInterstitialAd`
enum CreateInterstitialAdArg: String {
    case slotId
}

public class SwiftMyTargetFlutterPlugin: NSObject, FlutterPlugin {
    private var ads: [String: MTRGBaseAd] = [:]
    
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
                    result(FlutterError.invalidArgs())
                    return
            }
            
            let testDevices = args[InitializeArg.testDevices.rawValue] as? [String]
            initialize(result: result, useDebugMode: useDebugMode, testDevices: testDevices)
        case .createInterstitialAd:
            guard
                let args = call.arguments as? [String: Any],
                let slotId = args[CreateInterstitialAdArg.slotId.rawValue] as? UInt
                else {
                    result(FlutterError.invalidArgs())
                    return
            }
            
            createInterstitialAd(result: result, slotId: slotId)
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
    
    private func createInterstitialAd(result: @escaping FlutterResult, slotId: UInt) {
        let ad = MTRGInterstitialAd(slotId: slotId)
        
        let rnd = Int.random(in: 1000000..<10000000)
        let id = "\(slotId)_\(rnd)"
        
        ads[id] = ad
        
        result(id)
    }
    
    private func load(result: @escaping FlutterResult) {
        // TODO:
    }
    
    private func show(result: @escaping FlutterResult) {
        // TODO:
    }
}

extension FlutterError {
    static func invalidArgs(_ message: String = "Arguments is invalid", details: Any? = nil) -> FlutterError {
        return FlutterError(code: "INVALID_ARGS", message: message, details: details);
    }
}
