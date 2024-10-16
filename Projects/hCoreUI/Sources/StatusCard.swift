import Foundation
import SwiftUI
import hCore

public struct StatusCard<MainContent, BottomContent>: View
where MainContent: View, BottomContent: View {
    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let title: String?
    let subTitle: String?
    let bottomComponent: () -> BottomContent
    @Environment(\.hCardWithoutSpacing) var cardWithoutSpacing

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        bottomComponent: @escaping () -> BottomContent
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.subTitle = subTitle
        self.bottomComponent = bottomComponent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hRow {
                HStack(alignment: .center) {
                    mainContent
                    Spacer()
                }
            }
            .verticalPadding(0)
            .padding(.bottom, cardWithoutSpacing ? 0 : .padding16)
            VStack(alignment: .leading, spacing: 0) {
                if let title = title {
                    hText(title)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
                hText(subTitle ?? " ", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)

            }
            .padding(.horizontal, .padding16)
            Spacer().frame(height: cardWithoutSpacing ? 0 : 16)
            bottomComponent()
                .padding(.horizontal, .padding16)
        }
        .padding(.vertical, .padding16)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .fill(hSurfaceColor.Opaque.primary)
        )
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
    }
}

struct CardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            StatusCard(
                onSelected: {

                },
                mainContent: Text("T"),
                title: "TITLE",
                subTitle: "SUBTITLE",
                bottomComponent: {
                    Text("BOTTOM COMPONENT")
                }
            )
            Spacer()
        }
        .background(Color.gray)
    }
}

struct FCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            StatusCard(
                onSelected: {

                },
                mainContent: Text("T"),
                title: "TITLE",
                subTitle: "SUBTITLE",
                bottomComponent: {
                    Text("BOTTOM COMPONENT")
                }
            )
            Spacer()
        }
        .background(Color.gray)
    }
}

private struct EnvironmentHCardWithoutSpacing: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hCardWithoutSpacing: Bool {
        get { self[EnvironmentHCardWithoutSpacing.self] }
        set { self[EnvironmentHCardWithoutSpacing.self] = newValue }
    }
}

extension View {
    public var hCardWithoutSpacing: some View {
        self.environment(\.hCardWithoutSpacing, true)
    }
}
