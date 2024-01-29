//
//  SonosModel.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import AppKit
import Combine
import SonosAPI

/// Sonos API Model.
final class SonosModel: ObservableObject {
    
    struct CurrentTrack {
        let title: String
        let duration: Date?
        let artist: String
        let album: String
    }
    
    struct SonosGroup: Identifiable {
        var id: String
        let coordinatorURL: URL
        let name: String
    }
    
    @Published private(set) var groups = [SonosGroup]()
    @Published private(set) var albumArtURL: URL?
    @Published private(set) var currentTrack: CurrentTrack?
    @Published private(set) var currentTrackPosition: Date?
    @Published private(set) var groupVolume = 0
    
    
    // MARK: - Set the callback URL to the URL of the computer running this demo. Default port is 1337 - or use another available port on your computer.
    private var callbackURL = URL(string: "http://192.168.2.213:1337")
    private var eventSession: SOAPEventSession
    private var selectedGroup: SonosGroup!
    private var soapEventSubscription: AnyCancellable?
    private var sonosDevices = [SonosDevice]()
    private var soapActionSubscription: AnyCancellable?
    private var ssdpSubscription: AnyCancellable?
    
    init() {
        guard let callbackURL else {
            fatalError("Error - Callback URL is invalid.")
        }
        
        // 1) Create event Session handler.
        eventSession = SOAPEventSession(callbackURL: callbackURL)
        
        // Clean-up on app termination.
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            self.ssdpSubscription?.cancel()
            self.soapActionSubscription?.cancel()
            self.soapEventSubscription?.cancel()
        }
        setSubscribers()
        getDevices()
    }
    
    /// Retrieve Sonos devices on the local network.
    private func getDevices() {
        let ssdp = SSDPSession()
        
        ssdpSubscription = ssdp.onDeviceFound.sink { completion in
            
            self.ssdpSubscription?.cancel()
            
            switch completion {
                
            case .failure(let error):
                print(error.description)
                
            case .finished:
                // Once we have the Sonos devices, find out the groups (zones) coordinators.
                self.retrieveHouseholdCoordinators()
            }
            
        } receiveValue: { record in
            self.sonosDevices.append(record)
        }
        
        do {
            try ssdp.run()
        } catch {
            fatalError("Cannot run SSDP session: \(error.localizedDescription)")
        }
    }
    
    /// Set up events handler.
    private func setSubscribers() {
        
        // 2) Set up the event handler.
        soapEventSubscription = eventSession.onDataReceived.sink { completion in
            switch completion {
                
            case .finished:
                break
            case .failure(let error):
                fatalError("Failure: \(error.description)")
            }
        } receiveValue: { jsonData in
            
            switch jsonData.sonosService {
                
            case .avTransport:
                
                parseJSONToObject(json: jsonData.json) { (avTransport: AVTransport?) in
                    guard let avTransport else { return }
                    if let albumURL = URL(string: self.selectedGroup.coordinatorURL.description + (avTransport.currentTrackMetaData?.albumArtURI ?? "")) {
                        self.albumArtURL = albumURL
                        
                    } else {
                        self.albumArtURL = nil
                    }
                    
                    self.currentTrack = CurrentTrack(title: avTransport.currentTrackMetaData?.title ?? "", duration: avTransport.currentTrackDuration, artist: avTransport.currentTrackMetaData?.creator ?? "", album: avTransport.currentTrackMetaData?.album ?? "")
                }
                
            case .groupRenderingControl:
                
                parseJSONToObject(json: jsonData.json) { (groupRenderingControl: GroupRenderingControl?) in
                    guard let groupRenderingControl else { return }
                    
                    self.groupVolume = groupRenderingControl.groupVolume
                }
                
            default:
                break
            }
        }
    }
    
    /// Generate zone/household groups with their  corrdinator id.
    private func retrieveHouseholdCoordinators() {
        
        guard sonosDevices.count > 0 else { return }
        guard let url = sonosDevices[0].hostURL else { return }
        
        let session = SOAPActionSession(service: .zoneGroupTopology(action: .getZoneGroupState, url: url))
        
        soapActionSubscription = session.onDataReceived.sink { completion in
            
            self.soapActionSubscription?.cancel()
            
            switch completion {
                
            case .finished:
                break
                
            case .failure(let error):
                fatalError(error.description)
            }
            
        } receiveValue: { json in
            
            parseJSONToObject(json: json) { (groupData: ZoneGroupTopology?) in
                
                guard let groupData else { return }
                
                for zoneGroup in groupData.zoneGroupState.zoneGroups.zoneGroup {
                    for zoneGroupMember in zoneGroup.zoneGroupMember {
                        
                        if zoneGroupMember.uuid == zoneGroup.coordinator {
                            var name: String
                            if zoneGroup.zoneGroupMember.count == 1 {
                                name = zoneGroupMember.zoneName
                            } else {
                                name = "\(zoneGroupMember.zoneName) + \(zoneGroup.zoneGroupMember.count - 1)"
                            }
                            
                            let  group = SonosGroup(id: zoneGroupMember.uuid, coordinatorURL: zoneGroupMember.hostURL!, name: name)
                            DispatchQueue.main.async {
                                self.groups.append(group)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.groups.sort { $0.name < $1.name }
                }
            }
        }
        session.run()
    }
    
    ///  Identify the selected Sonos group.
    /// - Parameter id: Group ID
    func groupSelected(id: String) {
        if let group  = groups.first(where: { $0.id == id }) {
            
            selectedGroup = group
            process()
            
        } else {
            print("Invalid group id")
        }
    }
    
    /// Process various Sonos actions et events.
    private func process() {
        
        // An action is fired only once - it retrieves requested information from the Sonos Coordinator. In this case, get the current track position.
        let session = SOAPActionSession(service: .avTransport(action: .getPositionInfo, url: selectedGroup.coordinatorURL))
        
        soapActionSubscription = session.onDataReceived.sink { completion in
            
            self.soapActionSubscription?.cancel()
            
            switch completion {
                
            case .finished:
                break
            case .failure(let error):
                fatalError("\nFAILURE: \(error.description)\n")
            }
            
        } receiveValue: { json in
            
            parseJSONToObject(json: json) { (getPositionInfo: GetPositionInfo?) in
                
                if let getPositionInfo {
                    DispatchQueue.main.async {
                        self.currentTrackPosition = getPositionInfo.relTime
                    }
                }
            }
        }
        
        session.run()
        
        // 3) Subscribe to some Sonos events from the current Sonos Coordinator so we can be notified when there is an update - e.g. track, volume change. Note that subscribing to events also unsubscribe from previously subscribed events.
        Task {
            await  eventSession.subscribeToEvents(events: [.subscription(service: .avTransport), .subscription(service: .groupRenderingControl)], hostURL: selectedGroup.coordinatorURL)
        }

    }
}
