//
//  ContentViewModel.swift
//  ArticulaTest
//
//  Created by Triet Le on 16.12.2023.
//

import AgoraRtcKit
import AVKit
import Foundation
import SwiftUI

@MainActor
class ContentViewModel: NSObject, ObservableObject {
    @Published var isCalling: Bool = false
    @Published var errorMessage: String = ""
    @Published var hasError: Bool = false

    // The main entry point for Video SDK
    var agoraEngine: AgoraRtcEngineKit!
    
    // By default, set the current user role to broadcaster to both send and receive streams.
    var userRole: AgoraClientRole = .broadcaster

    // Update with the App ID of your project generated on Agora Console.
    let appID = "7cdf504d22bd4c1e831a64af95500db2"
    // Update with the temporary token generated in Agora Console.
    var token = "007eJxTYJinKNqvG9q2pc+Ndc7HVSqrju+X4jhRqhW35ojr7+T7XssUGMyTU9JMDUxSjIySUkySDVMtjA0TzUwS0yxNTQ0MUpKM/ANrUxsCGRkC779nYWSAQBCflcEjNScnn4EBAEhEH7Q="
    // Update with the channel name you used to generate the token in Agora Console.
    var channelName = "Hello"

    private let callManager = CallManager()

    private var isAudioAllowed: Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorized:
            return true
        @unknown default:
            return false
        }
    }

    func onAppear() async {
        callManager.startVOIP()
        await askForAudioPermissionIfNeeded()
        initializeAgoraEngine()
    }

    func onDisappear() {
        stopCall()
        AgoraRtcEngineKit.destroy()
    }

    func didTapCallButton() {
        isCalling ? stopCall() : startCall()
    }

    func didRespondToError() {
        hasError = true
        errorMessage = ""
    }

    private func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = "7cdf504d22bd4c1e831a64af95500db2"
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }

    private func askForAudioPermissionIfNeeded() async {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
            await AVCaptureDevice.requestAccess(for: .audio)
        }
    }

    private func startCall() {
        guard isAudioAllowed else {
            errorMessage = "Please allow microphone access on iPhone Settings and try again."
            hasError = true
            return
        }

        let option = AgoraRtcChannelMediaOptions()

        // Set the client role option as broadcaster or audience.
        if self.userRole == .broadcaster {
            option.clientRoleType = .broadcaster
        } else {
            option.clientRoleType = .audience
        }

        // For an audio call scenario, set the channel profile as communication.
        option.channelProfile = .communication

        // Join the channel with a temp token and channel name
        let result = agoraEngine.joinChannel(
            byToken: token, channelId: channelName, uid: 0, mediaOptions: option,
            joinSuccess: { (channel, uid, elapsed) in }
        )

        // Check if joining the channel was successful and set joined Bool accordingly
        if (result == 0) {
            isCalling = true
        }
    }

    private func stopCall() {
        let result = agoraEngine.leaveChannel(nil)
        // Check if leaving the channel was successful and set joined Bool accordingly
        if result == 0 { isCalling = false }
    }
}

extension ContentViewModel: AgoraRtcEngineDelegate { }
