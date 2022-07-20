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
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}

struct hGradient: View {
    @Binding var oldGradientType: GradientType
    @Binding var newGradientType: GradientType
    
    @State private var progress: CGFloat = 0
    @State private var colors: [Color] = []
    
    var body: some View {
        Rectangle()
            .animatableGradient(fromGradient: Gradient(colors: oldGradientType.colors()), toGradient: Gradient(colors: newGradientType.colors()), progress: progress)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                print("GRADZ new")
                self.progress = 0
                withAnimation(.linear(duration: 1.0)) {
                    self.progress = 1
                }
            }
        
        /*LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        ).onAppear {
            colors = oldColors
            withAnimation(.easeInOut(duration: 1.0)) {
                colors = newColors
            }
        }*/
    }
}

public enum GradientType {
    case none, home, insurance, forever, profile
    
    public func colors() -> [Color] {
        switch self {
        case .none:
            return [
                Color(.brand(.primaryBackground())),
                Color(.brand(.primaryBackground())),
                Color(.brand(.primaryBackground()))
            ]
        case .home:
            return [
                Color(red: 0.75, green: 0.79, blue: 0.85, opacity: 1.00),
                Color(red: 0.93, green: 0.80, blue: 0.67, opacity: 1.00),
                Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
            ]
        case .insurance:
            return [
                Color(red: 0.95, green: 0.85, blue: 0.75, opacity: 1.00),
                Color(red: 0.96, green: 0.91, blue: 0.86, opacity: 1.00),
                Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
            ]
        case .forever:
            return [
                Color(red: 0.83, green: 0.83, blue: 0.83, opacity: 1.00),
                Color(red: 0.90, green: 0.90, blue: 0.90, opacity: 1.00),
                Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
            ]
        case .profile:
            return [
                Color(red: 0.77, green: 0.87, blue: 0.93, opacity: 1.00),
                Color(red: 0.87, green: 0.93, blue: 0.95, opacity: 1.00),
                Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
            ]
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
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
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
 
        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
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
    
    @Published public var gradientType: GradientType = .none {
        didSet {
            if gradientType != oldValue {
                print("GRADZ new value:", gradientType, "old value:", oldValue)
                oldGradientType = oldValue
            }
        }
    }
}

public struct HostingGradient: View {
    @ObservedObject var gradientState = GradientState.shared
    
    public init() {}
    
    public var body: some View {
        if gradientState.gradientType != .none {
            hGradient(
                oldGradientType: $gradientState.oldGradientType,
                newGradientType: $gradientState.gradientType
            )
        } else {
            BackgroundView().edgesIgnoringSafeArea(.all)
        }
    }
}

public struct hForm<Content: View>: View {
    @ObservedObject var gradientState = GradientState.shared
    
    @State var bottomAttachedViewHeight: CGFloat = 0
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView
    var content: Content

    public init(
        gradientType: GradientType = .none,
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
        gradientState.gradientType = gradientType
    }

    public var body: some View {
        ZStack {
            if gradientState.gradientType != .none {
                hGradient(
                    oldGradientType: $gradientState.oldGradientType,
                    newGradientType: $gradientState.gradientType
                )
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
