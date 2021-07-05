//
//  SidebarLoggedIn.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-05.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import Presentation
import Contracts
import Flow
import Forever
import Home
import hCore
import hCoreUI

@available(iOS 14.0, *)
struct Sidebar: View {
    @State var selectedTag: String? = nil
    
    let home = Home()
    let contracts = Contracts()
    let keyGear = KeyGearOverview()
    let forever = Forever(service: ForeverServiceGraphQL())
    let profile = Profile()
    
    var body: some View {
        List {
            TabableView(presentable: home, contextGradientOption: .home, selectedTag: $selectedTag)
            TabableView(presentable: contracts, contextGradientOption: .none, selectedTag: $selectedTag)
            TabableView(presentable: keyGear, contextGradientOption: .none, selectedTag: $selectedTag)
            TabableView(presentable: forever, contextGradientOption: .forever, selectedTag: $selectedTag)
            TabableView(presentable: profile, contextGradientOption: .profile, selectedTag: $selectedTag)
        }.listStyle(SidebarListStyle()).navigationTitle("Hedvig")
    }
}

@available(iOS 14.0, *)
struct SidebarLoggedIn: View {
    var body: some View {
        NavigationView {
            Sidebar()
            EmptyView()
        }
    }
}
