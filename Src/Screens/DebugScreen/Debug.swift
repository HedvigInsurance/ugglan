//
//  Debug.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-07.
//

import Foundation
import SwiftUI
import Apollo

@available(iOS 13, *)
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
    @State private var authorizationToken: String = ""
    @State private var showFaultyEndpointAlert = false

    static var environmentOptionFromTarget: EnvironmentOption {
        let targetEnvironment = ApplicationState.getTargetEnvironment()

        switch targetEnvironment {
        case .production:
            return .production
        case .staging:
            return .staging
        case .custom:
            return .custom
        }
    }

    init() {
        switch ApplicationState.getTargetEnvironment() {
        case let .custom(endpointURL, wsEndpointURL, assetsEndpointURL):
            _endpointURL = State(initialValue: endpointURL.absoluteString)
            _wsEndpointURL = State(initialValue: wsEndpointURL.absoluteString)
            _assetsEndpointURL = State(initialValue: assetsEndpointURL.absoluteString)
        default:
            break
        }

        _pickedEnvironment = State(initialValue: Debug.environmentOptionFromTarget)
        _authorizationToken = State(initialValue: ApolloClient.retreiveToken()?.token ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Which environment do you want to use?")
                    Picker(selection: $pickedEnvironment, label: Text("Which environment do you want to use?")) {
                        ForEach(0 ..< EnvironmentOption.allCases.count) { index in
                            Text(EnvironmentOption.allCases[index].rawValue).tag(EnvironmentOption.allCases[index])
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                if pickedEnvironment == .custom {
                    Section {
                        SwiftUI.TextField("Endpoint URL", text: $endpointURL)
                        SwiftUI.TextField("WebSocket Endpoint URL", text: $wsEndpointURL)
                        SwiftUI.TextField("Assets Endpoint URL", text: $assetsEndpointURL)
                    }
                }
                Section {
                    SwiftUI.TextField("Authorization token", text: $authorizationToken)
                }
                Section {
                    SwiftUI.Button("Logout", action: {
                        ApplicationState.preserveState(.marketPicker)
                        UIApplication.shared.appDelegate.logout()
                    })
                }
            }
            .alert(isPresented: $showFaultyEndpointAlert) {
                Alert(title: Text("Endpoint config is faulty"), dismissButton: .default(Text("OK!")))
            }
            .navigationBarItems(trailing: SwiftUI.Button("Update", action: {
                switch self.pickedEnvironment {
                case .staging:
                    ApplicationState.setTargetEnvironment(.staging)
                case .production:
                    ApplicationState.setTargetEnvironment(.production)
                case .custom:
                    guard let endpointURL = URL(string: self.endpointURL) else {
                        self.showFaultyEndpointAlert = true
                        return
                    }
                    guard let wsEndpointURL = URL(string: self.wsEndpointURL) else {
                        self.showFaultyEndpointAlert = true
                        return
                    }
                    guard let assetsEndpointURL = URL(string: self.assetsEndpointURL) else {
                        self.showFaultyEndpointAlert = true
                        return
                    }

                    ApplicationState.setTargetEnvironment(.custom(
                        endpointURL: endpointURL,
                        wsEndpointURL: wsEndpointURL,
                        assetsEndpointURL: assetsEndpointURL
                    ))
                }
                
                ApplicationState.preserveState(.loggedIn)
                ApolloClient.saveToken(token: self.authorizationToken)
            }))
            .navigationBarTitle(Text("Wizard 🧙‍♂️"), displayMode: .large)
        }
    }
}
