//
//  hDesignSystem.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2021-08-05.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCore
import Flow
import hCoreUI
import Combine

struct MainForm: View {
    let rows = [
        "Row one",
        "Row two",
        "Row three",
        "Row four"
    ]
    
    var body: some View {
        Group {
            hSection(header: hText("Buttons")) {
                hRow {
                    VStack(alignment: .leading) {
                        hText("Large Button - Filled", style: .headline)
                            .foregroundColor(hLabelColor.secondary)
                            .padding(.bottom, 10)
                        VStack {
                            hButton.LargeButtonFilled {
                                
                            } content: {
                                hText("Enabled")
                            }
                            hButton.LargeButtonFilled {
                                
                            } content: {
                                hText("Disabled")
                            }.disabled(true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                hRow {
                    VStack(alignment: .leading) {
                        hText("Large Button - Outlined", style: .headline)
                            .foregroundColor(hLabelColor.secondary)
                            .padding(.bottom, 10)
                        VStack {
                            hButton.LargeButtonOutlined {
                                
                            } content: {
                                hText("Enabled")
                            }
                            hButton.LargeButtonOutlined {
                                
                            } content: {
                                hText("Disabled")
                            }.disabled(true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                hRow {
                    VStack(alignment: .leading) {
                        hText("Large Button - Text", style: .headline)
                            .foregroundColor(hLabelColor.secondary)
                            .padding(.bottom, 10)
                        VStack {
                            hButton.LargeButtonText {
                                
                            } content: {
                                hText("Enabled")
                            }
                            hButton.LargeButtonText {
                                
                            } content: {
                                hText("Disabled")
                            }.disabled(true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            hSection(rows, id: \.self) { row in
                hRow {
                    hText(row, style: .headline)
                }.onTap {}
            }.withHeader {
                hText("Rows")
            }.withFooter {
                hText("A footer")
            }
        }
    }
}

struct hDesignSystem: PresentableView {
    typealias Result = Disposable
    
    @State var darkMode: Bool = false
    
    var result: Disposable {
        DisposeBag()
    }
    
    var body: some View {
        hForm {
            hSection(header: hText("Settings")) {
                hRow {
                    Toggle("Dark mode", isOn: $darkMode)
                }
            }
            MainForm()
        }
        .environment(\.colorScheme, darkMode ? .dark : .light)
        .presentableTitle("hDesignSystem")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainForm()
    }
}
