import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct CurrentInsurerSection {
    let quoteBundle: QuoteBundle
}

struct InceptionRow: View {
    var displayName: String?
    var insurer: String
    var switchable: Bool

    func makeSwitcherCard() -> some View {
        hCard(
            titleIcon: hCoreUIAssets.restart.image,
            title: L10n.switcherAutoCardTitle,
            bodyText: L10n.switcherAutoCardDescription,
            backgroundColor: hTintColor.lavenderTwo
        ) { EmptyView() }
    }

    func makeManualCard() -> some View {
        hCard(
            titleIcon: hCoreUIAssets.warningTriangle.image,
            title: L10n.switcherManualCardTitle,
            bodyText: L10n.switcherManualCardDescription,
            backgroundColor: hTintColor.lavenderTwo
        ) { EmptyView() }
    }

    var body: some View {
        hRow {
            VStack(spacing: 8) {
                displayName?
                    .hText(.title3)
                    .foregroundColor(hLabelColor.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                insurer
                    .hText(.body)
                    .foregroundColor(hLabelColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if switchable {
                    makeSwitcherCard()
                } else {
                    makeManualCard()
                }
            }
        }
    }
}

extension CurrentInsurerSection: View {
    var body: some View {
        switch quoteBundle.inception {
        case .concurrent(let concurrentInception):
            hSection {
                InceptionRow(
                    displayName: nil,
                    insurer: concurrentInception.currentInsurer?.displayName ?? "",
                    switchable: concurrentInception.currentInsurer?.switchable ?? false
                )
            }
            .withHeader {
                L10n.Offer
                    .switcherTitle(quoteBundle.quotes.count)
                    .hText()
            }
        case .independent(let inceptions):
            hSection(inceptions) { inception in
                InceptionRow(
                    displayName: quoteBundle.quoteFor(id: inception.correspondingQuoteId)?.displayName,
                    insurer: inception.currentInsurer?.displayName ?? "",
                    switchable: inception.currentInsurer?.switchable ?? false
                )
            }
            .withHeader {
                L10n.Offer
                    .switcherTitle(quoteBundle.quotes.count)
                    .hText()
            }
        case .unknown:
            EmptyView()
        }
    }
}
