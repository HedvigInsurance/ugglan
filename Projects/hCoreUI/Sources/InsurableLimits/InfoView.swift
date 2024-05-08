import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct InfoViewHolder: View {
    let title: String
    let description: String
    let type: InfoButtonType
    @State private var disposeBag = DisposeBag()
    public init(title: String, description: String, type: InfoButtonType = .regular) {
        self.title = title
        self.description = description
        self.type = type
    }

    public var body: some View {
        SwiftUI.Button {
            showInfoView()
        } label: {
            Image(uiImage: type.image)
                .foregroundColor(type.color)
        }
    }

    private func showInfoView() {
        let cancelAction = ReferenceAction {}
        let view = InfoView(title: title, description: description)
        let journey = HostingJourney(
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        )

        let calendarJourney = journey.addConfiguration { presenter in
            cancelAction.execute = {
                presenter.dismisser(JourneyError.cancelled)
            }
        }
        let vc = UIApplication.shared.getTopViewController()
        if let vc {
            disposeBag += vc.present(calendarJourney)
        }
    }

    public enum InfoButtonType {
        case regular
        case navigation

        var image: UIImage {
            switch self {
            case .regular:
                hCoreUIAssets.infoIconFilled.image
            case .navigation:
                hCoreUIAssets.infoIcon.image
            }
        }

        @hColorBuilder
        var color: some hColor {
            switch self {
            case .regular:
                hTextColor.secondary
            case .navigation:
                hTextColor.primary
            }
        }
    }
}

extension InfoViewHolder {
    public static func showInfoView(with title: String, and description: String) {
        let disposeBag = DisposeBag()
        let cancelAction = ReferenceAction {}
        let view = InfoView(title: title, description: description)
        let journey = HostingJourney(
            rootView: view,
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        )

        let infoViewJourney = journey.addConfiguration { presenter in
            cancelAction.execute = {
                presenter.dismisser(JourneyError.cancelled)
            }
        }
        let vc = UIApplication.shared.getTopViewController()
        if let vc {
            disposeBag += vc.present(infoViewJourney)
        }
    }
}

public struct InfoView: View {
    let title: String
    let description: String
    let extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)?
    @StateObject private var vm = InfoViewModel()
    public init(
        title: String,
        description: String,
        extraButton: (text: String, style: hButtonConfigurationType, action: () -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.extraButton = extraButton
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 8) {
                    hText(title)
                    hText(description)
                        .foregroundColor(hTextColor.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)
                .padding(.top, 32)
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, 23)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if let button = extraButton {
                    if button.style != .alert {
                        hButton.LargeButton(type: .primary) {
                            button.action()
                        } content: {
                            hText(button.text)
                        }
                    } else {
                        hButton.LargeButton(type: .alert) {
                            button.action()
                        } content: {
                            hText(button.text)
                        }

                    }
                }
                hButton.LargeButton(type: .ghost) {
                    vm.vc?.dismiss(animated: true)
                } content: {
                    hText(L10n.generalCloseButton)
                }
            }
            .padding(.horizontal, 24)
        }
        .introspectViewController { vc in
            vm.vc = vc
        }
    }
}

private class InfoViewModel: ObservableObject {
    weak var vc: UIViewController?
}
