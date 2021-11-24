import AppClip
import SwiftUI

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
