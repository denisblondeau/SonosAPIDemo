//
//  ContentView.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import SwiftUI

struct ContentView: View {
    
    @State private var groupId: String?
    @StateObject private var model = SonosModel()
    
    private let timeFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateFormat = "mm:ss"
        return result
    }()
  
    var body: some View {
        
        NavigationSplitView {
            
            Text("Sonos Groups")
                .font(.title)
                .padding()
            List(model.groups, selection: $groupId) { group in
                Text(group.name)
            }
            .frame(width: 200)
            
            
            
        } detail: {
            
            VStack {
                
//                AsyncImage(url: model.albumArtURL, transaction: Transaction(animation: .easeInOut(duration: 2.0))) { phase in
//
//
//                    switch phase {
//                    case .success(let image):
//                        image.resizable()
//                    case .failure(_):
//                        Image(systemName: "questionmark")
//                            .symbolVariant(.circle)
//                            .font(.largeTitle)
//                    default:
//                        Image(systemName: "music.note")
//                            .resizable()
//
//                    }
//
//
//                }
//                .frame(width: 600, height: 600)
//                .padding()
                
                Spacer()
                
                
//                    if let currentTrack = model.currentTrack {
//                        VStack {
//                            Text("Title: \(currentTrack.title)")
//                            Text("Artist: \(currentTrack.artist)")
//                            Text("Album: \(currentTrack.album)")
//                            if let date = currentTrack.duration {
//
//                                Text("Track duration: \(timeFormatter.string(from: date))")
//                            }
//                            if let date = model.currentTrackPosition {
//                                Text("Track position: \(timeFormatter.string(from: date))")
//                            }
//
//                        }
//
//                        .animation(.easeInOut(duration: 2.0), value: currentTrack.title)
//                    } else {
//                        Text("Please select a Sonos Group")
//
//                    }
               
               
                Spacer()
                
            }
            
        }
        .navigationTitle("Sonos API Demo")
        .onChange(of: groupId) { id in
            if let id {
              //  model.groupSelected(id: id)
            }
            
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
