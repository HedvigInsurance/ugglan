import Foundation
import SwiftUI
import UIKit

public struct VectorPreservedImage<Color: hColor>: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.userInterfaceLevel) var level
    var image: UIImage
    var tint: Color
    
    public init(image: UIImage, tint: Color) {
        self.image = image
        self.tint = tint
    }
    
    public func makeUIView(context: Context) -> UIImageView {
        UIImageView(image: image)
    }
    
    public func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.image = image
        imageView.tintColor = UIColor(
            cgColor: tint.colorFor(colorScheme, level).color.cgColor
            ?? .init(red: 0, green: 0, blue: 0, alpha: 0)
        )
    }
}
