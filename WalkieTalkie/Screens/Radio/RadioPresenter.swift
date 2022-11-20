//
//  RadioPresenter.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 11.11.2022.
//

import UIKit

class RadioCreator {
    static func createModule(for mode: Mode) -> UIViewController {
        let presenter = RadioPresenter(mode: mode)
        let vc = RadioVC(presenter: presenter)
        presenter.vc = vc
        return vc
    }
}

final class RadioPresenter {
    private let sessionHelper: SessionHelper
    private let locationHelper = LocationHelper()
    fileprivate weak var vc: RadioVC!
    private let mode: Mode
    
    private var connectionIsOK = false
    private var currentUserWantsSpeaking = false
    private var currentUserIsTalking = false
    private var anyPeerIsTalking = false
    
    private var audioRecorder: AudioRecorder?
    private var audioPlayer: AudioPlayer?

    init(mode: Mode) {
        self.mode = mode
        self.sessionHelper = SessionHelper(serviceType: Constants.serviceType)
        self.sessionHelper.delegate = self
        locationHelper.delegate = self
    }

    private func sendMessageWith(type: MessageType) {
        if let encodedData = try? JSONEncoder().encode(type) {
            sessionHelper.send(data: encodedData)
        }
    }

    private func startSpeaking() {
        currentUserWantsSpeaking = false

        vc?.addToLogs(text: Constants.userStartedSpeaking)

        audioRecorder = AudioRecorder()
        audioRecorder?.delegate = self
        audioRecorder?.startRecording()
        vc?.makeSpeakingButtonTapped()
    }

    private func handleMessageFromPeer(_ message: MessageType) {
        switch message {
        case .wantSpeaking:
            if currentUserWantsSpeaking || currentUserIsTalking {
                sendMessageWith(type: .rejectSpeaking)
                vc?.addToLogs(text: Constants.peersRequestDeclined)
            } else {
                sendMessageWith(type: .allowSpeaking)
                vc?.addToLogs(text: Constants.allowPeerSpeaking)
            }
        case .allowSpeaking:
            startSpeaking()
            vc?.addToLogs(text: Constants.allowUserSpeaking)
        case .rejectSpeaking:
            currentUserWantsSpeaking = false
            vc?.makeSpeakingButtonEnabled()
            vc?.addToLogs(text: Constants.usersRequestDeclined)
        case .stopSpeaking:
            vc?.makeSpeakingButtonEnabled()
            vc?.addToLogs(text: Constants.peerStoppedSpeaking)
            audioPlayer?.stopPlaying()
        case .audioData(let data):
            vc?.makeSpeakingButtonDisabled()
            if audioPlayer == nil {
                audioPlayer = AudioPlayer()
            }
            
            audioPlayer?.play(data: data)
        case let .coordinates(lat, lon):
            locationHelper.updatePeerLocation(lat: lat, lon: lon)
        }
    }
}

extension RadioPresenter {
    func onViewDidAppear() {
        vc?.setStatus(Constants.connectionFailed, isConnectionOk: false)
        vc?.makeSpeakingButtonDisabled()
        
        switch mode {
        case .hoster:
            sessionHelper.startHost()
        case .joiner:
            sessionHelper.startJoin(on: vc)
        }
    }

    func startedHighlighing() {
        if connectionIsOK && !anyPeerIsTalking {
            sendMessageWith(type: .wantSpeaking)
            currentUserWantsSpeaking = true
        }
    }
    
    func endedHighlighting() {
        audioRecorder?.stopRecording()
        
        sendMessageWith(type: .stopSpeaking)
        currentUserWantsSpeaking = false
        currentUserIsTalking = false

        vc?.addToLogs(text: Constants.userStoppedSpeaking)
        vc?.makeSpeakingButtonEnabled()
    }
}

extension RadioPresenter: AudioRecorderDelegate {
    func didRecordData(_ data: Data) {
        sendMessageWith(type: .audioData(data))
    }
}

extension RadioPresenter: SessionHelperDelegate {
    func didReceive(data: Data) {
        do {
            let message = try JSONDecoder().decode(MessageType.self, from: data)
            self.handleMessageFromPeer(message)
        } catch {
            print(error)
        }
    }

    func didReceive(stream: InputStream) {}
    
    func connectionEstablished(withPeer peer: String) {
        connectionIsOK = true
        let text = String(format: Constants.connectionOk, peer)
        vc?.setStatus(text, isConnectionOk: true)

        vc?.addToLogs(text: text)

        vc?.makeSpeakingButtonEnabled()
        locationHelper.startLoading()
    }
    
    func connectionFailed(withPeer: String) {
        vc?.setStatus(Constants.connectionFailed, isConnectionOk: false)

        vc?.addToLogs(text: Constants.connectionFailed)

        vc?.makeSpeakingButtonDisabled()

        connectionIsOK = false
        locationHelper.stopLoading()
    }
}

extension RadioPresenter: LocationHelperDelegate {
    func updatedDistanceBetweenUsers(newValue: Double) {
        let text = String(format: Constants.distance, Int(newValue))
        vc?.setDistance(text)
    }
    
    func didUpdateLocation(lat: Double, lon: Double) {
        sendMessageWith(type: .coordinates(lat, lon))
    }
}
