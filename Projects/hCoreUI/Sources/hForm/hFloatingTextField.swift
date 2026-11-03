import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

public struct hFloatingTextField<Value: Hashable>: View {
    @Environment(\.hFieldSize) var size
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hFieldRightAttachedView) var rightAttachedView
    @Environment(\.hFieldMultiline) var isMultiline
    @Environment(\.hWithoutFontMultiplier) var withoutFontMultiplier
    @Environment(\.hFieldFocusCoordinator) private var focusCoordinator
    @Environment(\.hFormScrollProxy) private var scrollProxy
    @FocusState private var isFocused: Bool
    @State private var fieldID = hFieldFocusID()

    @State private var innerValue: String = ""
    @State private var animate = false
    @State private var previousInnerValue: String = ""
    @State private var shouldMoveLabel: Bool = false
    @Binding var error: String?
    @Binding var value: String
    @Binding var focus: Value?

    private var masking: Masking
    private var placeholder: String
    private var suffix: String?
    /// `nil` when focus isn't controlled from outside, see the `Value == Never` init
    private let focusValue: Value?
    private let onReturn: () -> Void
    private let textFieldPlaceholder: String?

    /// - Parameters:
    ///   - focus: Lets the caller move focus to this field, by setting it to `focusValue`, or drop it,
    ///     by setting anything else. Return moves to the next field in the enclosing `hForm` on its own.
    public init(
        masking: Masking,
        value: Binding<String>,
        focus: Binding<Value?>,
        focusValue: Value,
        placeholder: String? = nil,
        suffix: String? = nil,
        error: Binding<String?>? = nil,
        textFieldPlaceholder: String? = nil,
        onReturn: @escaping () -> Void = {}
    ) {
        self.init(
            masking: masking,
            value: value,
            focus: focus,
            optionalFocusValue: focusValue,
            placeholder: placeholder,
            suffix: suffix,
            error: error,
            textFieldPlaceholder: textFieldPlaceholder,
            onReturn: onReturn
        )
    }

    fileprivate init(
        masking: Masking,
        value: Binding<String>,
        focus: Binding<Value?>,
        optionalFocusValue focusValue: Value?,
        placeholder: String?,
        suffix: String?,
        error: Binding<String?>?,
        textFieldPlaceholder: String?,
        onReturn: @escaping () -> Void
    ) {
        self.masking = masking
        self.placeholder = placeholder ?? masking.placeholderText ?? ""
        self.suffix = suffix
        _value = value
        _focus = focus
        self.focusValue = focusValue
        self.onReturn = onReturn
        _error = error ?? Binding.constant(nil)
        _previousInnerValue = State(initialValue: value.wrappedValue)
        _innerValue = State(initialValue: value.wrappedValue)
        // @State can't be written from init, so the label position is seeded as the initial value
        let startsFocused = focusValue != nil && focus.wrappedValue == focusValue
        _shouldMoveLabel = State(initialValue: !value.wrappedValue.isEmpty || startsFocused)
        self.textFieldPlaceholder = textFieldPlaceholder
    }

    public var body: some View {
        HStack(spacing: .padding8) {
            hFieldContainer(
                placeholder: placeholder,
                customLabelOffset: nil,
                animate: $animate,
                error: $error,
                shouldMoveLabel: $shouldMoveLabel
            ) {
                HStack {
                    getTextField
                        .showClearButtonOrError(
                            $innerValue,
                            isFocused: isFocused,
                            error: $error
                        )
                    if let suffix, !suffix.isEmpty {
                        hText(suffix, style: fontStyle)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityHint(
                isEnabled ? L10n.voiceoverPressTo + " " + L10n.voiceoverEdit : ""
            )
            rightAttachedView
        }
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .geometryGroup()
        .onTapGesture {
            isFocused = true
        }
        .accessibilityAddTraits(.isButton)
        .id(fieldID)
        // Disabled fields are left out, so return skips over them
        .preference(key: hFieldFocusOrderKey.self, value: isEnabled ? [fieldID] : [])
        .onAppear {
            if isFocusedFromOutside {
                isFocused = true
            }
        }
        .onChange(of: focus) {
            isFocused = isFocusedFromOutside
        }
        .onChange(of: focusCoordinator?.focusRequest) { _, request in
            if request == fieldID {
                focusCoordinator?.focusRequest = nil
                isFocused = true
            }
        }
        .onChange(of: isFocused) { _, isFocused in
            if isFocused {
                clearError()
                if let focusValue {
                    focus = focusValue
                }
                scrollIntoView()
            } else if isFocusedFromOutside {
                focus = nil
            }
            updateMoveLabel()
        }
        .onChange(of: value) { _, value in
            innerValue = value
        }
        .onChange(of: innerValue) { _, currentValue in
            handleInnerValueChange(currentValue)
        }
        .onChange(of: error) {
            pulseAnimation()
        }
    }

    private var isFocusedFromOutside: Bool {
        focusValue != nil && focus == focusValue
    }

    /// Applies the masking to typed text and writes the result back to the bindings.
    private func handleInnerValueChange(_ currentValue: String) {
        if currentValue != previousInnerValue {
            let masked = masking.maskValue(text: currentValue, previousText: previousInnerValue)
            withAnimation {
                value = masked
                innerValue = masked
                previousInnerValue = masked
            }
            // A rewritten value fires this handler again, which then does the work below
            if masked != currentValue { return }
        }
        clearError()
        updateMoveLabel()
        pulseAnimation { currentValue == innerValue }
    }

    /// Moves focus to the next field in the enclosing `hForm`, or drops the keyboard when this is the last one.
    private func handleReturn() {
        if let next = focusCoordinator?.field(after: fieldID) {
            // The next field takes the first responder from this one, so the keyboard stays up
            focusCoordinator?.focusRequest = next
        } else {
            isFocused = false
        }
        onReturn()
    }

    /// Scrolls the enclosing `hForm` so the field sits in the middle of the area left above the keyboard
    private func scrollIntoView() {
        guard let scrollProxy else { return }
        Task {
            // Waits for the keyboard inset, otherwise the scroll targets the area the keyboard is about to cover
            await delay(0.3)
            guard isFocused else { return }
            withAnimation {
                scrollProxy.scrollTo(fieldID, anchor: .center)
            }
        }
    }

    private func clearError() {
        guard error != nil else { return }
        withAnimation {
            error = nil
        }
    }

    /// Highlights the field background briefly. `shouldReset` is checked after the delay,
    /// so a newer pulse can keep the highlight on.
    private func pulseAnimation(shouldReset: @escaping @MainActor () -> Bool = { true }) {
        animate = true
        Task {
            await delay(0.4)
            if shouldReset() {
                animate = false
            }
        }
    }

    /// The label sits above the text whenever the field has a value or is focused.
    private func updateMoveLabel() {
        let target = !innerValue.isEmpty || isFocused
        guard target != shouldMoveLabel else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            shouldMoveLabel = target
        }
    }

    @ViewBuilder
    private var getTextField: some View {
        let title = shouldMoveLabel ? textFieldPlaceholder ?? "" : ""
        if isMultiline {
            let labelOffset = firstRowHeight / 2 + (shouldMoveLabel ? .padding4 : 0)
            styled(
                SwiftUI.TextField(title, text: $innerValue, axis: .vertical)
                    .lineLimit(2...2)
                    .alignmentGuide(.fieldLabel) { _ in labelOffset }
            )
        } else {
            // Return in a multiline field inserts a new line, so only single line fields submit
            styled(SwiftUI.TextField(title, text: $innerValue))
                .submitLabel(focusCoordinator?.field(after: fieldID) == nil ? .done : .return)
                .introspect(.textField, on: .iOS(.v17...)) { textField in
                    ReturnKeyInterceptor.install(on: textField, onReturn: handleReturn)
                }
        }
    }

    private var fontStyle: HFontTextStyle {
        size == .large ? .body2 : .body1
    }

    private var firstRowHeight: CGFloat {
        Fonts.fontFor(style: fontStyle, withoutFontMultipler: withoutFontMultiplier).lineHeight
    }

    private func styled(_ textField: some View) -> some View {
        textField
            .modifier(hFontModifier(style: fontStyle))
            .modifier(masking)
            .tint(foregroundColor)
            .foregroundColor(foregroundColor)
            .focused($isFocused)
    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Translucent.secondary
        }
    }
}

