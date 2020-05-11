//
//  PresentStartDate.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-14.
//

import Apollo
import Flow
import Foundation
import Presentation
import SnapKit
import UIKit
import Core

struct ChooseStartDate {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
}

extension ChooseStartDate: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIView()
        view.backgroundColor = .primaryBackground

        viewController.view = view

        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical

        view.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        let textStackView = UIStackView()
        textStackView.spacing = 8
        textStackView.axis = .vertical
        textStackView.layoutMargins = UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)
        textStackView.isLayoutMarginsRelativeArrangement = true
        containerView.addArrangedSubview(textStackView)

        let pickerStackView = UIStackView()
        pickerStackView.spacing = 8
        pickerStackView.axis = .vertical
        pickerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 0)
        pickerStackView.isLayoutMarginsRelativeArrangement = true
        pickerStackView.alignment = .fill
        pickerStackView.isUserInteractionEnabled = true

        containerView.addArrangedSubview(pickerStackView)

        let actionStackView = UIStackView()
        actionStackView.spacing = 24
        actionStackView.axis = .vertical
        actionStackView.alignment = .center
        actionStackView.layoutMargins = UIEdgeInsets(top: 32, left: 0, bottom: 10, right: 0)
        actionStackView.isLayoutMarginsRelativeArrangement = true
        actionStackView.isUserInteractionEnabled = true

        containerView.addArrangedSubview(actionStackView)

        let titleLabel = MultilineLabel(
            value: L10n.draggableStartdateTitle,
            style: .draggableOverlayTitle
        )

        bag += textStackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: L10n.draggableStartdateDescription,
            style: .draggableOverlayDescription
        )

        bag += textStackView.addArranged(descriptionLabel)

        let picker = UIDatePicker()

        picker.calendar = Calendar.current
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        picker.maximumDate = Calendar.current.date(byAdding: .year,
                                                   value: 1,
                                                   to: Date())

        pickerStackView.addArrangedSubview(picker)

        bag += client.watch(query: OfferQuery()).map { ($0.data?.lastQuoteOfMember.asCompleteQuote?.startDate?.localDateToDate) }.onValue { date in

            if let date = date {
                picker.date = date
            } else {
                picker.date = Date()
            }
        }

        let chooseDateButton = Button(title: L10n.chooseDateBtn,
                                      type: .standard(backgroundColor: .primaryButtonBackgroundColor,
                                                      textColor: .white))

        let loadableChooseDateButton = LoadableButton(button: chooseDateButton,
                                                      initialLoadingState: false)

        let activateNowButton = Button(title: "",
                                       type: .transparent(textColor: .primaryTintColor))

        let loadableActivateButton = LoadableButton(button: activateNowButton,
                                                    initialLoadingState: false)

        bag += actionStackView.addArranged(loadableChooseDateButton.wrappedIn(UIStackView()))
        bag += actionStackView.addArranged(loadableActivateButton.wrappedIn(UIStackView()))

        func updateStartDateCache(startDate: String?) {
            store.update(query: OfferQuery()) { (data: inout OfferQuery.Data) in
                data.lastQuoteOfMember.asCompleteQuote?.startDate = startDate
            }
        }

        return (viewController, Future { completion in

            bag += loadableChooseDateButton.onTapSignal.onValue { _ in

                loadableChooseDateButton.isLoadingSignal.value = true

                bag += self.client.fetch(query: OfferQuery()).valueSignal.compactMap {
                    $0.data?.lastQuoteOfMember.asCompleteQuote?.id
                }
                .plain()
                .withLatestFrom(picker.atOnce().plain())
                .mapLatestToFuture { id, pickedStartDate in
                    self.client.perform(mutation: ChangeStartDateMutationMutation(id: id, startDate: pickedStartDate.localDateString ?? ""))
                }.onValue { result in

                    bag += Signal(after: 0.5).onValue { _ in
                        loadableChooseDateButton.isLoadingSignal.value = false
                        completion(.success)
                    }

                    updateStartDateCache(startDate: result.data?.editQuote.asCompleteQuote?.startDate)
                }
            }

            bag += self.client.fetch(query: OfferQuery()).map { $0.data?.insurance.previousInsurer }.onValue { previousInsurer in
                if previousInsurer == nil {
                    activateNowButton.title.value = L10n.activateTodayBtn

                    bag += loadableActivateButton.onTapSignal.onValue { _ in
                        loadableActivateButton.isLoadingSignal.value = true

                        self.client.fetch(query: OfferQuery()).onValue { result in
                            guard let id = result.data?.lastQuoteOfMember.asCompleteQuote?.id else { return }

                            self.client.perform(mutation: ChangeStartDateMutationMutation(id: id, startDate: Date().localDateString ?? "")).onValue { result in
                                bag += Signal(after: 0.5).onValue { _ in
                                    loadableActivateButton.isLoadingSignal.value = false
                                    completion(.success)
                                }

                                updateStartDateCache(startDate: result.data?.editQuote.asCompleteQuote?.startDate)
                            }
                        }
                    }
                } else {
                    activateNowButton.title.value = L10n.activateInsuranceEndBtn

                    bag += loadableActivateButton.onTapSignal.onValue { _ in
                        loadableActivateButton.isLoadingSignal.value = true

                        self.client.fetch(query: OfferQuery()).onValue { result in
                            guard let quoteId = result.data?.lastQuoteOfMember.asCompleteQuote?.id else { return }

                            self.client.perform(mutation: RemoveStartDateMutation(id: quoteId)).onValue { _ in
                                updateStartDateCache(startDate: nil)

                                bag += Signal(after: 0.5).onValue { _ in
                                    loadableActivateButton.isLoadingSignal.value = false
                                    completion(.success)
                                }
                            }
                        }
                    }
                }
            }

            return bag
        })
    }
}
