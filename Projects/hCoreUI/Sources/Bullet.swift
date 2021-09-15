import Flow
import UIKit
import hCore
import SwiftUI

public struct Bullet {
    @ReadWriteState public var isSelected = false

    public init(isSelected: Bool) { self.isSelected = isSelected }

    public init(isSelectedSignal: ReadWriteSignal<Bool>) { _isSelected = .init(wrappedValue: isSelectedSignal) }
}

extension Bullet: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIControl, Disposable) {
        let bag = DisposeBag()

        let control = UIControl()
        control.layer.borderWidth = 1
        control.clipsToBounds = true
        control.backgroundColor = .clear

        let largeCircle = UIView()
        largeCircle.backgroundColor = .clear
        largeCircle.layer.borderWidth = 0

        control.snp.makeConstraints { $0.height.width.equalTo(24) }

        control.addSubview(largeCircle)

        largeCircle.snp.makeConstraints { make in make.edges.equalToSuperview() }

        bag += control.applyBorderColor { _ in .brand(.primaryBorderColor) }

        bag += largeCircle.applyBorderColor { _ in .brand(.primaryBackground(true)) }

        bag += control.didLayoutSignal.onValue {
            control.layer.cornerRadius = control.bounds.width / 2
            largeCircle.layer.cornerRadius = largeCircle.bounds.width / 2
        }

        bag += $isSelected.atOnce()
            .onValue { isSelected in
                UIView.transition(
                    with: largeCircle,
                    duration: 0.25,
                    options: .transitionCrossDissolve,
                    animations: { largeCircle.layer.borderWidth = isSelected ? 8 : 0 },
                    completion: nil
                )
            }

        return (control, bag)
    }
}

public struct BulletView: UIViewRepresentable {
    public var isSelected: Bool
    
    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public class Coordinator {
        let bag = DisposeBag()
        let isSelectedSignal: ReadWriteSignal<Bool>
        let bullet: Bullet

        init(
            isSelectedSignal: ReadWriteSignal<Bool>
        ) {
            self.isSelectedSignal = isSelectedSignal
            self.bullet = Bullet(isSelectedSignal: isSelectedSignal)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(isSelectedSignal: .init(false))
    }

    public func makeUIView(context: Context) -> some UIView {
        let (view, disposable) = context.coordinator.bullet.materialize(
            events: ViewableEvents(wasAddedCallbacker: .init())
        )
        context.coordinator.isSelectedSignal.value = isSelected
        context.coordinator.bag += disposable
        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.isSelectedSignal.value = isSelected
    }
}