/// Handles the return key of a SwiftUI backed `UITextField` and forwards every other delegate call to
/// SwiftUI's own delegate, so `@FocusState` keeps working.
/// SwiftUI resigns the field on return, before the next field takes focus, which drops and raises the keyboard.
/// Not resigning here hands the first responder straight over to the next field.
@MainActor
final class ReturnKeyInterceptor: NSObject, UITextFieldDelegate {
    private static var associatedKey: UInt8 = 0

    private var onReturn: () -> Void = {}
    nonisolated(unsafe) private weak var forwardee: (any UITextFieldDelegate)?

    /// Owned by the text field rather than the view, since `onReturn` captures the view's state
    static func install(on textField: UITextField, onReturn: @escaping () -> Void) {
        let interceptor =
            objc_getAssociatedObject(textField, &associatedKey) as? ReturnKeyInterceptor
            ?? {
                let interceptor = ReturnKeyInterceptor()
                objc_setAssociatedObject(textField, &associatedKey, interceptor, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return interceptor
            }()
        interceptor.onReturn = onReturn
        if textField.delegate !== interceptor {
            interceptor.forwardee = textField.delegate
            textField.delegate = interceptor
        }
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        onReturn()
        return false
    }

    override nonisolated func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || forwardee?.responds(to: aSelector) == true
    }

