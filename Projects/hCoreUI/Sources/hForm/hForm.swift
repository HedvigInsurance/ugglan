import Combine
import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

private struct EnvironmentHFormBottomAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hFormBottomAttachedView: AnyView? {
        get { self[EnvironmentHFormBottomAttachedView.self] }
        set { self[EnvironmentHFormBottomAttachedView.self] = newValue }
    }
}

extension View {
    public func hFormAttachToBottom<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hFormBottomAttachedView, AnyView(content()))
    }
}

struct BackgroundView: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.backgroundColor = .brand(.primaryBackground())
    }

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
}

extension View {
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(
            AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress)
        )
    }
}

struct hGradient: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var oldGradientType: GradientType
    @Binding var newGradientType: GradientType
    @Binding var animate: Bool

    @State private var hasAnimatedCurrentTypes = false
    @State private var progress: CGFloat = 0
    @State private var colors: [Color] = []

    var body: some View {
        if #available(iOS 14.0, *) {
            Rectangle()
                .animatableGradient(
                    fromGradient: Gradient(colors: oldGradientType.colors(for: colorScheme)),
                    toGradient: Gradient(colors: newGradientType.colors(for: colorScheme)),
                    progress: animate ? progress : 1
                )
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    if !hasAnimatedCurrentTypes {
                        self.progress = 0
                        withAnimation(.easeOut(duration: 1.0)) {
                            self.progress = 1
                        }
                        hasAnimatedCurrentTypes = true
                    } else {
                        self.progress = 1
                    }
                }
                .onChange(of: newGradientType) { _ in
                    hasAnimatedCurrentTypes = false
                }
        } else {
            EmptyView()
        }
    }
}

public enum GradientType {
    case none, home, insurance, forever, profile

    public func colors(for scheme: ColorScheme) -> [Color] {
        switch self {
        case .none:
            return [
                Color(.brand(.primaryBackground())),
                Color(.brand(.primaryBackground())),
                Color(.brand(.primaryBackground())),
            ]
        case .home:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.11, green: 0.15, blue: 0.19, opacity: 1.00),
                    Color(red: 0.20, green: 0.13, blue: 0.12, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.75, green: 0.79, blue: 0.85, opacity: 1.00),
                    Color(red: 0.93, green: 0.80, blue: 0.67, opacity: 1.00),
                    Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
                ]
            }
        case .insurance:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.04, green: 0.09, blue: 0.10, opacity: 1.00),
                    Color(red: 0.10, green: 0.18, blue: 0.20, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.95, green: 0.85, blue: 0.75, opacity: 1.00),
                    Color(red: 0.96, green: 0.91, blue: 0.86, opacity: 1.00),
                    Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
                ]
            }
        case .forever:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.07, green: 0.07, blue: 0.07, opacity: 1.00),
                    Color(red: 0.15, green: 0.15, blue: 0.15, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.83, green: 0.83, blue: 0.83, opacity: 1.00),
                    Color(red: 0.90, green: 0.90, blue: 0.90, opacity: 1.00),
                    Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
                ]
            }
        case .profile:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.06, green: 0.06, blue: 0.02, opacity: 1.00),
                    Color(red: 0.12, green: 0.11, blue: 0.04, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.77, green: 0.87, blue: 0.93, opacity: 1.00),
                    Color(red: 0.87, green: 0.93, blue: 0.95, opacity: 1.00),
                    Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
                ]
            }
        }
    }
}

extension Color {
    func uiColor() -> UIColor {

        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff00_0000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff_0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000_ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x0000_00ff) / 255
        }
        return (r, g, b, a)
    }
}

struct AnimatableGradientModifier: AnimatableModifier {
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        var gradientColors = [Color]()

        for i in 0..<fromGradient.stops.count {

            let fromColor = fromGradient.stops[i].color.uiColor()
            let toColor = toGradient.stops[i].color.uiColor()

            gradientColors.append(colorMixer(fromColor: fromColor, toColor: toColor, progress: progress))
        }

        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        guard let fromColor = fromColor.cgColor.components else { return Color(fromColor) }
        guard let toColor = toColor.cgColor.components else { return Color(toColor) }
        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress

        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

public class GradientState: ObservableObject {
    public static let shared = GradientState()
    private init() {}

    @Published var oldGradientType: GradientType = .none
    @Published var animate: Bool = true

    @Published var gradientTypeBeforeNone: GradientType? = nil

    @Published public var gradientType: GradientType = .none {
        didSet {
            if gradientType != oldValue && oldValue != .none {
                oldGradientType = oldValue

                if gradientType == .none {
                    gradientType = oldValue
                    gradientTypeBeforeNone = oldValue
                }
            }
        }
    }
}

public struct hForm<Content: View>: View {
    @ObservedObject var gradientState = GradientState.shared
    let gradientType: GradientType

    @State var shouldAnimateGradient = true

    @State var bottomAttachedViewHeight: CGFloat = 0
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    var content: Content

    public init(
        gradientType: GradientType = .none,
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
        self.gradientType = gradientType
        gradientState.gradientType = gradientType
    }

    public var body: some View {
        ZStack {
            if gradientType != .none {
                hGradient(
                    oldGradientType: $gradientState.oldGradientType,
                    newGradientType: $gradientState.gradientType,
                    animate: $shouldAnimateGradient
                )
                .onDisappear {
                    shouldAnimateGradient = gradientState.gradientTypeBeforeNone != gradientType
                }
                .onAppear {
                    if gradientState.gradientTypeBeforeNone == gradientType {
                        gradientState.gradientTypeBeforeNone = nil
                    }
                }
            } else {
                BackgroundView().edgesIgnoringSafeArea(.all)
            }
            ScrollView {
                VStack {
                    content
                }
                .frame(maxWidth: .infinity)
                .tint(hTintColor.lavenderOne)
                Color.clear
                    .frame(height: bottomAttachedViewHeight)
            }
            .modifier(ForceScrollViewIndicatorInset(insetBottom: bottomAttachedViewHeight))
            .introspectScrollView { scrollView in
                if #available(iOS 15, *) {
                    scrollView.viewController?.setContentScrollView(scrollView)
                }
            }
            bottomAttachedView
                .background(
                    GeometryReader { geo in
                        Color.clear.onReceive(Just(geo.size.height)) { height in
                            self.bottomAttachedViewHeight = height
                        }
                    }
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}
