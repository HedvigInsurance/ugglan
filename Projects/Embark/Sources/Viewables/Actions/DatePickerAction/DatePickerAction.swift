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
    func materialize(events _: ViewableEvents) -> (UIStackView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        
        let control = UIControl()
        let bag = DisposeBag()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        
        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label
        
        let placeHolderLabel = UILabel()
        placeHolderLabel.style = .brand(.body(color: .secondary))
        placeHolderLabel.text = "Select Date"
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = hCoreUIAssets.menuIcon.image
        imageView.tintColor = .brand(.tertiaryText)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(placeHolderLabel)
        stackView.addArrangedSubview(imageView)
        
        control.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let datePicker = UIDatePicker()
        datePicker.maximumDate = Date()
        datePicker.calendar = Calendar.current
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        
        view.addArrangedSubview(datePicker)
        view.addArrangedSubview(control)
        
        return (view, Signal { callback in
            
            bag += control.signal(for: .touchDown).onValue {
                
            }
            
            callback(data.next.fragments.embarkLinkFragment)
            
            return bag
        })
    }
}
