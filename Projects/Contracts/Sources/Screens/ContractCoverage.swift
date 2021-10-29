import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL


struct ContractCoverageView: View {
    @PresentableStore var store: ContractStore
    let perils: [Perils]
    let insurableLimits: [InsurableLimits]
    
    var body: some View {
        VStack {
            hSection {
                PerilCollection(perils: perils) { peril in
                    store.send(.contractDetailNavigationAction(action: .peril(peril: peril)))
                }
            }.sectionContainerStyle(.transparent)
            Spacer()
            SwiftUI.Divider()
            Spacer()
            InsurableLimitsSectionView(
                header: hText(
                    L10n.contractCoverageMoreInfo,
                    style: .headline
                )
                .foregroundColor(hLabelColor.secondary),
                limits: insurableLimits
            ) { limit in
                store.send(.contractDetailNavigationAction(action: .insurableLimit(insurableLimit: limit)))
            }
        }
    }
}

struct ContractCoverage {
    let perils: [Perils]
    let insurableLimits: [InsurableLimits]
}

extension ContractCoverage: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = L10n.contractCoverageMainTitle
        let stack = UIStackView()
        stack.axis = .vertical

        let insets = EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

        let perilCollection = PerilCollection(
            perils: perils,
            didTapPeril: { peril in
                viewController
                    .present(
                        PerilDetail(peril: peril).withCloseButton,
                        style: .detented(.preferredContentSize, .large)
                    )
            }
        )
        .padding(insets)

        stack.addArrangedSubview(HostingView(rootView: perilCollection))

        bag += stack.addArranged(Spacing(height: 20))

        bag += stack.addArranged(Divider(backgroundColor: .brand(.primaryBorderColor)))

        bag += stack.addArranged(Spacing(height: 20))

        bag += stack.addArranged(InsurableLimitsSection(insurableLimits: insurableLimits))

        //form.appendSpacing(.custom(20))

        //bag += viewController.install(form, options: [])
        viewController.view = stack

        return (viewController, bag)
    }
}