    override nonisolated func forwardingTarget(for _: Selector!) -> Any? {
        forwardee
    }
}

#Preview {
    @Previewable @State var value: String = "Text Input"
    @Previewable @State var error: String?
    @Previewable @State var focus: PreviewField? = .first

    return hForm {
        VStack {
            hFloatingTextField(
                masking: .init(type: .none),
                value: $value,
                focus: $focus,
                focusValue: .first,
                placeholder: "Label",
                suffix: "SEK",
                error: $error
            )
            hFloatingTextField(
                masking: .init(type: .none),
                value: $value,
                placeholder: "Label",
                error: $error
            )
            .disabled(true)
            hFloatingTextField(
                masking: .init(type: .none),
                value: $value,
                placeholder: "Label",
                error: $error
            )
            hFloatingTextField(
                masking: .init(type: .none),
                value: $value,
                placeholder: "Label",
                error: $error
            )
            .hFieldMultiline()
        }
    }
    .hFieldSize(.large)

    enum PreviewField {
        case first
    }
}

extension hFloatingTextField where Value == Never {
    /// A field whose focus is only driven by the user, return moves to the next field in the enclosing `hForm`.
    public init(
        masking: Masking,
        value: Binding<String>,
        placeholder: String? = nil,
        suffix: String? = nil,
        error: Binding<String?>? = nil,
        textFieldPlaceholder: String? = nil,
        onReturn: @escaping () -> Void = {}
    ) {
        self.init(
            masking: masking,
            value: value,
            focus: .constant(nil),
            optionalFocusValue: nil,
            placeholder: placeholder,
            suffix: suffix,
            error: error,
            textFieldPlaceholder: textFieldPlaceholder,
            onReturn: onReturn
        )
    }
}

/// Identifies one `hFloatingTextField` inside an `hFieldFocusScope`
struct hFieldFocusID: Hashable, Sendable {
    private let id = UUID()
}

/// Collects the enabled fields in the order they are declared, which is the order return moves through them
struct hFieldFocusOrderKey: PreferenceKey {
    static let defaultValue: [hFieldFocusID] = []

    static func reduce(value: inout [hFieldFocusID], nextValue: () -> [hFieldFocusID]) {
        value.append(contentsOf: nextValue())
    }
}

@MainActor
@Observable
final class hFieldFocusCoordinator {
    fileprivate var order: [hFieldFocusID] = []
    /// Set by a field on return, picked up and cleared by the field it names
    var focusRequest: hFieldFocusID?

    func field(after id: hFieldFocusID) -> hFieldFocusID? {
        guard let index = order.firstIndex(of: id), index + 1 < order.count else { return nil }
        return order[index + 1]
    }
}

