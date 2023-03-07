//
//  SOAPEventSession.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-01-14.
//

import AppKit
import Combine
import Network

/// Sono Service Event.
final class SOAPEventSession {
    
    // MARK: - Enums Start
    
    enum SOAPEventError: LocalizedError, Identifiable {
        var id: String { localizedDescription }
        
        case dataDecoding(String)
        case httpResponse(Int)
        case urlRequest(Error)
        case genericError(String)
        
        var description: String {
            switch self {
                
            case .httpResponse(let statusCode):
                return "Cannot subscribe to host. HTTP response code: \(statusCode)"
                
            case .urlRequest(let error):
                return "Cannot subscribe to host. Invalud URL request: \(error.localizedDescription)"
                
            case .dataDecoding(let error):
                return "Cannot parse json data to object - \(error)"
                
            case .genericError(let description):
                return ("Error occured: \(description)")
            }
        }
    }
    
    enum SonosEvents {
        
        case subscription(service: SonosService)
        
        var service: SonosService {
            
            switch self {
                
            case .subscription(service: let service):
                return service
            }
        }
        
        var eventSubscriptionEndpoint: String {
            
            switch self {
                
            case .subscription(service: let service):
                
                var endpoint = ""
                
                switch service {
                    
                case .alarmClock:
                    break
                case .audioIn:
                    break
                case .avTransport:
                    endpoint = "/MediaRenderer/AVTransport/Event"
                case .connectionManager:
                    break
                case .contentDirectory:
                    break
                case .deviceProperties:
                    break
                case .groupManagement:
                    break
                case .groupRenderingControl:
                    endpoint = "/MediaRenderer/GroupRenderingControl/Event"
                case .htControl:
                    break
                case .musicServices:
                    break
                case .qPlay:
                    break
                case .queue:
                    break
                case .renderingControl:
                    break
                case .systemProperties:
                    break
                case .virtualLineIn:
                    break
                case .zoneGroupTopology:
                    endpoint = "/ZoneGroupTopology/Event"
                }
                return endpoint
            }
        }
    }
    
    // MARK: - Enums End
    
    private var serviceEvents: [SonosEvents]
    private var listener: NWListener!
    private var subscriptionSID = [String]()
    private var subscriptionTimeout = 86400 // 86400 seconds = 24 hrs.
    private var renewSubscriptionTimer: Timer?
    private var callbackURL: URL
    private var hostURL: URL
    
    private let parameters: NWParameters = {
        let parameters: NWParameters = .tcp
        parameters.acceptLocalOnly = true
        return parameters
    }()
    
    let onDataReceived = PassthroughSubject<JSONData, SOAPEventError>()
    
