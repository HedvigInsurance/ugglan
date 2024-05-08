import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct Launch: View {

    let completeAnimationCallbacker = Callbacker<Void>()
    static let shared = Launch()

    var body: some View {
        VStack {
            Image(uiImage: hCoreUIAssets.wordmark.image)
                .frame(width: 140, height: 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary)
    }
}
