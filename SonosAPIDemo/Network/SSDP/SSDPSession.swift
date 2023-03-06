//
//  SSDPSession.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import Combine
import Foundation
import Network


/// Discover Sonos players on the local network (multicast broadcast ).
final class SSDPSession {
    
    enum SSDPError: LocalizedError, Identifiable {
        var id: String { localizedDescription }
        
        case invalidContent
        case multicastCreation(Error)
        case sendRequest(Error)
        case stateUpdate(Error)
        case genericError(String)
        
        var description: String {
            switch self {
            case .invalidContent:
                return "Invalid content received from upnp device."
            case .multicastCreation(let error):
                return "Erreur setting up session: \(error.localizedDescription)"
            case .sendRequest(let error):
                return "Error sending request: \(error.localizedDescription)"
            case .stateUpdate(let error):
                return "Error on session state change: \(error.localizedDescription)"
            case .genericError(let message):
                return ("Error: \(message)")
            }
        }
    }
    
    private let discoveryMessage = "M-SEARCH * HTTP/1.1\r\n" +
    "HOST: 239.255.255.250:1900\r\n" +
    "MAN: \"ssdp:discover\"\r\n" +
    "MX: 1\r\n" +
    "ST: urn:schemas-upnp-org:device:ZonePlayer:1\r\n" +
    "\r\n"
    
    private var group: NWConnectionGroup?
    private let parameters: NWParameters = {
        let parameters: NWParameters = .udp
        parameters.acceptLocalOnly = true
        return parameters
    }()
    private var parserSubscription: AnyCancellable?
    
    let onDeviceFound = PassthroughSubject<SonosDevice, SSDPError>()
    
    
    /// Initiates multicast request.
    func run() throws {
        
        do {
            try setup()
            
            // Wait 1 sec. for multicast replys than cancel the request.
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                self.group?.cancel()
                self.onDeviceFound.send(completion: .finished)
            }
        } catch {
            throw error
        }
    }
    
    
    /// Send multicast request. (Discovery message)
    private func sendRequest() {
        
        let data = discoveryMessage.data(using:  .utf8)
        
        group?.send(content:  data) { error in
            if let error {
                self.onDeviceFound.send(completion: .failure(.sendRequest(error)))
            }
        }
    }
    
    
    /// Set up the multicast broadcast.
    private func setup() throws {
        
        let multicast = try NWMulticastGroup(for: [.hostPort(host: "239.255.255.250", port: 1900)])
        group = NWConnectionGroup(with: multicast, using: parameters)
        
        if group == nil {
            onDeviceFound.send(completion: .failure(.genericError("\(#function) - Cannot create connection group.")))
            return
        }
        group?.setReceiveHandler(maximumMessageSize:  4096, rejectOversizedMessages: true) {  (message, content, isComplete) in
            
            
            if let content {
                let parser = SSDPParser(content)
                
                self.parserSubscription =  parser.onParsingContent.sink(receiveCompletion: { completion in
                    
                    self.parserSubscription?.cancel()
                    
                }, receiveValue: { record in
                    self.onDeviceFound.send(record)
                })
                
                parser.parse()
            } else {
                self.onDeviceFound.send(completion: .failure(.invalidContent))
            }
        }
        
        group?.stateUpdateHandler = { state in
            
            switch state {
            case .setup:
                break
                
            case .waiting(let error):
                self.onDeviceFound.send(completion: .failure(.sendRequest(error)))
                
            case .ready:
                self.sendRequest()
                
            case .failed(let error):
                self.onDeviceFound.send(completion: .failure(.sendRequest(error)))
                
            case .cancelled:
                break
                
            @unknown default:
                print("Unknown group state.")
            }
        }
        
        group?.start(queue: .main)
        
    }
}
