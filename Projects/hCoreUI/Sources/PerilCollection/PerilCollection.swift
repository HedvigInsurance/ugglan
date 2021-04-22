import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

public struct PerilCollection {
    let perilFragmentsSignal: ReadSignal<[GraphQL.PerilFragment]>

    public init(perilFragmentsSignal: ReadSignal<[GraphQL.PerilFragment]>) {
        self.perilFragmentsSignal = perilFragmentsSignal
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension PerilCollection: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let stackView = UIStackView()
        stackView.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        stackView.axis = .vertical
        stackView.spacing = 8
        let bag = DisposeBag()
        
        bag += perilFragmentsSignal.atOnce().onValueDisposePrevious { perilFragments in
            return perilFragments.chunked(into: 2).map { perils -> DisposeBag in
                let rowStackView = UIStackView()
                rowStackView.spacing = 9
                rowStackView.distribution = .fillEqually
                
                let innerBag = DisposeBag()
                
                innerBag += perils.map { perilFragment in
                    let (row, disposable) = PerilRow(fragment: perilFragment).reuseTypeAndDisposable()
                    rowStackView.addArrangedSubview(row)
                    return disposable
                }
                
                if perils.count == 1 {
                    rowStackView.addArrangedSubview(UIView())
                }
                
                stackView.addArrangedSubview(rowStackView)
                
                innerBag += {
                    rowStackView.removeFromSuperview()
                }
                
                return innerBag
            }.disposable
        }
    
        return (stackView, bag)
    }
}
