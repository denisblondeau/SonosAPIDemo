//
//  Helpers.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import Foundation


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
