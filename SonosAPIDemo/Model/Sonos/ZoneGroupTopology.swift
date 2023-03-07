//
//  ZoneGroupTopology.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-01-24.
//

import Foundation

// MARK: - GroupData
struct ZoneGroupTopology: Codable {
    let zoneGroupState: ZoneGroupState
    
    enum CodingKeys: String, CodingKey {
        case zoneGroupState = "ZoneGroupState"
    }
}

// MARK: - ZoneGroupState
struct ZoneGroupState: Codable {
    let vanishedDevices: JSONNull?
    let zoneGroups: ZoneGroups
    
    enum CodingKeys: String, CodingKey {
        case vanishedDevices = "VanishedDevices"
        case zoneGroups = "ZoneGroups"
    }
}

// MARK: - ZoneGroups
struct ZoneGroups: Codable {
    /// A list of groups in the household (e.g. zone). Each element is a group object.
    let zoneGroup: [ZoneGroup]
    
    enum CodingKeys: String, CodingKey {
        case zoneGroup = "ZoneGroup"
    }
}

// MARK: - ZoneGroup
struct ZoneGroup: Codable {
    /// The ID of the player acting as the group coordinator for the group. This is a playerId value.
    let coordinator: String
    /// The ID of the group.
    let id: String
    let zoneGroupMember: [ZoneGroupMember]
    
    enum CodingKeys: String, CodingKey {
        case coordinator = "@Coordinator"
        case id = "@ID"
        case zoneGroupMember = "ZoneGroupMember"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coordinator = try container.decode(String.self, forKey: .coordinator)
        self.id = try container.decode(String.self, forKey: .id)
        if let x = try? container.decode([ZoneGroupMember].self, forKey: .zoneGroupMember) {
            self.zoneGroupMember = x
        } else
        if let x = try? container.decode(ZoneGroupMember.self, forKey: .zoneGroupMember) {
            var arrayZ = Array<ZoneGroupMember>()
            arrayZ.append(x)
            self.zoneGroupMember = arrayZ
        } else {
            throw DecodingError.typeMismatch(ZoneGroupMember.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ZoneGroupMember"))
        }
    }
}

// MARK: - ZoneGroupMember
struct ZoneGroupMember: Codable {
    let uuid: String
    let location: String
    /// The display name for the room of the device, such as “Living Room” .
    let zoneName: String
    let icon: String
    let configuration: Int
    /// The version of the software running on the device.
    let softwareVersion: String
    let swGen: Int
    let minCompatibleVersion, legacyCompatibleVersion: String
    let bootSeq, tvConfigurationError, hdmiCecAvailable, wirelessMode: Int
    let wirelessLeafOnly, channelFreq, behindWifiExtender, wifiEnabled: Int
    let ethLink, orientation, roomCalibrationState, secureRegState: Int
    let voiceConfigState, micEnabled, airPlayEnabled, idleState: Int
    let moreInfo: String
    let sslPort, hhsslPort: Int
    let htSatChanMapSet: String?
    let satellite: [ZoneGroupMember]?
    let invisible: Int?
    var hostURL: URL? {
        if let locationURL = URL(string: location) {
            if let baseURL = getBaseURL(from: locationURL) {
                return baseURL
            }
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid = "@UUID"
        case location = "@Location"
        case zoneName = "@ZoneName"
        case icon = "@Icon"
        case configuration = "@Configuration"
        case softwareVersion = "@SoftwareVersion"
        case swGen = "@SWGen"
        case minCompatibleVersion = "@MinCompatibleVersion"
        case legacyCompatibleVersion = "@LegacyCompatibleVersion"
        case bootSeq = "@BootSeq"
        case tvConfigurationError = "@TVConfigurationError"
        case hdmiCecAvailable = "@HdmiCecAvailable"
        case wirelessMode = "@WirelessMode"
        case wirelessLeafOnly = "@WirelessLeafOnly"
        case channelFreq = "@ChannelFreq"
        case behindWifiExtender = "@BehindWifiExtender"
        case wifiEnabled = "@WifiEnabled"
        case ethLink = "@EthLink"
        case orientation = "@Orientation"
        case roomCalibrationState = "@RoomCalibrationState"
        case secureRegState = "@SecureRegState"
        case voiceConfigState = "@VoiceConfigState"
        case micEnabled = "@MicEnabled"
        case airPlayEnabled = "@AirPlayEnabled"
        case idleState = "@IdleState"
        case moreInfo = "@MoreInfo"
        case sslPort = "@SSLPort"
        case hhsslPort = "@HHSSLPort"
        case htSatChanMapSet = "@HTSatChanMapSet"
        case satellite = "Satellite"
        case invisible = "@Invisible"
    }
}

