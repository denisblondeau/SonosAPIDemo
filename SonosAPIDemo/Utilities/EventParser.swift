//
//  EventParser.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-02-01.
//

import Foundation

/// Parse various Sonos events (XML Data)
final class EventParser {
    
    
    /// Convert XML to JSON.
    /// - Parameter eventData: Data to be parsed.
    /// - Returns: JSON object.
    func process(eventData: Data) -> JSONData? {
        
        guard let source = String(data: eventData, encoding: .utf8)?.components(separatedBy: "\r\n\r\n") else { return nil }
        guard (source.count == 2) else { return nil }
        
        let sourceHeaders = source[0].components(separatedBy: "\r\n")
        let serviceKey = "X-SONOS-SERVICETYPE: "
        
        guard let serviceTypeHeader = sourceHeaders.last, serviceTypeHeader.contains(serviceKey) else { return nil }
        
        var jsonData: JSONData? = nil
        
        switch serviceTypeHeader.uppercased() {
            
        case (serviceKey + SonosService.avTransport.rawValue.uppercased()):
            
            let json =  processAVTransport(xml: source[1].html2String)
            if let json {
                jsonData =  JSONData(sonosService: .avTransport, json: json)
            }
            
        case (serviceKey + SonosService.groupRenderingControl.rawValue.uppercased()):
            if let json =  processGroupRenderingControl(xml: source[1]) {
                jsonData =  JSONData(sonosService: .groupRenderingControl, json: json)
            }
            
        default:
            break
        }
        return jsonData
    }
    
    private func processAVTransport(xml: String) -> String? {
        
        guard let doc = try? XMLDocument(xmlString: xml) else { return  nil }
        guard let node = try? doc.nodes(forXPath: "/Event[1]/InstanceID[1]")[0] else { return nil }
        guard let children = node.children else { return nil }
        
        var json = "{"
        
        for (index, child) in children.enumerated() {
            
            guard let element = child as? XMLElement else { return nil }
            guard let key = element.name, let value = element.attribute(forName: "val")?.stringValue else { return nil }
            
            if value.prefix(1) == "<" {
                
                json += "\"\(key)\": {"
                if let jsonValue = processXML(xml: value) {
                    json += jsonValue
                } else {
                    return nil
                }
                
                json += "}, "
                
            } else {
                json += "\"\(key)\": \"\(value)\""
                if (index < children.count - 1) {
                    json += ", "
                }
            }
        }
        
        json += "}"
        //  print(json)
        return json
        
        func processXML(xml: String) -> String? {
            guard let doc = try? XMLDocument(xmlString: xml) else { return nil }
            guard let root = doc.rootElement() else { return nil }
            guard let children = root.children else { return nil }
            
            var json = ""
            let child = children[0]
            
            guard let children = child.children else { return nil}
            
            for (index, child) in children.enumerated() {
                
                guard let element = child as? XMLElement else { return nil }
                guard let key = element.name, let value = element.stringValue else { return nil }
                
                json += "\"\(key)\": \"\(value)\""
                
                if (index < children.count - 1) {
                    json += ", "
                }
            }
            return json
        }
    }
    
    private func processGroupRenderingControl(xml: String) -> String?  {
        
        guard let doc = try? XMLDocument(xmlString: xml) else { return  nil }
        guard let root = doc.rootElement() else { return nil }
        guard let children = root.children else { return nil }
        
        var json = "{"
        
        for (index, child) in children.enumerated() {
            
            guard child.childCount > 0 else { return nil }
            
            for node in child.children! {
                
                if let key = node.name, let value = node.stringValue {
                    json += "\"\(key)\": \"\(value)\""
                }
            }
            
            if (index < children.count - 1) {
                json += ", "
            }
        }
        
        json += "}"
        
        return json
    }
}

// MARK: - Shared structure

struct JSONData {
    let sonosService: SonosService
    let json: String
}
