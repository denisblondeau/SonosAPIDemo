//
//  AVTransport.swift
//  SnosAPIDemo
//
//  Created by Denis Blondeau on 2023-02-01.
//

import Foundation

// MARK: - AVTransport
struct AVTransport: Codable {
    
    let avTransportURI, currentPlayMode, currentRecordQualityMode, currentTrackURI, currentTransportActions, currentValidPlayModes, directControlAccountID, directControlClientID, directControlIsSuspended, enqueuedTransportURI, nextAVTransportURI,nextAVTransportURIMetaData, nextTrackURI, playbackStorageMedium, possiblePlaybackStorageMedia, possibleRecordQualityModes, possibleRecordStorageMedia, recordMediumWriteStatus, recordStorageMedium, sleepTimerGeneration, transportPlaySpeed, transportState, transportStatus: String
    
    let currentTrackMetaData: CurrentTrackMetaData
    let nextTrackMetaData: NextTrackMetaData?
    let avTransportURIMetaData: TransportURIMetaData?
    let enqueuedTransportURIMetaData: EnqueuedTransportURIMetaData?
    let currentCrossfadeMode, alarmRunning, snoozeRunning, restartPending: Bool
    let numberOfTracks, currentTrack, currentSection: Int
    let currentTrackDuration, currentMediaDuration: Date
    
    enum CodingKeys: String, CodingKey {
        case transportState = "TransportState"
        case currentPlayMode = "CurrentPlayMode"
        case currentCrossfadeMode = "CurrentCrossfadeMode"
        case numberOfTracks = "NumberOfTracks"
        case currentTrack = "CurrentTrack"
        case currentSection = "CurrentSection"
        case currentTrackURI = "CurrentTrackURI"
        case currentTrackDuration = "CurrentTrackDuration"
        case currentTrackMetaData = "CurrentTrackMetaData"
        case nextTrackURI = "r:NextTrackURI"
        case nextTrackMetaData = "r:NextTrackMetaData"
        case enqueuedTransportURI = "r:EnqueuedTransportURI"
        case enqueuedTransportURIMetaData = "r:EnqueuedTransportURIMetaData"
        case playbackStorageMedium = "PlaybackStorageMedium"
        case avTransportURI = "AVTransportURI"
        case avTransportURIMetaData = "AVTransportURIMetaData"
        case nextAVTransportURI = "NextAVTransportURI"
        case nextAVTransportURIMetaData = "NextAVTransportURIMetaData"
        case currentTransportActions = "CurrentTransportActions"
        case currentValidPlayModes = "r:CurrentValidPlayModes"
        case directControlClientID = "r:DirectControlClientID"
        case directControlIsSuspended = "r:DirectControlIsSuspended"
        case directControlAccountID = "r:DirectControlAccountID"
        case transportStatus = "TransportStatus"
        case sleepTimerGeneration = "r:SleepTimerGeneration"
        case alarmRunning = "r:AlarmRunning"
        case snoozeRunning = "r:SnoozeRunning"
        case restartPending = "r:RestartPending"
        case transportPlaySpeed = "TransportPlaySpeed"
        case currentMediaDuration = "CurrentMediaDuration"
        case recordStorageMedium = "RecordStorageMedium"
        case possiblePlaybackStorageMedia = "PossiblePlaybackStorageMedia"
        case possibleRecordStorageMedia = "PossibleRecordStorageMedia"
        case recordMediumWriteStatus = "RecordMediumWriteStatus"
        case currentRecordQualityMode = "CurrentRecordQualityMode"
        case possibleRecordQualityModes = "PossibleRecordQualityModes"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transportState = try container.decode(String.self, forKey: .transportState)
        currentPlayMode = try container.decode(String.self, forKey: .currentPlayMode)
        var value = try container.decodeIfPresent(String.self, forKey: .currentCrossfadeMode)
        currentCrossfadeMode = (Int(value ?? "0") == 1)
        value = try container.decodeIfPresent(String.self, forKey: .numberOfTracks)
        numberOfTracks = Int(value ?? "") ?? 0
        value = try container.decodeIfPresent(String.self, forKey: .currentTrack)
        currentTrack = Int(value ?? "") ?? 0
        value = try container.decodeIfPresent(String.self, forKey: .currentSection)
        currentSection = Int(value ?? "") ?? 0
        currentTrackURI = try container.decode(String.self, forKey: .currentTrackURI)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:m:ss"
        value = try container.decode(String.self, forKey: .currentTrackDuration)
        var time = dateFormatter.date(from: value ?? "")
        currentTrackDuration = time ?? Date()
        currentTrackMetaData = try container.decode(CurrentTrackMetaData.self, forKey: .currentTrackMetaData)
        nextTrackURI = try container.decode(String.self, forKey: .nextTrackURI)
        if let data = try? container.decodeIfPresent(NextTrackMetaData.self, forKey: .nextTrackMetaData) {
            nextTrackMetaData = data
        } else
        if (try? container.decodeIfPresent(String.self, forKey: .nextTrackMetaData)) != nil {
            nextTrackMetaData = nil
        } else {
            throw DecodingError.typeMismatch(NextTrackMetaData.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for NextTrackMetaData"))
        }
        enqueuedTransportURI = try container.decode(String.self, forKey: .enqueuedTransportURI)
        if let data = try? container.decodeIfPresent(EnqueuedTransportURIMetaData.self, forKey: .enqueuedTransportURIMetaData) {
            enqueuedTransportURIMetaData = data
        } else {
            enqueuedTransportURIMetaData = nil
        }
        value = try? container.decodeIfPresent(String.self, forKey: .playbackStorageMedium)
        playbackStorageMedium = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .avTransportURI)
        avTransportURI = value ?? ""
        if let data = try? container.decodeIfPresent(TransportURIMetaData.self, forKey: .avTransportURIMetaData) {
            avTransportURIMetaData = data
        } else {
            avTransportURIMetaData = nil
        }
        value = try container.decodeIfPresent(String.self, forKey: .nextAVTransportURI)
        nextAVTransportURI = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .nextAVTransportURIMetaData)
        nextAVTransportURIMetaData = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentTransportActions)
        currentTransportActions = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentValidPlayModes)
        currentValidPlayModes = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .directControlClientID)
        directControlClientID = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .directControlIsSuspended)
        directControlIsSuspended = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .directControlAccountID)
        directControlAccountID = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .transportStatus)
        transportStatus = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .sleepTimerGeneration)
        sleepTimerGeneration = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .alarmRunning)
        alarmRunning = (Int(value ?? "0") == 1)
        value = try container.decodeIfPresent(String.self, forKey: .snoozeRunning)
        snoozeRunning = (Int(value ?? "0") == 1)
        value = try container.decodeIfPresent(String.self, forKey: .restartPending)
        restartPending = (Int(value ?? "0") == 1)
        value =  try container.decodeIfPresent(String.self, forKey: .transportPlaySpeed)
        transportPlaySpeed = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentMediaDuration)
        time = dateFormatter.date(from: value ?? "")
        currentMediaDuration = time ?? Date()
        value =  try container.decodeIfPresent(String.self, forKey: .recordStorageMedium)
        recordStorageMedium = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .possiblePlaybackStorageMedia)
        possiblePlaybackStorageMedia = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .possibleRecordStorageMedia)
        possibleRecordStorageMedia = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .recordMediumWriteStatus)
        recordMediumWriteStatus = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentRecordQualityMode)
        currentRecordQualityMode = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .possibleRecordQualityModes)
        possibleRecordQualityModes = value ?? ""
    }
}

