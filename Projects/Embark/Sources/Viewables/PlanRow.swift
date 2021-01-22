import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct PlanRow: Equatable, Hashable {
    static func == (lhs: PlanRow, rhs: PlanRow) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(discount)
        hasher.combine(message)
    }
    
    let title: String
    let discount: String?
    let message: String
    let isSelected: ReadWriteSignal<Bool>
}

extension PlanRow: Reusable {
    
    static func makeAndConfigure() -> (make: UIView, configure: (PlanRow) -> Disposable) {
        
        let view = UIStackView()
        view.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        view.insetsLayoutMarginsFromSafeArea = true
        
        let contentView = UIControl()
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = .defaultCornerRadius
        contentView.layer.borderWidth = .hairlineWidth
        contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(124) }
        
        view.addArrangedSubview(contentView)
        
        let horizontalContentContainer = UIStackView()
        horizontalContentContainer.axis = .horizontal
        horizontalContentContainer.spacing = 10
        horizontalContentContainer.alignment = .firstBaseline
       
        let verticalContentContainer = UIStackView()
        verticalContentContainer.isUserInteractionEnabled = false
        verticalContentContainer.axis = .vertical
        verticalContentContainer.distribution = .fill
        verticalContentContainer.edgeInsets = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        verticalContentContainer.spacing = 20
        
        verticalContentContainer.addArrangedSubview(horizontalContentContainer)
        
        let titleLabel = UILabel(value: "", style: .brand(.title2(color: .primary)))
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        horizontalContentContainer.addArrangedSubview(titleLabel)
        
        contentView.addSubview(verticalContentContainer)
        
        verticalContentContainer.snp.makeConstraints { $0.top.bottom.trailing.leading.equalToSuperview() }
        
        return (view, { `self` in
            let bag = DisposeBag()
        
            titleLabel.value = self.title
            
            bag += contentView.applyBorderColor { _ in
                .brand(.primaryBorderColor)
            }
            
            bag += contentView.signal(for: .touchUpInside).map {
                return true
            }.bindTo(self.isSelected)
            
            let descriptionLabel = MultilineLabel(
                value: self.message,
                style: .brand(.body(color: .primary)))
            
            let checkmark = Bullet(isSelectedSignal: self.isSelected)
            
            bag += verticalContentContainer.addArranged(descriptionLabel)
            
            let gradientView = GradientView(
                gradientOption: .init(preset: .insuranceThree, traitCollection: view.traitCollection),
                signal: self.isSelected)
            
            bag += contentView.add(gradientView) { view in
                contentView.sendSubviewToBack(view)
                view.snp.makeConstraints { (make) in
                    make.top.bottom.trailing.leading.equalToSuperview()
                }
            }
            
            if let discount = self.discount {
                let tintColor = UIColor.brand(.primaryBackground(true))
                bag += horizontalContentContainer.addArranged(
                    PillCollection(
                        pills: [.make(
                                    Pill(
                                        tintColor: tintColor,
                                        title: discount,
                                        textStyle: .brand(.caption1(color: .primary(state: .matching(tintColor))))))
                        ]
                    ).wrappedIn({
                        let stack = UIStackView()
                        stack.axis = .vertical
                        return stack
                    }())
                )
            }
            
            horizontalContentContainer.addArrangedSubview(UIView())
           
            bag += horizontalContentContainer.addArranged(checkmark.wrappedIn({
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.setContentHuggingPriority(.required, for: .horizontal)
                return stackView
            }()))
            
            return bag
        })
    }
}
