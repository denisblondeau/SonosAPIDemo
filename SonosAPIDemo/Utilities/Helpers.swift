//
//  Helpers.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import Foundation


// MARK: - getBaseURL
/// Parse a full URL (URI) to its basic scheme, host name, and port number.
/// - Parameter url: URI to parse.
/// - Returns: Basic URL.
func getBaseURL(from url: URL) -> URL? {
    
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
        if let scheme = components.scheme {
            
            if let host = components.host {
                var baseURL = scheme + "://" + host
                if let port = components.port {
                    baseURL += ":\(port)"
                }
                if let url =  URL(string: baseURL) {
                    return url
                    
                }
            }
        }
    }
    return nil
}

// MARK: - parseJSONToObject
/// Parse json data to a known object.
/// - Parameters:
///   - json: JSON data to decode.
///   - completion: New struct of type T or nil if decoding error.
func parseJSONToObject<T: Decodable>(json: String, completion: @escaping (T?) -> ())  {
    
    let debug = true
    var errorMessage = ""
    
    let decoder = JSONDecoder()
    
    do {
        completion(try decoder.decode(T.self, from: Data(json.utf8)))
        
    } catch let DecodingError.dataCorrupted(context) {
        errorMessage = "Data corrupted: \(context)"
        
    } catch let DecodingError.keyNotFound(key, context) {
        errorMessage = "Key '\(key)' not found: \(context.debugDescription)\ncodingPath: \(context.codingPath)"
        
    } catch let DecodingError.valueNotFound(value, context) {
        errorMessage = "Value '\(value)' not found: \(context.debugDescription)\ncodingPath: \(context.codingPath)"
        
    } catch let DecodingError.typeMismatch(type, context)  {
        errorMessage = "Type '\(type)' mismatch: \(context.debugDescription)\ncodingPath: \(context.codingPath)"
        
    } catch {
        errorMessage = "Error in \(#function): \(error)"
    }
    
    if debug  && !errorMessage.isEmpty {
        print("ERROR DECODING TYPE:", T.self)
        print("JSON START")
        print(json)
        print("JSON ENDS")
        fatalError(errorMessage)
    }
}

// MARK: - Extensions

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}

extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

