//
//  CommonClaimTitleAndBulletPoints.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-15.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import Core

struct CommonClaimTitleAndBulletPoints {
    let commonClaimCard: CommonClaimCard
    let originView: UIView
}

extension CommonClaimTitleAndBulletPoints: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = .offWhite

        commonClaimCard.backgroundStateSignal.value = .expanded
        commonClaimCard.cornerRadiusSignal.value = 0
        commonClaimCard.iconTopPaddingStateSignal.value = .expanded
        commonClaimCard.titleLabelStateSignal.value = .expanded
        commonClaimCard.controlIsEnabledSignal.value = false
        commonClaimCard.shadowOpacitySignal.value = 0
        commonClaimCard.showTitleCloseButton.value = true
        commonClaimCard.showClaimButtonSignal.value = true

        bag += commonClaimCard.claimButtonTapSignal.onValue { _ in
            let overlay = DraggableOverlay(
                presentable: HonestyPledge(),
                presentationOptions: [
                    .defaults,
                    .prefersLargeTitles(false),
                    .largeTitleDisplayMode(.never),
                    .prefersNavigationBarHidden(true),
                ],
                adjustsToKeyboard: false
            )
            viewController.present(overlay)
        }

        bag += view.addArranged(commonClaimCard) { commonClaimCardView in
            commonClaimCardView.snp.makeConstraints { make in
                make.height.equalTo(commonClaimCard.height(state: .expanded))
            }

            bag += commonClaimCardView.didLayoutSignal.onValue { _ in
                view.bringSubviewToFront(commonClaimCardView)
            }
        }

        if let bulletPoints = commonClaimCard.data.layout.asTitleAndBulletPoints?.bulletPoints {
            bag += view.addArranged(BulletPointTable(
                bulletPoints: bulletPoints
            )) { tableView in
                bag += tableView.didLayoutSignal.onValue { _ in
                    tableView.snp.remakeConstraints { make in
                        make.height.equalTo(tableView.contentSize.height + 20)
                    }
                }
            }
        }

        bag += viewController.install(view) { scrollView in
            bag += scrollView.contentOffsetSignal.bindTo(self.commonClaimCard.scrollPositionSignal)
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 90, left: 0, bottom: 40, right: 0)
            scrollView.insetsLayoutMarginsFromSafeArea = false
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        return (viewController, Future { completion in
            bag += self.commonClaimCard.closeSignal.onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
