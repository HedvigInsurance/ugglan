import Combine
import SwiftUI
import hCore

public struct hRadioField<Content: View>: View {
    private let content: Content
    private let id: String
    private var useAnimation: Bool
    @Environment(\.hFieldSize) var size
    @Environment(\.hUseNewDesign) var hUseNewDesign
    @Binding var selected: String?
    @Binding private var error: String?
    @State private var animate = false

    public init(
        id: String,
        content: @escaping () -> Content,
        selected: Binding<String?>,
        error: Binding<String?>? = nil,
        useAnimation: Bool = false
    ) {
        self.id = id
        self.content = content()
        self._selected = selected
        self._error = error ?? Binding.constant(nil)
        self.useAnimation = useAnimation
    }

    public var body: some View {
        HStack(spacing: 0) {
            content
            Spacer()
            hRadioOptionSelectedView(selectedValue: $selected, value: id)
        }
        .padding(.top, hUseNewDesign ? size.topPaddingNewDesign : size.topPadding)
        .padding(.bottom, hUseNewDesign ? size.bottomPaddingNewDesign : size.bottomPadding)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            ImpactGenerator.soft()
            withAnimation(.none) {
                self.selected = id
            }
            if useAnimation {
                self.animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.animate = false
                }
            }
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        print("NEW HEIGHT IS \(geo.size.height)")
                    }
                    .onChange(of: geo.size.height) { newValue in
                        print("NEW HEIGHT IS \(newValue)")

                    }
            }
        }
    }
}

struct hRadioField_Previews: PreviewProvider {
    @State static var value: String?
    @State static var error: String?
    static var previews: some View {
        VStack {
            hRadioField(
                id: "id",
                content: {
                    hText("id")
                },
                selected: $value,
                error: $error,
                useAnimation: true
            )
        }
    }
}

extension hFieldSize {
    fileprivate var minHeight: CGFloat {
        switch self {
        case .small:
            return 40
        case .large:
            return 72
        case .medium:
            return 72
        }
    }

    fileprivate var minHeightNewDesign: CGFloat {
        switch self {
        case .small:
            return 56
        case .large:
            return 64
        case .medium:
            return 64
        }
    }

    fileprivate var topPadding: CGFloat {
        switch self {
        case .small:
            return 8
        case .large:
            return 11
        case .medium:
            return 11
        }
    }

    fileprivate var topPaddingNewDesign: CGFloat {
        switch self {
        case .small:
            return 15
        case .large:
            return 16
        case .medium:
            return 19
        }
    }

    fileprivate var bottomPadding: CGFloat {
        topPadding
    }

    fileprivate var bottomPaddingNewDesign: CGFloat {
        topPaddingNewDesign + 2
    }
}
