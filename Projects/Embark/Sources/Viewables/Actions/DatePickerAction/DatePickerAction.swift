import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL
import hCoreUI

typealias EmbarkDatePickerActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkDatePickerAction

struct EmbarkDatePickerAction {
    let state: EmbarkState
    let data: EmbarkDatePickerActionData
}

extension EmbarkDatePickerAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let bag = DisposeBag()
        
        let mainView = UIStackView()
        mainView.axis = .vertical
        mainView.distribution = .fill
        mainView.spacing = 16
        
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 8
        view.edgeInsets = .init(top: 20, left: 16, bottom: 20, right: 0)
        
        let box = UIView()
        box.backgroundColor = .brand(.secondaryBackground())
        box.layer.cornerRadius = 8
        bag += box.applyShadow { _ -> UIView.ShadowProperties in .embark }
        
        let containerView = UIView()
        containerView.backgroundColor = .brand(.secondaryBackground())
        containerView.layer.cornerRadius = 8
            
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.edgeInsets = .init(top: 0, left: 0, bottom: 10, right: 16)
        
        let datePicker = UIDatePicker()
        datePicker.minimumDate = Date()
        datePicker.calendar = Calendar.current
        datePicker.datePickerMode = .date
        datePicker.tintColor = .brand(.link)
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.date = Date()
        
        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label
        
        let placeHolderLabel = UILabel()
        placeHolderLabel.style = .brand(.body(color: .link))
        placeHolderLabel.textAlignment = .right
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(placeHolderLabel)
     
        bag += datePicker.atOnce().onValue { date in
            placeHolderLabel.text = date.localDateString
        }
        
        let divider = UIView()
        divider.backgroundColor = .brand(.primaryBorderColor)
        divider.snp.makeConstraints { make in make.height.equalTo(1) }
        
        view.addArrangedSubview(stackView)
        view.addArrangedSubview(divider)
        view.addArrangedSubview(datePicker)
        
        containerView.addSubview(box)
        box.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        containerView.addSubview(view)
        view.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        
        let button = Button(
            title: L10n.generalContinueButton,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )
        
        mainView.addArrangedSubview(containerView)
        bag += mainView.addArranged(button)
        
        return (mainView, Signal { callback in
            
            bag += button.onTapSignal.onValue {
                self.state.store.setValue(key: data.storeKey, value: datePicker.date.localDateString)
                
                if let passageName = self.state.passageNameSignal.value {
                    self.state.store.setValue(
                        key: "\(passageName)Result",
                        value: datePicker.date.localDateString
                    )
                }
                                
                self.state.store.createRevision()
                
                callback(data.next.fragments.embarkLinkFragment)
            }
    
            return bag
        })
    }
}
