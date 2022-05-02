import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

struct FrequentlyAskedQuestionsSection {}

extension FrequentlyAskedQuestionsSection: UIViewRepresentable {
    
    class Coordinator {
        let bag = DisposeBag()
        
        init() {}
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> some UIView {
        let (view, disposable) = self.materialize()
        
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

extension FrequentlyAskedQuestionsSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let store: OfferStore = self.get()

        let section = SectionView(
            headerView: UILabel(value: L10n.Offer.faqTitle, style: .default),
            footerView: {
                let footerStackView = UIStackView()
                footerStackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 15)
                footerStackView.axis = .vertical
                footerStackView.spacing = 16

                let footerDescription = UILabel(
                    value: L10n.offerFooterSubtitle,
                    style: .brand(.subHeadline(color: .primary)).aligned(to: .center)
                )

                footerStackView.addArrangedSubview(footerDescription)

                let button = Button(
                    title: L10n.offerFooterButtonText,
                    type: .standardOutlineIcon(
                        borderColor: .brand(.primaryText()),
                        textColor: .brand(.primaryText()),
                        icon: .left(image: hCoreUIAssets.chat.image, width: 24)
                    )
                )

                bag += button.onTapSignal.onValue { _ in
                    let store: OfferStore = self.get()
                    store.send(.openChat)
                }

                bag += footerStackView.addArranged(button)

                return footerStackView
            }()
        )
        section.dynamicStyle = .brandGroupedInset(separatorType: .standard)

        bag += store.stateSignal.map { $0.currentVariant?.bundle.appConfiguration.showFaq ?? false }
            .onValue { shouldShowFaq in
                section.isHidden = !shouldShowFaq
            }

        bag += store.stateSignal.compactMap { $0.currentVariant?.bundle.frequentlyAskedQuestions }
            .onValueDisposePrevious { frequentlyAskedQuestions in
                let innerBag = DisposeBag()

                innerBag += frequentlyAskedQuestions.map { frequentlyAskedQuestion in
                    let innerBag = DisposeBag()

                    let titleLabel = MultilineLabel(
                        value: frequentlyAskedQuestion.headline ?? "",
                        style: .brand(.body(color: .primary))
                    )

                    let row = RowView()
                    innerBag += row.append(titleLabel)

                    innerBag += section.append(row).compactMap { _ in row.viewController }
                        .onValue { viewController in
                            innerBag += viewController.present(
                                FrequentlyAskedQuestionDetail(
                                    frequentlyAskedQuestion: frequentlyAskedQuestion
                                )
                                .journey
                            )
                        }

                    innerBag += Disposer {
                        section.remove(row)
                    }

                    let imageView = UIImageView()
                    imageView.image = hCoreUIAssets.chevronRight.image
                    imageView.setContentHuggingPriority(.required, for: .horizontal)

                    row.append(imageView)
                    imageView.snp.makeConstraints { make in
                        make.width.equalTo(16)
                    }

                    return innerBag
                }

                return innerBag
            }

        return (section, bag)
    }
}