extension EnvironmentValues {
    @Entry var hFieldFocusCoordinator: hFieldFocusCoordinator? = nil
}

/// Lets return move between the `hFloatingTextField`s inside it, in the order they are declared.
/// `hForm` applies it, so it's only needed for fields that aren't in one.
struct hFieldFocusScopeModifier: ViewModifier {
    @State private var coordinator = hFieldFocusCoordinator()

    func body(content: Content) -> some View {
        content
            .environment(\.hFieldFocusCoordinator, coordinator)
            .onPreferenceChange(hFieldFocusOrderKey.self) { [coordinator] order in
                MainActor.assumeIsolated {
                    // @Observable notifies on every write, which would re-render every field in the scope
                    if coordinator.order != order {
                        coordinator.order = order
                    }
                }
            }
            // An enclosing scope shouldn't chain into the fields of this one
            .transformPreference(hFieldFocusOrderKey.self) { $0 = [] }
    }
}

extension View {
    public func hFieldFocusScope() -> some View {
        modifier(hFieldFocusScopeModifier())
    }
}

public enum BackgroundOption: Sendable {
    case withoutDisabled
    case locked
}

public enum hFieldSize: Hashable, Sendable {
    case small
    case medium
    case large
    case extraLarge

    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return .padding14
        case .medium:
            return .padding16
        case .large:
            return .padding16
        case .extraLarge:
            return .padding16
        }
    }
}

extension EnvironmentValues {
    @Entry public var hBackgroundOption: [BackgroundOption] = []
    @Entry public var hFieldSize: hFieldSize = .medium
    @Entry public var hFieldRightAttachedView: AnyView? = nil
    @Entry public var hFieldMultiline: Bool = false
}

extension View {
    /// Lets `hFloatingTextField` wrap onto two rows, at a fixed height. The field does not grow
    /// with the text, longer input scrolls inside it.
    /// Return inserts a new line instead of moving focus to the next field.
    public func hFieldMultiline(_ isMultiline: Bool = true) -> some View {
        environment(\.hFieldMultiline, isMultiline)
    }
}

extension View {
    public func hBackgroundOption(option: [BackgroundOption]) -> some View {
        environment(\.hBackgroundOption, option)
    }
}

extension View {
    public func hFieldSize(_ size: hFieldSize) -> some View {
        environment(\.hFieldSize, size)
    }
}

extension View {
    public func hFieldAttachToRight<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        environment(\.hFieldRightAttachedView, AnyView(content()))
    }
}

struct TextFieldClearButtonOrError: ViewModifier {
    @Binding var fieldText: String
    let isFocused: Bool
    @Binding var error: String?
    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 0) {
            content
            if fieldText != "", isFocused {
                SwiftUI.Button(
                    action: {
                        fieldText = ""
                    },
                    label: {
                        hCoreUIAssets.close.view
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hTextColor.Opaque.primary)
                    }
                )
                .accessibilityLabel(L10n.a11YClearField)
            } else if error != nil {
                hCoreUIAssets.warningTriangleFilled.view
                    .foregroundColor(hSignalColor.Amber.element)
            }
        }
    }
}

extension View {
    func showClearButtonOrError(
        _ text: Binding<String>,
        isFocused: Bool,
        error: Binding<String?>
    ) -> some View {
        modifier(
            TextFieldClearButtonOrError(
                fieldText: text,
                isFocused: isFocused,
                error: error
            )
        )
    }
}

extension hFieldSize {
    var labelOffset: CGFloat {
        switch self {
        case .small: return -13
        case .medium: return -14
        case .large: return -15
        case .extraLarge: return -15
        }
    }

    var fieldOffset: CGFloat {
        .padding8
    }

    var labelFont: HFontTextStyle {
        switch self {
        case .small: return .body1
        case .medium: return .body1
        case .large: return .body2
        case .extraLarge: return .body2
        }
    }
}

extension EnvironmentValues {
    @Entry public var hAnimateField: Bool = true
}

extension View {
    public func hAnimateField(_ animate: Bool) -> some View {
        environment(\.hAnimateField, animate)
    }
}
