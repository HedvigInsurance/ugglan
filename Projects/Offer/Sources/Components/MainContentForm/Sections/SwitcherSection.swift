import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SwitcherSection {}

struct CurrentInsurerSectionView: UIViewRepresentable {
    let quoteBundle: QuoteBundle

    class Coordinator {
        let bag = DisposeBag()

        init() {}
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> some UIView {
        let (view, disposable) = CurrentInsurerSection(quoteBundle: quoteBundle).materialize()

        context.coordinator.bag += Disposer {
            DispatchQueue.main.async {
                disposable.dispose()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

extension SwitcherSection: View {
    var body: some View {
        VStack {
            PresentableStoreLens(
                OfferStore.self,
                getter: { $0.currentVariant?.bundle ?? nil }
            ) { quoteBundle in
                if let quoteBundle = quoteBundle, quoteBundle.switcher {
                    CurrentInsurerSectionView(quoteBundle: quoteBundle)
                }
            }
        }
    }
}
