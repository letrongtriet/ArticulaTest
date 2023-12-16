//
//  CallManager.swift
//  ArticulaTest
//
//  Created by Triet Le on 16.12.2023.
//

import CallKit
import Foundation
import PushKit

class CallManager: NSObject {
    func startVOIP() {
        let callRegistry = PKPushRegistry(queue: nil)
        callRegistry.delegate = self
        callRegistry.desiredPushTypes = [PKPushType.voIP]
    }
}

extension CallManager: CXProviderDelegate, PKPushRegistryDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("providerDidReset")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("Your device token: \(deviceToken)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // Create an object to handle call configurations and settings
        let callConfigObject = CXProviderConfiguration()
        // Disable video calls
        callConfigObject.supportsVideo = false
        // Show missed, received and sent calls in the phone app's Recents category
        callConfigObject.includesCallsInRecents = true
        // Create an object to give update about call-related events
        let callReport = CXCallUpdate()
        // Display the name of the caller
        callReport.remoteHandle = CXHandle(type: .generic, value: "Hello")
        // Disable video call
        callReport.hasVideo = false
        // Create an object to give update about incoming calls
        let callProvider = CXProvider(configuration: callConfigObject)
        callProvider.reportNewIncomingCall(with: UUID(), update: callReport, completion: { error in })
        callProvider.setDelegate(self, queue: nil)
    }
}
