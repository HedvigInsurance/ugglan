import Combine
import Flow
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ButtonShowcase<Content: View>: View {
    let title: String
    
    @ViewBuilder
    let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            hText(title, style: .headline)
                .foregroundColor(hLabelColor.secondary)
                .padding(.bottom, 10)
            VStack(spacing: 10) {
                content
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FormShowcase: View {
	let rows = [
		"Row one",
		"Row two",
		"Row three",
		"Row four",
	]

	var body: some View {
		Group {
			hSection(header: hText("Buttons")) {
				hRow {
                    ButtonShowcase(title: "Large Button - Filled") {
                        hButton.LargeButtonFilled {

                        } content: {
                            hText("Enabled")
                        }
                        hButton.LargeButtonFilled {

                        } content: {
                            hText("Disabled")
                        }
                        .disabled(true)
                    }
				}
				hRow {
                    ButtonShowcase(title: "Large Button - Outlined") {
                        hButton.LargeButtonOutlined {

                        } content: {
                            hText("Enabled")
                        }
                        hButton.LargeButtonOutlined {

                        } content: {
                            hText("Disabled")
                        }
                        .disabled(true)
                    }
				}
				hRow {
                    ButtonShowcase(title: "Large Button - Text") {
                        hButton.LargeButtonText {

                        } content: {
                            hText("Enabled")
                        }
                        hButton.LargeButtonText {

                        } content: {
                            hText("Disabled")
                        }
                        .disabled(true)
                    }
				}
			}

			hSection(rows, id: \.self) { row in
				hRow {
					hText(row, style: .headline)
				}
				.onTap {}
			}
			.withHeader {
				hText("Rows")
			}
			.withFooter {
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
            FormShowcase()
		}
		.environment(\.colorScheme, darkMode ? .dark : .light)
		.presentableTitle("hDesignSystem")
	}
}
