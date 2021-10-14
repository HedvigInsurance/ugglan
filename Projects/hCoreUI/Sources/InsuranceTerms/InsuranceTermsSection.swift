import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hGraphQL

public struct InsuranceTermsSection: View {
    var terms: [InsuranceTerm]
    var didTapInsuranceTerm: (_ insuranceTerm: InsuranceTerm) -> Void

    public init(
        terms: [InsuranceTerm],
        didTapInsuranceTerm: @escaping (InsuranceTerm) -> Void
    ) {
        self.terms = terms
        self.didTapInsuranceTerm = didTapInsuranceTerm
    }

    public var body: some View {
        hSection(terms, id: \.displayName) { insuranceTerm in
            hRow {
                HStack(spacing: 20) {
                    Image(uiImage: hCoreUIAssets.document.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    hText(insuranceTerm.displayName)
                }
            }
            .onTap {
                didTapInsuranceTerm(insuranceTerm)
            }
        }
        .withHeader {
            hText(L10n.offerDocumentsSectionTitle)
        }
    }
}
