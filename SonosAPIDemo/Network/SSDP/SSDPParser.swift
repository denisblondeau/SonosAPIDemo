//
//  SSDPParser.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-01-11.
//

import Combine
import Foundation

/// Parse SSDP data  to JSON and then to a SonosDevice object.
final class SSDPParser {
    
    enum ParserError: LocalizedError, Identifiable {
        var id: String { localizedDescription }
        
        case dataDecoding(String)
        case invalidContent
        
        var description: String {
            
            switch self {
                
            case .dataDecoding(let errorMessage):
                return errorMessage
                
            case .invalidContent:
                return "Invalid content provided - cannot parse."
            }
        }
    }
    
    let onParsingContent = PassthroughSubject<SonosDevice, ParserError>()
    private var content = ""
    
    init(_ data: Data) {
        if let content = String(data: data, encoding: .utf8) {
            self.content = content
        } else {
            onParsingContent.send(completion: .failure(.invalidContent))
        }
    }
    
    func parse() {
        if content.isEmpty {
            onParsingContent.send(completion: .failure(.invalidContent))
            return
        }
        
        var json = "{"
        var components = content.components(separatedBy: "\r\n")
        
        components.remove(at: 0)
        components.removeAll { string in
            string.isEmpty
        }
        
        for (index, component) in components.enumerated() {
            
            var keyword = ""
            var nextIndex: String.Index?
            var value = ""
            let endOfKeyword = component.firstIndex(of: ":")
            
            if let endOfKeyword {
                keyword = String(component[..<endOfKeyword])
                json += "\"\(keyword)\": "
                
                nextIndex = component.index(endOfKeyword, offsetBy: 2, limitedBy: component.endIndex)
                if let nextIndex {
                    value = String(component[nextIndex...])
                    if Int(value) != nil {
                        json += "\(value)"
                    } else {
                        json += "\"\(value)\""
                    }
                } else {
                    json += "null"
                }
            }
            
            if index < (components.count - 1) {
                json += ","
            }
        }
        
        json += "}"
        
        let decoder = JSONDecoder()
        
        do {
            let record = try decoder.decode(SonosDevice.self, from: Data(json.utf8))
            onParsingContent.send(record)
            onParsingContent.send(completion: .finished)
            
        } catch let DecodingError.dataCorrupted(context) {
            onParsingContent.send(completion: .failure(.dataDecoding("Data corrupted: \(context)")))
            
        } catch let DecodingError.keyNotFound(key, context) {
            onParsingContent.send(completion: .failure(.dataDecoding("Key '\(key)' not found: \(context.debugDescription)\ncodingPath: \(context.codingPath)")))
            
        } catch let DecodingError.valueNotFound(value, context) {
            onParsingContent.send(completion: .failure(.dataDecoding("Value '\(value)' not found: \(context.debugDescription)\ncodingPath: \(context.codingPath)")))
            
        } catch let DecodingError.typeMismatch(type, context)  {
            onParsingContent.send(completion: .failure(.dataDecoding("Type '\(type)' mismatch: \(context.debugDescription)\ncodingPath: \(context.codingPath)")))
            
        } catch {
            onParsingContent.send(completion: .failure(.dataDecoding("Error: \(error)")))
        }
    }
}
