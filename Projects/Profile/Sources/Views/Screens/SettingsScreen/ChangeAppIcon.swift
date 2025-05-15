import SwiftUI
import hCoreUI

struct ChangeAppIconView: View {
    @ObservedObject var vm: ChangeAppIconViewModel
    let onCancel: () -> Void

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
                                        .frame(width: 40, height: 40)
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
                        vm.updateAppIcon(onCancel: onCancel)
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
    case green = "AppIconGreen"
    case blue = "AppIconBlue"
    case dog = "AppIconDog"
    case home = "AppIconHome"
    case car = "AppIconCar"

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
            return "Default"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .dog:
            return "Dog"
        case .home:
            return "Home"
        case .car:
            return "Car"
        }
    }

    var previewImage: Image {
        switch self {
        case .primary:
            return hCoreUIAssets.hedvigAppIcon.view
        case .green:
            return hCoreUIAssets.greenAppIcon.view
        case .blue:
            return hCoreUIAssets.blueAppIcon.view
        case .dog:
            return hCoreUIAssets.appIconDog.view
        case .home:
            return hCoreUIAssets.appIconHome.view
        case .car:
            return hCoreUIAssets.appIconHome.view
        }
    }
}

@MainActor
public final class ChangeAppIconViewModel: ObservableObject, @preconcurrency Equatable, Identifiable {
    public static func == (lhs: ChangeAppIconViewModel, rhs: ChangeAppIconViewModel) -> Bool {
        return lhs.selectedAppIcon?.rawValue == rhs.selectedAppIcon?.rawValue
    }

    @Published var selectedAppIcon: AppIcon?

    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    func updateAppIcon(onCancel: @escaping () -> Void) {
        let previousAppIcon = selectedAppIcon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != selectedAppIcon?.iconValue else {
                /// No need to update since we're already using this icon.
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(selectedAppIcon?.iconValue)

                onCancel()
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
    ChangeAppIconView(vm: .init(), onCancel: {})
}
