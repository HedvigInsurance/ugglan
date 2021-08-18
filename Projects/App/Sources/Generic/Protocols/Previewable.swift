import Flow
import Form
import Foundation
import Presentation

/// Something that can preview something that is a presentable 👀
protocol Previewable {
    associatedtype PreviewMatter: Presentable
    func preview() -> (PreviewMatter, PresentationOptions)
}
