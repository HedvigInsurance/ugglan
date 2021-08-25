import Foundation
import SwiftUI

extension ImageAsset {
    /// a SwiftUI view with the image asset
    public var view: SwiftUI.Image {
        .init(uiImage: self.image)
    }
}
