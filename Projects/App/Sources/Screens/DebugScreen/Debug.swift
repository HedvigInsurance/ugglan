import Apollo
import Flow
import Foundation
import Market
import SwiftUI
import hCore
import hGraphQL

struct Debug: View {
    enum EnvironmentOption: String, CaseIterable {
        case production = "Production"
        case staging = "Staging"
        case custom = "Custom"
    }

    @State private var pickedEnvironment: EnvironmentOption
    @State private var endpointURL: String = ""
    @State private var wsEndpointURL: String = ""
    @State private var assetsEndpointURL: String = ""
    @State private var webBaseURL: String = ""
    @State private var showFaultyEndpointAlert = false

    static var environmentOptionFromTarget: EnvironmentOption {
        let targetEnvironment = Environment.current

        switch targetEnvironment {
        case .production: return .production
        case .staging: return .staging
        case .custom: return .custom
        }
    }

    init() {
        _endpointURL = State(initialValue: Environment.current.giraffeEndpointURL.absoluteString)
        _wsEndpointURL = State(initialValue: Environment.current.giraffeWSEndpointURL.absoluteString)
        _assetsEndpointURL = State(initialValue: Environment.current.assetsEndpointURL.absoluteString)
        _webBaseURL = State(initialValue: Environment.current.webBaseURL.absoluteString)
        _pickedEnvironment = State(initialValue: Debug.environmentOptionFromTarget)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Color.clear.frame(height: 100)
                    Text("Which environment do you want to use?")
                    Picker(
                        selection: $pickedEnvironment,
                        label: Text("Which environment do you want to use?")
                    ) {
                        ForEach(0..<EnvironmentOption.allCases.count, id: \.self) { index in
                            Text(EnvironmentOption.allCases[index].rawValue)
                                .tag(EnvironmentOption.allCases[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                if pickedEnvironment == .custom {
                    Section {
                        SwiftUI.TextField("Endpoint URL", text: $endpointURL)
                        SwiftUI.TextField("WebSocket Endpoint URL", text: $wsEndpointURL)
                        SwiftUI.TextField("Assets Endpoint URL", text: $assetsEndpointURL)
                        SwiftUI.TextField("Web Base URL", text: $webBaseURL)
                    }
                }
                Section {
                    SwiftUI.Button(
                        "Reset Tooltips",
                        action: {
                            let userDefaultsDict = UserDefaults.standard
                                .dictionaryRepresentation()

                            userDefaultsDict.filter { key, _ in key.contains("tooltip") }
                                .forEach { key, _ in
                                    UserDefaults.standard.setValue(nil, forKey: key)
                                }
                        }
                    )
                }
                Section {
                    Text("Available locales")
                    ForceAvailableLocales()
                }
                Section {
                    SwiftUI.Button(
                        "Go to market picker",
                        action: {
                            ApplicationState.preserveState(.marketPicker)
                            UIApplication.shared.appDelegate.bag += UIApplication.shared
                                .appDelegate.window.present(AppJourney.main)
                        }
                    )
                }
                Section {
                    SwiftUI.Button(
                        "Logout",
                        action: {
                            ApplicationState.preserveState(.marketPicker)
                            UIApplication.shared.appDelegate.logout()
                        }
                    )
                }
            }
            .alert(isPresented: $showFaultyEndpointAlert) {
                Alert(title: Text("Endpoint config is faulty"), dismissButton: .default(Text("OK!")))
            }
            .navigationBarItems(
                trailing: SwiftUI.Button(
                    "Update",
                    action: {
                        switch self.pickedEnvironment {
                        case .staging: Environment.setCurrent(.staging)
                        case .production: Environment.setCurrent(.production)
                        case .custom:
                            guard let endpointURL = URL(string: self.endpointURL) else {
                                self.showFaultyEndpointAlert = true
                                return
                            }
                            guard let wsEndpointURL = URL(string: self.wsEndpointURL) else {
                                self.showFaultyEndpointAlert = true
                                return
                            }
                            guard
                                let assetsEndpointURL = URL(
                                    string: self.assetsEndpointURL
                                )
                            else {
                                self.showFaultyEndpointAlert = true
                                return
                            }
                            guard let webBaseURL = URL(string: self.webBaseURL) else {
                                self.showFaultyEndpointAlert = true
                                return
                            }

                            Environment.setCurrent(
                                .custom(
                                    endpointURL: endpointURL,
                                    wsEndpointURL: wsEndpointURL,
                                    assetsEndpointURL: assetsEndpointURL,
                                    webBaseURL: webBaseURL
                                )
                            )
                        }

                        ApplicationState.preserveState(.loggedIn)
                    }
                )
            )
            .navigationBarTitle(Text("Wizard 🧙‍♂️"), displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