// MARK: - CurrentTrackMetaData
struct CurrentTrackMetaData: Codable {
    let res, streamContent, radioShowMd, streamInfo: String
    let albumArtURI, title, class_, creator: String
    let album: String
    
    enum CodingKeys: String, CodingKey {
        case res
        case streamContent = "r:streamContent"
        case radioShowMd = "r:radioShowMd"
        case streamInfo = "r:streamInfo"
        case albumArtURI = "upnp:albumArtURI"
        case title = "dc:title"
        case class_ = "upnp:class"
        case creator = "dc:creator"
        case album = "upnp:album"
    }
}

// MARK: - EnqueuedTransportURIMetaData
struct EnqueuedTransportURIMetaData: Codable {
    let title, class_, desc: String
    let albumArtURI: String
    
    enum CodingKeys: String, CodingKey {
        case title = "dc:title"
        case class_ = "upnp:class"
        case desc
        case albumArtURI = "upnp:albumArtURI"
    }
}

// MARK: - NextTrackMetaData
struct NextTrackMetaData: Codable {
    let res, albumArtURI, title, class_: String
    let creator, album: String
    
    enum CodingKeys: String, CodingKey {
        case res
        case albumArtURI = "upnp:albumArtURI"
        case title = "dc:title"
        case class_ = "upnp:class"
        case creator = "dc:creator"
        case album = "upnp:album"
    }
}

// MARK: - TransportURIMetaData
struct TransportURIMetaData: Codable {
    let title, class_: String
    let albumArtURI: String
    let desc: String
    
    enum CodingKeys: String, CodingKey {
        case title = "dc:title"
        case class_ = "upnp:class"
        case albumArtURI = "upnp:albumArtURI"
        case desc
    }
}
