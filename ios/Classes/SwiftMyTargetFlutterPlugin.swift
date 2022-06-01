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
    private var dispatcher: AdDispatcher!
    private var ads: [String: Ad] = [:]
        
    var viewController: UIViewController? {
        get {
            return UIApplication.shared.delegate?.window??.rootViewController
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "my_target_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMyTargetFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public override init() {
        super.init()
        let controller = viewController as! FlutterViewController
        dispatcher = AdDispatcher(controller: controller)
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
        
        let delegate = InterstitialAdDelegate(dispatcher, uid, clear)
        ad.delegate = delegate
        
        ads[uid] = Ad(ad, delegate)
        
        result(uid)
    }
    
    private func load(result: @escaping FlutterResult, adUid: String) {
        guard
            let item = ads[adUid]
        else {
            result(FlutterError.adsNotFound(adUid))
            return
        }
        
        item.ad.load()
    }
    
    private func show(result: @escaping FlutterResult, adUid: String) {
        guard
            let item = ads[adUid]
        else {
            result(FlutterError.adsNotFound(adUid))
            return
        }
        
        item.ad.show(with: viewController!)
    }
    
    private func clear(_ adUid: String) {
        if let item = ads.removeValue(forKey: adUid) {
            item.ad.delegate = nil
        }
    }
}

enum AdEvent: String {
    case loaded = "ad_loaded",
         noAd = "no_ad",
         display = "ad_display",
         click = "click_on_ad",
         videoComplete = "ad_video_completed",
         close = "ad_dismiss"
}

class AdDispatcher: NSObject, FlutterStreamHandler {
    private let channel: FlutterEventChannel
    private var sink: FlutterEventSink?
    private var intents = [URL]()
    
    init(controller: FlutterViewController) {
        channel = FlutterEventChannel(name: "my_target_flutter/ad_listener",
                                      binaryMessenger: controller.binaryMessenger)
        
        super.init()
        channel.setStreamHandler(self)
    }
    
    func dispatch(uid: String, event: AdEvent, data: [String: Any]? = nil) {
        if let events = sink {
            var event: [String: Any] = ["event": event.rawValue, "uid": uid]
            if data != nil {
                event["data"] = data
            }
            
            events(event)
        }
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}

class Ad {
    public var ad: MTRGInterstitialAd
    private var delegate: InterstitialAdDelegate
    
    init(_ ad: MTRGInterstitialAd, _ delegate: InterstitialAdDelegate) {
        self.ad = ad
        self.delegate = delegate
    }
}

class InterstitialAdDelegate: NSObject, MTRGInterstitialAdDelegate {
    private var dispatcher: AdDispatcher
    private var uid: String
    private var onDone: (_ uid: String) -> Void
    
    init(_ dispatcher: AdDispatcher, _ uid: String, _ onDone: @escaping (_ uid: String) -> Void) {
        self.dispatcher = dispatcher
        self.uid = uid
        self.onDone = onDone
    }

    func onLoad(with interstitialAd: MTRGInterstitialAd) {
        dispatcher.dispatch(uid: uid, event: AdEvent.loaded)
    }
    
    func onNoAd(withReason reason: String, interstitialAd: MTRGInterstitialAd) {
        dispatcher.dispatch(uid: uid, event: AdEvent.noAd, data: ["reason": reason])
        onDone(uid)
    }
    
    func onDisplay(with interstitialAd: MTRGInterstitialAd) {
        dispatcher.dispatch(uid: uid, event: AdEvent.display)
    }
    
    func onClick(with interstitialAd: MTRGInterstitialAd) {
        dispatcher.dispatch(uid: uid, event: AdEvent.click)
    }
    
    func onVideoComplete(with interstitialAd: MTRGInterstitialAd) {
        dispatcher.dispatch(uid: uid, event: AdEvent.videoComplete)
    }
    
    func onClose(with interstitialAd: MTRGInterstitialAd) {
        dispatcher.dispatch(uid: uid, event: AdEvent.close)
        onDone(uid)
    }
    
    func onLeaveApplication(with interstitialAd: MTRGInterstitialAd) {
//        dispatcher.dispatch(uid: uid, event: AdEvent.)
        onDone(uid)
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
