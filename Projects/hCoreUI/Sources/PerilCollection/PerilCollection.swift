import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PerilCollection {
    let perilSignal: ReadSignal<[Perils]>

    public init(
        perilSignal: ReadSignal<[Perils]>
    ) {
        self.perilSignal = perilSignal
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size)
            .map {
                Array(self[$0..<Swift.min($0 + size, count)])
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

        bag += perilSignal.atOnce()
            .onValueDisposePrevious { perilFragments in
                return perilFragments.chunked(into: 2)
                    .map { perils -> DisposeBag in
                        let rowContainer = UIView()

                        let innerBag = DisposeBag()

                        innerBag += perils.enumerated()
                            .map { (offset, peril) in
                                let (row, disposable) = PerilRow(
                                    peril: peril
                                )
                                .reuseTypeAndDisposable()
                                rowContainer.addSubview(row)

                                row.snp.makeConstraints { make in
                                    make.width.equalToSuperview().dividedBy(2)
                                        .inset(2.5)

                                    if offset == 0 {
                                        make.leading.equalToSuperview()
                                    } else {
                                        make.trailing.equalToSuperview()
                                    }

                                    make.top.bottom.equalToSuperview()
                                }

                                return disposable
                            }

                        stackView.addArrangedSubview(rowContainer)

                        innerBag += {
                            rowContainer.removeFromSuperview()
                        }

                        return innerBag
                    }
                    .disposable
            }

        return (stackView, bag)
    }
}
