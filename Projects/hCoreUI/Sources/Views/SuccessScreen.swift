import Presentation
import SwiftUI
import hCore

public struct SuccessScreen<T>: View where T: View {
    let title: String
    let subTitle: String?
    let withButtons: Bool
    let customBottomSuccessView: T?
    let successViewButtonAction: (() -> Void)?

    public init(
        title: String
    ) {
        self.title = title
        self.withButtons = false
        self.subTitle = nil
        self.customBottomSuccessView = nil
        self.successViewButtonAction = nil
    }

    public init(
        successViewTitle: String,
        successViewBody: String,
        customBottomSuccessView: T? = nil,
        successViewButtonAction: @escaping () -> Void
    ) {
        self.withButtons = true
        self.title = successViewTitle
        self.subTitle = successViewBody
        self.customBottomSuccessView = customBottomSuccessView
        self.successViewButtonAction = successViewButtonAction
    }

    public var body: some View {
        if withButtons {
            ZStack(alignment: .bottom) {
                BackgroundView().ignoresSafeArea()
                VStack {
                    Spacer()
                    Spacer()
                    VStack(spacing: 16) {
                        Image(uiImage: hCoreUIAssets.tick.image)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hSignalColor.greenElement)
                        hSection {
                            VStack(spacing: 0) {
                                hText(title)
                                hText(subTitle ?? "")
                                    .foregroundColor(hTextColor.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }
                if customBottomSuccessView != nil {
                    customBottomSuccessView
                } else {
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButton(type: .ghost) {
                                successViewButtonAction?()
                            } content: {
                                hText(L10n.generalCloseButton)
                            }
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        } else {
            hSection {
                VStack(spacing: 20) {
                    Spacer()
                    Image(uiImage: hCoreUIAssets.tick.image)
                        .resizable()
                        .foregroundColor(hSignalColor.greenElement)
                        .frame(width: 24, height: 24)
                    hText(title)
                    Spacer()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SuccessScreen<EmptyView>(title: "SUCCESS")
    }
}

extension SuccessScreen {
    public static func journey(with title: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: SuccessScreen(title: title),
            options: [.prefersNavigationBarHidden(true)]
        )
        .hidesBackButton
    }
}
