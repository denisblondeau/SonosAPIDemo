//
//  SonosAPIDemoApp.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import SwiftUI

@main
struct SonosAPIDemoApp: App {
    var body: some Scene {
        Window("Sonos API Demo", id: "main") {
            ContentView()
                .frame(
                    minWidth: 800, maxWidth: 1400,
                    minHeight: 400, maxHeight: 800)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .pasteboard) { }
        }
        .windowResizability(.contentSize)
    }
}
