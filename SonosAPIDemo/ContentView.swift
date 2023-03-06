//
//  ContentView.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-03-06.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var model = SonosModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
