//
//  AttachGIFPane.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-30.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct AttachGIFPane {
    let isOpenSignal: ReadWriteSignal<Bool>
    let chatState: ChatState
    @Inject var client: ApolloClient

    init(isOpenSignal: ReadWriteSignal<Bool>,
         chatState: ChatState) {
        self.isOpenSignal = isOpenSignal
        self.chatState = chatState
    }
}

extension AttachGIFPane: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()

        bag += isOpenSignal.atOnce().map { !$0 }.animated(style: SpringAnimationStyle.lightBounce(),
                                                          animations: { isHidden in
                                                              view.animationSafeIsHidden = isHidden
                                                              view.layoutSuperviewsIfNeeded()
        })

        view.backgroundColor = .clear

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(horizontalInset: 15,
                                           verticalInset: 10)

        let collectionKit = CollectionKit<EmptySection, AttachGIFImage>(
            table: Table(rows: []),
            layout: layout
        )

        collectionKit.view.contentInset = UIEdgeInsets(top: 0,
                                                       left: 5,
                                                       bottom: 0,
                                                       right: 5)
        collectionKit.view.backgroundColor = .clear
        bag.hold(collectionKit)

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            let height = collectionKit.view.frame.height
            return CGSize(width: height, height: height)
        }

        let infoText = MultilineLabel(styledText: .init(text: L10n.labelSearchGif,
                                                        style: .centeredBody))
        let searchBar = TextView(placeholder: L10n.searchBarGif)

        let (searchBarView, searchBarValue) = searchBar.materialize(events: events)

        bag += searchBarValue.onValue { _ in }

        let searchBarContainer = UIStackView()
        searchBarContainer.addArrangedSubview(searchBarView)

        view.addSubview(searchBarContainer)

        searchBarContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }

        searchBarView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
        }

        view.addSubview(collectionKit.view)
        collectionKit.view.snp.makeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom).offset(10)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        bag += view.add(infoText) { labelView in
            labelView.snp.makeConstraints { make in
                labelView.textColor = .darkGray
                make.top.equalTo(searchBarView.snp.bottom).offset(10)
                make.left.equalTo(view).offset(10)
                make.right.bottom.equalTo(view).offset(-10)

                bag += searchBarValue.map { string -> Bool in
                    string.count == 0
                }.onValue { isEmpty in
                    if isEmpty {
                        labelView.alpha = 1
                    } else {
                        labelView.alpha = 0
                    }
                }
            }
        }

        bag += isOpenSignal.onValue { isOpen in
            if !isOpen {
                searchBarValue.value = ""
            }
        }

        bag += searchBarValue.mapLatestToFuture { value in
            self.client.fetch(query: GifQuery(query: value))
        }.compactMap { result in
            result.data?.gifs.compactMap { $0 }
        }.onValue { gifs in
            let attachGIFImages = gifs.compactMap { gif -> AttachGIFImage? in
                guard let url = URL(string: gif.url) else {
                    return nil
                }

                return AttachGIFImage(url: url, chatState: self.chatState)
            }
            collectionKit.table = Table(rows: attachGIFImages)
        }

        bag += collectionKit.onValueDisposePrevious { table -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += table.map { gifImage in
                gifImage.uploadGifDelegate.set { url -> Signal<Void> in

                    Signal { callback in
                        let signalBag = DisposeBag()
                        signalBag += self.chatState.sendChatFreeTextResponse(text: url).onValue { _ in
                            self.isOpenSignal.value = false
                            callback(())
                        }

                        return signalBag
                    }
                }
            }

            return innerBag
        }

        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(300)
            }
        }
        return (view, bag)
    }
}
