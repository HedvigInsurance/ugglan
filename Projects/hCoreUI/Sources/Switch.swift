//
//  Switch.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2022-02-08.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public struct Switch : UIViewRepresentable {
    @Binding var on: Bool
    
    public init(on: Binding<Bool>) {
        self._on = on
    }
    
      public func makeUIView(context: Context) -> UISwitch {
        let view = UISwitch()
          
          view.addTarget(context.coordinator, action: #selector(Coordinator.changed), for: .valueChanged)
          
          return view
      }
    
    public class Coordinator {
        @Binding var on: Bool
        
        init(_ on: Binding<Bool>) {
            self._on = on
        }
        
        @objc func changed(sender: UISwitch) {
            self.on = sender.isOn
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator($on)
    }

  public func updateUIView(_ uiView: UISwitch, context: Context) {
      uiView.onTintColor = .brand(.link)
  }
}
