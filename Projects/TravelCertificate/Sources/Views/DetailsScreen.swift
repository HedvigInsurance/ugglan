import SwiftUI
import hCoreUI

struct DetailsScreen: View {
    let model: TravelCertificateModel
    var body: some View {
        DocumentPreview(url: model.url)
    }
}

#Preview{
    DetailsScreen(
        model: .init(
            id: UUID().uuidString,
            date: Date(),
            valid: true,
            url: nil
        )!
    )
}
