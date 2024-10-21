import SwiftUI
import hGraphQL

public struct InsuranceTermView: View {
    let documents: [PDFDocument]
    let onDocumentTap: (_ document: PDFDocument) -> Void

    public init(
        documents: [PDFDocument],
        onDocumentTap: @escaping (_: PDFDocument) -> Void
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