    init(serviceEvents: [SonosEvents], hostURL: URL, callbackURL: URL) {
        
        self.serviceEvents = serviceEvents
        self.callbackURL = callbackURL
        self.hostURL = hostURL
        
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            self.cancel()
        }
    }
    
    /// Start listening to events..
    func run() {
        
        setupListener()
    }
    
    /// Cancel subscriptions and listener on demand.
    func cancel() {
        Task {
            do {
                renewSubscriptionTimer?.invalidate()
                try await self.unsubscribeFromEvents()
                if listener.state != .cancelled {
                    listener.cancel()
                }
                
                self.onDataReceived.send(completion: .finished)
            } catch {
                self.onDataReceived.send(completion: .failure(.urlRequest(error)))
            }
        }
    }
    
    private func setupListener() {
        
        guard let port = NWEndpoint.Port(String(callbackURL.port!)) else {
            
            onDataReceived.send(completion: .failure(.genericError("Invalid port.")))
            return
        }
        do {
            listener = try NWListener(using: parameters, on: port)
        } catch {
            onDataReceived.send(completion: .failure(.genericError(error.localizedDescription)))
            return
        }
        
        listener.stateUpdateHandler = { state in
            
            switch state {
                
            case .setup:
                break
                
            case .waiting(_):
                break
                
            case .ready:
                
                Task {
                    do {
                        try await self.subscribeToEvents()
                    } catch {
                        self.cancel()
                        self.onDataReceived.send(completion: .failure(.urlRequest(error)))
                    }
                }
                
            case .failed(let error):
                fatalError("Listener Failed: (\(error.localizedDescription)")
                
            case .cancelled:
                break
                
            @unknown default:
                break
            }
        }
        
        listener.newConnectionHandler = { connection in
            
            // Need to ack Sonos coordinator - otherwise the subscription will terminate.
            let msg = "HTTP/1.1 200 OK\r\nContent-length: 0\r\nConnection: close\r\n\r\n"
            
            connection.send(content: Data(msg.utf8), completion: .idempotent)
            
            connection.receiveMessage { completeContent, contentContext, isComplete, error in
                
                connection.cancel()
                
                if let completeContent {
                    
                    let parser = EventParser()
                    
                    if let jsonData = parser.process(eventData: completeContent) {
                        self.onDataReceived.send(jsonData)
                    } else {
                        self.onDataReceived.send(completion: .failure(.dataDecoding("Cannot parse XML to JSON.")))
                    }
                }
            }
            
            connection.stateUpdateHandler = { state in
                switch state {
                    
                case .setup:
                    break
                    
                case .waiting(_):
                    break
                    
                case .preparing:
                    break
                    
                case .ready:
                    break
                    
                case .failed(_):
                    fatalError("Connection Failed")
                    
                case .cancelled:
                    break
                    
                @unknown default:
                    break
                }
            }
            connection.start(queue: .main)
        }
        listener.start(queue: .main)
    }
    
    private func renewSubscriptions() async throws {
        
        guard !subscriptionSID.isEmpty else {
            return
        }
        
        var request: URLRequest
        
        for (index, serviceEvent) in serviceEvents.enumerated() {
            
            let serviceURL = URL(string: hostURL.description + serviceEvent.eventSubscriptionEndpoint)
            guard let serviceURL else {
                onDataReceived.send(completion: .failure(.genericError("\(#function) - Cannot create service URL.")))
                return
            }
            
            request = URLRequest(url: serviceURL)
            request.httpMethod = "SUBSCRIBE"
            request.addValue("\(subscriptionSID[index])", forHTTPHeaderField: "SID")
            request.addValue("Second-\(subscriptionTimeout)", forHTTPHeaderField: "TIMEOUT")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            let httpResponse = response as! HTTPURLResponse
            
            guard httpResponse.statusCode == 200 else {
                onDataReceived.send(completion: .failure(.httpResponse(httpResponse.statusCode)))
                return
            }
            
            if let sid = httpResponse.value(forHTTPHeaderField: "SID") {
                subscriptionSID[index] = sid
            } else {
                subscriptionSID[index] = ""
            }
        }
    }
    
    private func subscribeToEvents() async throws {
        
        var request: URLRequest
        for serviceEvent in serviceEvents {
            
            let serviceURL = URL(string: hostURL.description + serviceEvent.eventSubscriptionEndpoint)
            guard let serviceURL else {
                onDataReceived.send(completion: .failure(.genericError("\(#function) - Cannot create service URL.")))
                return
            }
            
            request = URLRequest(url: serviceURL)
            request.httpMethod = "SUBSCRIBE"
            request.addValue("<\(callbackURL.description)>", forHTTPHeaderField: "CALLBACK")
            request.addValue("upnp:event", forHTTPHeaderField: "NT")
            request.addValue("Second-\(subscriptionTimeout)", forHTTPHeaderField: "TIMEOUT")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            let httpResponse = response as! HTTPURLResponse
            
            guard httpResponse.statusCode == 200 else {
                onDataReceived.send(completion: .failure(.httpResponse(httpResponse.statusCode)))
                return
            }
            
            if let sid = httpResponse.value(forHTTPHeaderField: "SID") {
                
                subscriptionSID.append(sid)
            } else {
                onDataReceived.send(completion: .failure(.genericError("\(#function) - Cannot retrieve SID.")))
                return
            }
        }
        
        // Set up subscription renewal - Rewnew 1 minute before end of current subscription.
        renewSubscriptionTimer = Timer.scheduledTimer(withTimeInterval: Double(subscriptionTimeout - 60), repeats: true) { timer in
            Task {
                do {
                    try await self.renewSubscriptions()
                } catch {
                    self.onDataReceived.send(completion: .failure(.urlRequest(error)))
                }
            }
        }
    }
    
    private func unsubscribeFromEvents() async throws {
        
        guard !subscriptionSID.isEmpty else {
            return
        }
        
        
        var request: URLRequest
        
        for (index, serviceEvent) in serviceEvents.enumerated() {
            
            let serviceURL = URL(string: hostURL.description + serviceEvent.eventSubscriptionEndpoint)
            guard let serviceURL else {
                onDataReceived.send(completion: .failure(.genericError("\(#function) - Cannot create service URL.")))
                return
            }
            
            request = URLRequest(url: serviceURL)
            request.httpMethod = "UNSUBSCRIBE"
            request.addValue("\(subscriptionSID[index])", forHTTPHeaderField: "SID")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            let httpResponse = response as! HTTPURLResponse
            
            guard httpResponse.statusCode == 200 else {
                
                onDataReceived.send(completion: .failure(.httpResponse(httpResponse.statusCode)))
                return
            }
        }
        
        renewSubscriptionTimer?.invalidate()
        subscriptionSID.removeAll()
    }
}

// MARK: - Shared enum

enum SonosService: String  {
    case alarmClock
    case audioIn
    case avTransport
    case connectionManager
    case contentDirectory
    case deviceProperties
    case groupManagement
    case groupRenderingControl
    case htControl
    case musicServices
    case qPlay
    case queue
    case renderingControl
    case systemProperties
    case virtualLineIn
    case zoneGroupTopology
    
}
