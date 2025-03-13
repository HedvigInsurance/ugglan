import SwiftUI

struct DetectOrientation: ViewModifier {
    @Binding var orientation: DeviceOrientation

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                self.orientation = UIDevice.current.orientation.getDeviceOrientation
            }
    }
}

extension View {
    public func detectOrientation(_ orientation: Binding<DeviceOrientation>) -> some View {
        modifier(DetectOrientation(orientation: orientation))
    }
}

public enum DeviceOrientation {
    case portrait
    case landscape
}

extension UIDeviceOrientation {
    var getDeviceOrientation: DeviceOrientation {
        switch self {
        case .landscapeLeft, .landscapeRight:
            return .landscape
        default:
            return .portrait
        }
    }
}
