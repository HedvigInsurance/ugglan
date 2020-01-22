//
//  PresentStartDate.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-14.
//

import Foundation
import Flow
import Presentation
import UIKit
import SnapKit
import Apollo

struct PresentStartDate {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    private let didRedeemValidCodeCallbacker = Callbacker<RedeemCodeMutation.Data.RedeemCode>()
    
}

extension ChooseStartDate: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        
        bag += containerView.applySafeAreaBottomLayoutMargin()
        bag += containerView.applyPreferredContentSize(on: viewController)

        viewController.view = containerView

        let textStackView = UIStackView()
        textStackView.spacing = 8
        textStackView.axis = .vertical
        textStackView.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 32, right: 24)
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
            value: String("Byt startdatum"),
            style: .draggableOverlayTitle
        )
      
        bag += textStackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String("Vilket datum vill du att din försäkring aktiveras?"),
            style: .startDateDescription
        )
        
        bag += textStackView.addArranged(descriptionLabel)
        
        let picker = UIDatePicker()
        
        picker.calendar = Calendar.current
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        picker.maximumDate = Calendar.current.date(byAdding: .year,
                                                   value: 1,
                                                   to: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.local
        let today = dateFormatter.string(from: Date())
        
        var valueSelected: String = today
        
        bag += picker.atOnce().onValue({ (_) in
            let pickedValue = dateFormatter.string(from: picker.value)
            valueSelected = pickedValue
            print("PICKED VALUE: \(valueSelected)")
        })

        pickerStackView.addArrangedSubview(picker)
        
        let chooseDateButton = Button(title: "Välj datum",
                                      type: .standard(backgroundColor: .primaryTintColor,
                                                      textColor: .white))
        
        let loadableChooseDateButton = LoadableButton(button: chooseDateButton,
                                                  initialLoadingState: false)
        
        let activateNowButton = Button(title: "",
                                       type: .transparent(textColor: .primaryTintColor))
        
        let loadableActivateButton = LoadableButton(button: activateNowButton,
                                                    initialLoadingState: false)
        
        bag += actionStackView.addArranged(loadableChooseDateButton.wrappedIn(UIStackView()))
        bag += actionStackView.addArranged(loadableActivateButton.wrappedIn(UIStackView()))
        
        

        return (viewController, Future { completion in
            
            bag += loadableChooseDateButton.onTapSignal.onValue({ date in
                loadableChooseDateButton.isLoadingSignal.value = true
                print("Choosen date is: \(valueSelected)")
                bag += self.client.fetch(query: LastQuoteOfMemberQuery()).valueSignal.compactMap { $0.data?.lastQuoteOfMember.asCompleteQuote?.id
                }.mapLatestToFuture({ id in
                    self.client.perform(mutation: ChangeStartDateMutationMutation(id: id, startDate: valueSelected))
                }).onValue({ result in
                    print("IS: \(result)")
                    
                    bag += Signal(after: 0.5).onValue { _ in
                        loadableChooseDateButton.isLoadingSignal.value = false
                        completion(.success)
                    }
                    
                    self.store.update(query: HasStartDateQuery()) { (data: inout HasStartDateQuery.Data) in
                        data.lastQuoteOfMember.asCompleteQuote?.startDate = result.data?.editQuote.asCompleteQuote?.startDate
                    }
                })
            })
            
            bag += self.client.fetch(query: HasPreviousInsuranceQuery()).map{
                let previousInsuranceId = $0.data?.insurance.previousInsurer?.id
                
                if previousInsuranceId == nil {
                    activateNowButton.title.value = "Aktivera idag"

                    bag += loadableActivateButton.onTapSignal.onValue({ _ in
                        loadableActivateButton.isLoadingSignal.value = true
                        //DO STUFF
                        
                        
                        self.client.fetch(query: LastQuoteOfMemberQuery()).onValue { result in
                            guard let id = result.data?.lastQuoteOfMember.asCompleteQuote?.id else {return}
                            
                            self.client.perform(mutation: ChangeStartDateMutationMutation(id: id, startDate: today)).onValue { (result) in
                                print("TAPPED!")
                                print("TODAY: \(today)")
                                bag += Signal(after: 0.5).onValue({ _ in
                                    loadableActivateButton.isLoadingSignal.value = false
                                    completion(.success)
                                })
                                
                                self.store.update(query: HasStartDateQuery()) { (data: inout HasStartDateQuery.Data) in
                                    data.lastQuoteOfMember.asCompleteQuote?.startDate = result.data?.editQuote.asCompleteQuote?.startDate
                                }

                            }
                        }
                        
                    })
                } else {
                    activateNowButton.title.value = "Aktivera när din nuvarande försäkring går ut"
                    
                    bag += loadableActivateButton.onTapSignal.onValue({ _ in
                        loadableActivateButton.isLoadingSignal.value = true
                        
                        //DO STUFF REMOVESTARTDATE
                        self.client.fetch(query: LastQuoteOfMemberQuery()).onValue { (result) in
                            guard let memberID = result.data?.lastQuoteOfMember.asCompleteQuote?.id else {return}
                            
                            self.client.perform(mutation: RemoveStartDateMutation(id: memberID)).onValue { (result) in
                                print("Removed Startdate: \(result)")
                                bag += Signal(after: 0.5).onValue({ (_) in
                                    loadableActivateButton.isLoadingSignal.value = false
                                    completion(.success)
                                })
                            }
                            
                        }
                    })
                }
            }
            
            return bag
        })
    }
}
