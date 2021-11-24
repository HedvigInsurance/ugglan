//
//  Main.swift
//  Ugglan-AppClip
//
//  Created by Sam Pettersson on 2021-11-24.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import SwiftUI
import AppClip

struct ContentView: View {
    var body: some View {
        Text("Hello Appclips!")
            .padding()
    }
}

@main
struct MainAppClip: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
