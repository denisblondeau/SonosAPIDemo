//
//  SOAPActionSession.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-01-12.
//

import Combine
import Foundation

/// Sonos Service Action.
final class SOAPActionSession {
    
    // MARK: - Enums Start
    
    enum SOAPActionError: LocalizedError, Identifiable {
        var id: String { localizedDescription }
        
        case dataDecoding(String)
        case urlRequest(Int)
        
        var description: String {
            switch self {
                
            case .dataDecoding(let errorMessage):
                return errorMessage
                
            case .urlRequest(let statusCode):
                return "Cannot retrieve data from host. HTTP response code: \(statusCode)"
            }
        }
    }
    
    enum Service {
        case avTransport(action: AVTransportAction, url: URL)
        case zoneGroupTopology(action: ZoneGroupTopologyAction, url: URL)
        
        var action: String {
            switch self {
                
            case .avTransport(action: let action, _):
                return action.rawValue.capitalizingFirstLetter()
                
            case .zoneGroupTopology(let action, _):
                return action.rawValue.capitalizingFirstLetter()
            }
        }
        
        var actionBody: String {
            switch self {
                
            case .avTransport(let action, _):
                switch action {
                    
                case .getPositionInfo:
                    return "<u:GetPositionInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID></u:GetPositionInfo>"
                }
                
            case .zoneGroupTopology(let action, _):
                switch action {
                    
                case .beginsoftwareUpdate:
                    return ""
                case .checkUpdate:
                    return ""
                case .getZoneGroupAttributes:
                    return ""
                case .getZoneGroupState:
                    return "<u:GetZoneGroupState xmlns:u='urn:schemas-upnp-org:service:ZoneGroupTopology:1'></u:GetZoneGroupState>"
                case .registerMobileDevice:
                    return ""
                case .reportAlarmStartedRunning:
                    return ""
                case .reportUnresponsiveDevice:
                    return ""
                case .submitDiagnostics:
                    return ""
                    
                }
            }
        }
        
        var controlURL: URL {
            switch self {
            
            case .avTransport(_, let url):
                return URL(string: "\(url.description)/MediaRenderer/AVTransport/Control")!
                
            case .zoneGroupTopology(_, let url):
                return URL(string: "\(url.description)/ZoneGroupTopology/Control")!
            }
        }
        
        var serviceType: String {
            switch self {
            case .avTransport:
                return "urn:schemas-upnp-org:service:AVTransport:1#"
            case .zoneGroupTopology:
                return "urn:schemas-upnp-org:service:ZoneGroupTopology:1#"
            }
        }
    }
    
    // MARK: - Enums End
    
    private var service: Service
    let onDataReceived = PassthroughSubject<String, SOAPActionError>()
    
    init(service: Service) {
        self.service = service
    }
    
    /// Execute the specified action.
    func run() {
        
        let soapBody = "<?xml version='1.0' encoding='utf-8'?><s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'><s:Body>\(service.actionBody)</s:Body></s:Envelope>"
    
        let length = soapBody.count
        let soapAction = service.serviceType + service.action
     
        Task {
            var request = URLRequest(url: service.controlURL)
        
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("\(length)", forHTTPHeaderField: "Content-Length")
            request.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            request.httpMethod = "POST"
            request.httpBody = soapBody.data(using: .utf8)
            
            let (data, response) = try! await URLSession.shared.data(for: request)
            
            let httpResponse = response as! HTTPURLResponse
           
            guard httpResponse.statusCode == 200 else {
                onDataReceived.send(completion: .failure(.urlRequest(httpResponse.statusCode)))
                return
            }
            
            var sourceXML: String?
            
            switch service.action {
                
            case AVTransportAction.getPositionInfo.rawValue.capitalizingFirstLetter():
                sourceXML = String(data: data, encoding: .utf8)
            
            case ZoneGroupTopologyAction.getZoneGroupState.rawValue.capitalizingFirstLetter():
                sourceXML = String(data: data, encoding: .utf8)?.html2String
                
            default:
                onDataReceived.send(completion: .failure(.dataDecoding("Unknown service action to decode.")))
                return
            }
            
            guard let sourceXML else {
                onDataReceived.send(completion: .failure(.dataDecoding("Cannot decode html to xml.")))
                return
            }
            
            let parser = ActionParser()
            let jsonStr = parser.process(action: service.action, xml: sourceXML)
            
            guard let jsonStr else {
                onDataReceived.send(completion: .failure(.dataDecoding("Cannot parse XML to JSON.")))
                return
            }
          
            onDataReceived.send(jsonStr)
            onDataReceived.send(completion: .finished)
        }
    }
}

// MARK: - Shared enums

enum AVTransportAction: String {
    case getPositionInfo
}

enum ZoneGroupTopologyAction: String {
    case beginsoftwareUpdate
    case checkUpdate
    case getZoneGroupAttributes
    case getZoneGroupState
    case registerMobileDevice
    case reportAlarmStartedRunning
    case reportUnresponsiveDevice
    case submitDiagnostics
}
