//
//  PresentStartDate.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-14.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SnapKit
import UIKit

struct ChooseStartDate {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
}

extension ChooseStartDate: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = L10n.draggableStartdateTitle
        let bag = DisposeBag()

        let form = FormView()

        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical

        form.append(containerView)

        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        let textStackView = UIStackView()
        textStackView.spacing = 8
        textStackView.axis = .horizontal
        textStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        textStackView.isLayoutMarginsRelativeArrangement = true
        containerView.addArrangedSubview(textStackView)

        let pickerStackView = UIStackView()
        pickerStackView.spacing = 8
        pickerStackView.axis = .vertical
        pickerStackView.alignment = .fill
        pickerStackView.isUserInteractionEnabled = true

        containerView.addArrangedSubview(pickerStackView)

        let actionStackView = UIStackView()
        actionStackView.spacing = 10
        actionStackView.axis = .vertical
        actionStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        actionStackView.isLayoutMarginsRelativeArrangement = true
        actionStackView.isUserInteractionEnabled = true

        containerView.addArrangedSubview(actionStackView)

        let descriptionLabel = MultilineLabel(
            value: L10n.draggableStartdateDescription,
            style: .brand(.body(color: .secondary))
        )
        bag += textStackView.addArranged(descriptionLabel)

        let picker = UIDatePicker()
        picker.tintColor = .brand(.link)
        picker.calendar = Calendar.current
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        picker.maximumDate = Calendar.current.date(byAdding: .year,
                                                   value: 1,
                                                   to: Date())

        pickerStackView.addArrangedSubview(picker)

        bag += client.watch(query: GraphQL.OfferQuery())
            .map { $0.lastQuoteOfMember.asCompleteQuote?.startDate?.localDateToDate }
            .onValue { date in
                if let date = date {
                    picker.date = date
                } else {
                    picker.date = Date()
                }
            }

        let chooseDateButton = Button(title: L10n.chooseDateBtn,
                                      type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor),
                                                      textColor: .brand(.primaryButtonTextColor)))

        let loadableChooseDateButton = LoadableButton(button: chooseDateButton,
                                                      initialLoadingState: false)

        let activateNowButton = Button(title: "",
                                       type: .transparent(textColor: .primaryTintColor))

        let loadableActivateButton = LoadableButton(button: activateNowButton,
                                                    initialLoadingState: false)

        bag += actionStackView.addArranged(loadableChooseDateButton)
        bag += actionStackView.addArranged(loadableActivateButton)

        func updateStartDateCache(startDate: String?) {
            store.update(query: GraphQL.OfferQuery()) { (data: inout GraphQL.OfferQuery.Data) in
                data.lastQuoteOfMember.asCompleteQuote?.startDate = startDate
            }
        }

        bag += viewController.install(form)

        return (viewController, Future { completion in
            bag += loadableChooseDateButton.onTapSignal.onValue { _ in
                loadableChooseDateButton.isLoadingSignal.value = true

                bag += self.client.fetch(query: GraphQL.OfferQuery()).valueSignal.compactMap {
                    $0.lastQuoteOfMember.asCompleteQuote?.id
                }
                .plain()
                .withLatestFrom(picker.atOnce().plain())
                .mapLatestToFuture { id, pickedStartDate in
                    self.client.perform(mutation: GraphQL.ChangeStartDateMutationMutation(id: id, startDate: pickedStartDate.localDateString ?? ""))
                }.onValue { data in
                    bag += Signal(after: 0.5).onValue { _ in
                        loadableChooseDateButton.isLoadingSignal.value = false
                        completion(.success)
                    }

                    updateStartDateCache(startDate: data.editQuote.asCompleteQuote?.startDate)
                }
            }

            bag += self.client.fetch(query: GraphQL.OfferQuery()).map { $0.insurance.previousInsurer }.onValue { previousInsurer in
                if previousInsurer == nil {
                    activateNowButton.title.value = L10n.activateTodayBtn

                    bag += loadableActivateButton.onTapSignal.onValue { _ in
                        loadableActivateButton.isLoadingSignal.value = true

                        self.client.fetch(query: GraphQL.OfferQuery()).onValue { data in
                            guard let id = data.lastQuoteOfMember.asCompleteQuote?.id else { return }

                            self.client.perform(mutation: GraphQL.ChangeStartDateMutationMutation(id: id, startDate: Date().localDateString ?? "")).onValue { data in
                                bag += Signal(after: 0.5).onValue { _ in
                                    loadableActivateButton.isLoadingSignal.value = false
                                    completion(.success)
                                }

                                updateStartDateCache(startDate: data.editQuote.asCompleteQuote?.startDate)
                            }
                        }
                    }
                } else {
                    activateNowButton.title.value = L10n.activateInsuranceEndBtn

                    bag += loadableActivateButton.onTapSignal.onValue { _ in
                        loadableActivateButton.isLoadingSignal.value = true

                        self.client.fetch(query: GraphQL.OfferQuery()).onValue { data in
                            guard let quoteId = data.lastQuoteOfMember.asCompleteQuote?.id else { return }

                            self.client.perform(mutation: GraphQL.RemoveStartDateMutation(id: quoteId)).onValue { _ in
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
