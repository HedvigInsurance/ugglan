import SwiftUI
import hCoreUI

struct ChangeAppIconView: View {
    @ObservedObject var vm = ChangeAppIconViewModel()

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(AppIcon.allCases, id: \.self) { icon in
                        hRadioField<AppIcon>(
                            id: icon,
                            leftView: {
                                HStack(spacing: .padding16) {
                                    icon.previewImage
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    hText(icon.iconName, style: .heading2)
                                }
                                .asAnyView
                            },
                            selected: $vm.selectedAppIcon
                        )
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: "Apply"),
                    {
                        vm.updateAppIcon()
                    }
                )
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
    }
}

@MainActor
enum AppIcon: String, CaseIterable {
    case primary = "AppIcon"
    case secondary = "AppIcon2"

    var iconValue: String? {
        switch self {
        case .primary:
            /// `nil` is used to reset the app icon back to its primary icon.
            return nil
        default:
            return rawValue
        }
    }

    var iconName: String {
        switch self {
        case .primary:
            return "Ugglan"
        default:
            return "Hedvig"
        }
    }

    var previewImage: Image {
        switch self {
        case .primary:
            return hCoreUIAssets.flagSE.view
        case .secondary:
            return hCoreUIAssets.flagUK.view
        }
    }
}

@MainActor
final class ChangeAppIconViewModel: ObservableObject {
    @Published var selectedAppIcon: AppIcon?

    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    func updateAppIcon() {
        let previousAppIcon = selectedAppIcon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != selectedAppIcon?.iconValue else {
                /// No need to update since we're already using this icon.
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(selectedAppIcon?.iconValue)
            } catch {
                /// We're only logging the error here and not actively handling the app icon failure
                /// since it's very unlikely to fail.
                print("Updating icon to \(String(describing: selectedAppIcon?.iconValue)) failed.")

                /// Restore previous app icon
                selectedAppIcon = previousAppIcon
            }
        }
    }
}

#Preview {
    ChangeAppIconView()
}
