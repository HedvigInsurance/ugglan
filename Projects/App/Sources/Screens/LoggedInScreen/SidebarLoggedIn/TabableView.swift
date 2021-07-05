//
//  TabableView.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-05.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import Flow
import UIKit
import Presentation
import hCore
import hCoreUI

struct TabableView<P: Presentable>: View where P.Matter: UIViewController, P.Result == Disposable, P: Tabable  {
    let presentable: P
    let contextGradientOption: ContextGradient.Option
    
    var title: String {
        self.presentable.tabBarItem().title ?? ""
    }
    
    var selfTag: String {
        title
    }
    
    @Binding var selectedTag: String?
    
    var body: some View {
        NavigationLink(
            destination: PresentableView(presentable: presentable).navigationTitle(title),
            tag: selfTag,
            selection: $selectedTag,
            label: {
                Spacer().frame(width: 10, height: 0, alignment: .center)
                if selectedTag == selfTag, let image = presentable.tabBarItem().selectedImage {
                    Image(uiImage: image).frame(width: 20, height: 20, alignment: .center)
                } else if let image = presentable.tabBarItem().image {
                    Image(uiImage: image).frame(width: 20, height: 20, alignment: .center)
                }
                Spacer().frame(width: 20, height: 0, alignment: .center)
                hText(title)
            }
        ).onChange(of: selectedTag, perform: { value in
            if selectedTag == selfTag {
                ContextGradient.currentOption = contextGradientOption
            }
        })
    }
}
