//
//  SonosDevice.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import Foundation

// MARK: - SonosDevice
struct SonosDevice: Codable {
    let cacheControl: String
    let ext: JSONNull?
    let location: String
    var hostURL: URL? {
        if let locationURL = URL(string: location) {
            if let baseURL = getBaseURL(from: locationURL) {
                return baseURL
            }
        }
        return nil
    }
    let server, st, usn, xRinconHousehold: String
    let xRinconBootseq, bootidUpnpOrg, xRinconWifimode, xRinconVariant: Int
    let householdSmartspeakerAudio: String
    let securelocationUpnpOrg, xSonosHhsecurelocation: String
    
    enum CodingKeys: String, CodingKey {
        case cacheControl = "CACHE-CONTROL"
        case ext = "EXT"
        case location = "LOCATION"
        case server = "SERVER"
        case st = "ST"
        case usn = "USN"
        case xRinconHousehold = "X-RINCON-HOUSEHOLD"
        case xRinconBootseq = "X-RINCON-BOOTSEQ"
        case bootidUpnpOrg = "BOOTID.UPNP.ORG"
        case xRinconWifimode = "X-RINCON-WIFIMODE"
        case xRinconVariant = "X-RINCON-VARIANT"
        case householdSmartspeakerAudio = "HOUSEHOLD.SMARTSPEAKER.AUDIO"
        case securelocationUpnpOrg = "SECURELOCATION.UPNP.ORG"
        case xSonosHhsecurelocation = "X-SONOS-HHSECURELOCATION"
    }
}

// MARK: - Encode/decode helpers
class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public func hash(into hasher: inout Hasher) {
        // No-op
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
