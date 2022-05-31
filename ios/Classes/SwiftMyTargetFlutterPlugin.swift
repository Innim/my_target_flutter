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
    private var ads: [String: MTRGInterstitialAd] = [:]
    
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
            guard
                let adUid = call.arguments as? String
                else {
                    result(FlutterError.invalidArgs())
                    return
            }
            load(result: result, adUid: adUid)
        case .show:
            guard
                let adUid = call.arguments as? String
                else {
                    result(FlutterError.invalidArgs())
                    return
            }
            show(result: result, adUid: adUid)
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
        let uid = "\(slotId)_\(rnd)"
        
        ads[uid] = ad
        
        result(uid)
    }
    
    private func load(result: @escaping FlutterResult, adUid: String) {
        guard
            let ad = ads[adUid]
            else {
                result(FlutterError.adsNotFound(adUid))
                return
            }
            
            ad.load()
    }
    
    private func show(result: @escaping FlutterResult, adUid: String) {
        guard
            let ad = ads[adUid]
            else {
                result(FlutterError.adsNotFound(adUid))
                return
            }
            
            let viewController = (UIApplication.shared.delegate?.window??.rootViewController)!
            ad.show(with: viewController)
    }
}

extension FlutterError {
    static func invalidArgs(_ message: String = "Arguments is invalid", details: Any? = nil) -> FlutterError {
        return FlutterError(code: "INVALID_ARGS", message: message, details: details);
    }
    
    static func adsNotFound(_ uid: String, details: Any? = nil) -> FlutterError {
        return FlutterError(code: "ADS_NOT_FOUND", message: "Ads with uid <\(uid)> not found", details: details);
    }
}
