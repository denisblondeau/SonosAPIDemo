//
//  GetPositionInfo.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-02-08.
//

import Foundation

// MARK: - GetPositionInfo
struct GetPositionInfo: Codable {
  let absCount, relCount, track: Int
  let relTime, trackDuration: Date
  let trackMetaData: TrackMetaData?
  let trackURI, absTime: String
  
  enum CodingKeys: String, CodingKey {
    case track = "Track"
    case trackDuration = "TrackDuration"
    case trackMetaData = "TrackMetaData"
    case trackURI = "TrackURI"
    case relTime = "RelTime"
    case absTime = "AbsTime"
    case relCount = "RelCount"
    case absCount = "AbsCount"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var value = try container.decode(String.self, forKey: .track)
    track = Int(value) ?? 0
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "H:m:ss"
    var dateValue = try container.decodeIfPresent(String.self, forKey: .trackDuration)
    var time = dateFormatter.date(from: dateValue ?? "")
    trackDuration = time ?? Date()
    trackMetaData  = try? container.decodeIfPresent(TrackMetaData.self, forKey: .trackMetaData)
    trackURI = try container.decode(String.self, forKey: .trackURI)
    dateValue = try container.decodeIfPresent(String.self, forKey: .relTime)
    time = dateFormatter.date(from: dateValue ?? "")
    relTime = time ?? Date()
    absTime = try container.decode(String.self, forKey: .absTime)
    value = try container.decode(String.self, forKey: .relCount)
    relCount = Int(value) ?? 0
    value = try container.decode(String.self, forKey: .absCount)
    absCount = Int(value) ?? 0
  }
}

// MARK: - TrackMetaData
struct TrackMetaData: Codable {
  let res, streamContent, albumArtURI, title: String
  let class_, creator, album: String
  
  enum CodingKeys: String, CodingKey {
    case res
    case streamContent = "r:streamContent"
    case albumArtURI = "upnp:albumArtURI"
    case title = "dc:title"
    case class_ = "upnp:class"
    case creator = "dc:creator"
    case album = "upnp:album"
  }
}
