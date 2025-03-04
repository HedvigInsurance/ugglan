import SwiftUI
import hCore

public struct InsuranceTermView: View {
    let documents: [hPDFDocument]
    let onDocumentTap: (_ document: hPDFDocument) -> Void

    public init(
        documents: [hPDFDocument],
        onDocumentTap: @escaping (_: hPDFDocument) -> Void
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
