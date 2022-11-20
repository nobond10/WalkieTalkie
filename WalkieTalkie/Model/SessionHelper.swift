//
//  SessionHelper.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 11.11.2022.
//

import Foundation
import MultipeerConnectivity

protocol SessionHelperDelegate: AnyObject {
    func connectionEstablished(withPeer: String)
    func connectionFailed(withPeer: String)
    func didReceive(data: Data)
    func didReceive(stream: InputStream)
}

enum SessionError: LocalizedError {
    case noPeers
    case failedToCreateStream
    
    var errorDescription: String? {
        switch self {
        case .noPeers:
            return "В сессии нет пиров"
        case .failedToCreateStream:
            return "Не удалось начать запись"
        }
    }
}

class SessionHelper: NSObject {
    private let session: MCSession
    private let peerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceType: String
    private var assistant: MCAdvertiserAssistant?
    private let streamName = "stream"
    weak var delegate: SessionHelperDelegate?

    init(serviceType: String) {
        self.serviceType = serviceType
        self.session = MCSession(peer: peerId)
        super.init()
        self.session.delegate = self
    }

    deinit {
        assistant?.stop()
        session.disconnect()
    }
}

extension SessionHelper {
    func startHost() {
        assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        assistant?.start()
    }
    
    func startJoin(on vc: UIViewController) {
        let browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = self
        browser.maximumNumberOfPeers = 2
        vc.present(browser, animated: true)
    }
    
    func send(data: Data) {
        do {
            try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error)
        }
    }
    
    func startStream(completion: (Result<OutputStream, SessionError>)->()) {
        if let peer = self.session.connectedPeers.first {
            do {
                let stream = try self.session.startStream(withName: streamName, toPeer: peer)
                completion(.success(stream))
            } catch {
                completion(.failure(.failedToCreateStream))
            }
        } else {
            completion(.failure(.noPeers))
        }
    }
}

extension SessionHelper: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            delegate?.connectionFailed(withPeer: peerID.displayName)
        case .connecting:
            delegate?.connectionFailed(withPeer: peerID.displayName)
        case .connected:
            delegate?.connectionEstablished(withPeer: peerID.displayName)
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.didReceive(data: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        delegate?.didReceive(stream: stream)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension SessionHelper: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}
