import Flutter
import UIKit

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    let TAG = "[SwiftZendeskMessagingPlugin]"
    private var channel: FlutterMethodChannel
    var isInitialized = false
    var isLoggedIn = false
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_messaging", binaryMessenger: registrar.messenger())
        let instance = SwiftZendeskMessagingPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            self.processMethodCall(call, result: result)
        }
    }

    private func processMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let arguments = call.arguments as? Dictionary<String, Any>
        let zendeskMessaging = ZendeskMessaging(flutterPlugin: self, channel: channel)
        
        switch(method){
            case "initialize":
                if (isInitialized) {
                    print("\(TAG) - Messaging is already initialize!\n")
                    return
                }
                let channelKey: String = (arguments?["channelKey"] ?? "") as! String
                zendeskMessaging.initialize(channelKey: channelKey, flutterResult: result)
            case "show":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                zendeskMessaging.show(rootViewController: UIApplication.shared.delegate?.window??.rootViewController, flutterResult: result)
            case "loginUser":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                let jwt: String = arguments?["jwt"] as! String
                zendeskMessaging.loginUser(jwt: jwt, flutterResult: result)
            case "logoutUser":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                zendeskMessaging.logoutUser(flutterResult: result)
            case "getUnreadMessageCount":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                result(handleMessageCount())
            case "isInitialized":
                result(handleInitializedStatus())
            case "isLoggedIn":
                result(handleLoggedInStatus())
            case "setConversationTags":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                let tags: [String] = arguments?["tags"] as! [String]
                zendeskMessaging.setConversationTags(tags:tags)
                result(nil)
            case "clearConversationTags":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                zendeskMessaging.clearConversationTags()
                result(nil)
            case "setConversationFields":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                let fields: [String: String] = arguments?["fields"] as! [String: String]
                zendeskMessaging.setConversationFields(fields:fields)
                result(nil)
            case "clearConversationFields":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                zendeskMessaging.clearConversationFields()
                result(nil)
            case "invalidate":
                if (!isInitialized) {
                    print("\(TAG) - Messaging is already on an invalid state\n")
                    return
                }
                zendeskMessaging.invalidate()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    private func handleMessageCount() ->Int{
         let zendeskMessaging = ZendeskMessaging(flutterPlugin: self, channel: channel)

        return zendeskMessaging.getUnreadMessageCount()
    }
    private func handleInitializedStatus() ->Bool{
        return isInitialized
    }
    private func handleLoggedInStatus() ->Bool{
        return isLoggedIn
    }
}
