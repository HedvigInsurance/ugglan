import Foundation
import SwiftUI

public extension ImageAsset {
    /// a SwiftUI view with the image asset
    var view: SwiftUI.Image {
        .init(uiImage: image)
    }
}
