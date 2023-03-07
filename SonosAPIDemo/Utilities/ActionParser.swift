//
//  ActionParser.swift
//  SonoSAPIDemo
//
//  Created by Denis Blondeau on 2023-02-08.
//

import Foundation

/// Parse Sonos Action data  (XML) to JSON.
final class ActionParser {
    
    func process(action: String, xml sourceXML: String) -> String? {
        
        switch action {
            
        case AVTransportAction.getPositionInfo.rawValue.capitalizingFirstLetter():
            return processGetPositionInfo(xml: sourceXML)
            
        case ZoneGroupTopologyAction.getZoneGroupState.rawValue.capitalizingFirstLetter():
            let parser = ParseXMLToJSON(xml: sourceXML)
            return parser.parseXML()
            
        default:
            return nil
        }
    }
    
    private func processGetPositionInfo(xml: String) -> String? {
        
        guard let doc = try? XMLDocument(xmlString: xml) else { return  nil }
        guard let node = try? doc.nodes(forXPath: "/s:Envelope[1]/s:Body[1]")[0] else { return nil }
        guard let children = node.children?[0].children else { return nil }
        
        var json = "{"
        
        for (index, node) in children.enumerated() {
            
            guard let key = node.name, let value = node.stringValue else { continue }
            
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
        
        return json
        
        func processXML(xml: String) -> String? {
            guard let doc = try? XMLDocument(xmlString: xml) else { return nil }
            guard let root = doc.rootElement() else { return nil }
            guard let children = root.children else { return nil }
            
            var json = ""
            let child = children[0]
            
            guard let children = child.children else { return nil }
            
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
}

