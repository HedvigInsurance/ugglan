import SwiftUI
import hGraphQL

public struct InsuranceTermView: View {
    let documents: [InsuranceTerm]
    let onDocumentTap: (_ document: InsuranceTerm) -> Void

    public init(
        documents: [InsuranceTerm],
        onDocumentTap: @escaping (_: InsuranceTerm) -> Void
    ) {
        self.documents = documents
        self.onDocumentTap = onDocumentTap
    }

    public var body: some View {
        VStack(spacing: 4) {
            ForEach(documents, id: \.displayName) { document in
                hSection {
                    hRow {
                        hAttributedTextView(
                            text: AttributedPDF().attributedPDFString(for: document.displayName)
                        )
                        .id("sds_\(document.displayName)")
                    }
                    .withCustomAccessory {
                        Image(uiImage: hCoreUIAssets.arrowNorthEast.image)
                    }
                    .onTap {
                        onDocumentTap(document)
                    }
                }
                .sectionContainerStyle(.opaque)
            }
        }
    }
}
