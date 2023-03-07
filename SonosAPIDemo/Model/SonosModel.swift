//
//  SonosModel.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import AppKit
import Combine
import Foundation

/// Sonos API Model.
final class SonosModel: ObservableObject {
    
    struct SonosGroup: Identifiable {
        var id: String
        let coordinatorURL: URL
        let name: String
    }
    
    @Published private(set) var groups = [SonosGroup]()
    
    private var sonosDevices = [SonosDevice]()
    private var soapActionSubscription: AnyCancellable?
    private var ssdpSubscription: AnyCancellable?
    
    init() {
        
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            //            self.eventSession?.cancel()
            self.ssdpSubscription?.cancel()
            self.soapActionSubscription?.cancel()
            //            self.soapEventSubscription?.cancel()
        }
        
        getDevices()
    }
    
    /// Retrieve Sonos devices on the local network.
    private func getDevices() {
        let ssdp = SSDPSession()
        
        ssdpSubscription = ssdp.onDeviceFound.sink { completion in
            
            self.ssdpSubscription?.cancel()
            
            switch completion {
                
            case .failure(let error):
                fatalError(error.description)
                
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
    
}
