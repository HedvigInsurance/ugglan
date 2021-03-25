import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

enum InsuranceWrapper {
    case external(EmbarkPassage.Action.AsEmbarkExternalInsuranceProviderAction)
    case previous(EmbarkPassage.Action.AsEmbarkPreviousInsuranceProviderAction)

    var embarkLinkFragment: GraphQL.EmbarkLinkFragment {
        switch self {
        case let .external(data):
            return data.externalInsuranceProviderData.next.fragments.embarkLinkFragment
        case let .previous(data):
            return data.previousInsuranceProviderData.next.fragments.embarkLinkFragment
        }
    }

    var isExternal: Bool {
        false
    }
}

struct InsuranceProviderAction {
    let state: EmbarkState
    let data: InsuranceWrapper
}

extension InsuranceProviderAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let bag = DisposeBag()
        let view = UIView()
        bag += view.applyShadow { _ -> UIView.ShadowProperties in
            .embark
        }

        return (view, Signal { callback in
            func renderChildViewController() {
                let options: PresentationOptions = [.defaults]
                let (selectionViewController, didPickInsuranceProviderFuture) = InsuranceProviderSelection(data: data).materialize()

                bag += didPickInsuranceProviderFuture.onValue { provider in
                    if let passageName = self.state.passageNameSignal.value {
                        self.state.store.setValue(
                            key: "\(passageName)Result",
                            value: provider.name
                        )
                    }

                    self.state.store.setValue(key: "previousInsurer", value: provider.name)
                    callback(self.data.embarkLinkFragment)
                }.disposable

                let childViewController = selectionViewController.embededInNavigationController(options)

                view.viewController?.addChild(childViewController)

                if #available(iOS 13.0, *) {
                    view.viewController?.setOverrideTraitCollection(UITraitCollection(userInterfaceLevel: .elevated), forChild: childViewController)
                }

                view.addSubview(childViewController.view)

                childViewController.view.snp.makeConstraints { make in
                    make.top.bottom.leading.trailing.equalToSuperview()
                }

                childViewController.becomeFirstResponder()
                childViewController.didMove(toParent: view.viewController ?? UIViewController())

                childViewController.view.layer.cornerRadius = 8

                bag += childViewController.signal(for: \.preferredContentSize).atOnce().onValue { size in
                    view.snp.remakeConstraints { make in
                        make.height.equalTo(size.height)
                    }
                }
            }

            bag += view.didMoveToWindowSignal.atOnce().take(first: 1).onValue(renderChildViewController)

            return bag
        })
    }
}
