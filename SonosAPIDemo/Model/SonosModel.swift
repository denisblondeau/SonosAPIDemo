//
//  SonosModel.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import Combine
//import Foundation

/// Sonos API Model.
final class SonosModel: ObservableObject {
    
    private var sonosDevices = [SonosDevice]()
    private var ssdpSubscription: AnyCancellable?
    
    init() {
        
        getDevices()
    }
    
    
    /// Retrieve Sonos devices on the local network.
    private func getDevices() {
        let ssdp = SSDPSession()
        
        ssdpSubscription = ssdp.onDeviceFound.sink{ completion in
            
            self.ssdpSubscription?.cancel()
            
            switch completion {
                
            case .failure(let error):
                fatalError(error.description)
                
            case .finished:
                break
               // self.retrieveHouseholdCoordinators()
               
                
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
    
}
