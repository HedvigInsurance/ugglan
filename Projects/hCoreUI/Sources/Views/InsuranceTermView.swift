import SwiftUI
import hCore

public struct InsuranceTermView: View {
    let documents: [hPDFDocument]
    let onDocumentTap: (_ document: hPDFDocument) -> Void
    let header: String?

    public init(
        documents: [hPDFDocument],
        withHeader: String? = nil,
        onDocumentTap: @escaping (_: hPDFDocument) -> Void
    ) {
        self.documents = documents
        header = withHeader
        self.onDocumentTap = onDocumentTap
    }

    public var body: some View {
        VStack(spacing: .padding8) {
            if let header {
                hSection {
                    hText(header, style: .heading1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .sectionContainerStyle(.transparent)
            }
            VStack(spacing: .padding4) {
                ForEach(documents, id: \.displayName) { document in
                    hSection {
                        hRow {
                            hAttributedTextView(
                                text: AttributedPDF().attributedPDFString(for: document.displayName)
                            )
                            .id("sds_\(document.displayName)")
                        }
                        .withCustomAccessory {
                            hCoreUIAssets.arrowNorthEast.view
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
}
