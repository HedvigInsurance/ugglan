//
//  PerilLargeIconSubtitle.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-08.
//

import Flow
import Form
import Foundation

struct PerilExpandableRow {
    let perilsDataSignal: ReadWriteSignal<PerilCategoryFragment?> = ReadWriteSignal(nil)
    let perilsCategory: PerilsCategory
    let presentingViewController: UIViewController
    
    enum PerilsCategory {
        case home, me, stuff
        
        var image: ImageAsset {
            switch self {
            case .me: return Asset.coinsuredPlain
            case .home: return Asset.homePlain
            case .stuff: return Asset.itemsPlain
            }
        }
    }

    init(perilsCategory: PerilsCategory, presentingViewController: UIViewController) {
        self.perilsCategory = perilsCategory
        self.presentingViewController = presentingViewController
    }
}

extension PerilExpandableRow: Viewable {
    func materialize(events _: ViewableEvents) -> (ExpandableRow<LargeIconTitleSubtitle, PerilCollection>, Disposable) {
        let bag = DisposeBag()

        let contentView = LargeIconTitleSubtitle()

        bag += perilsDataSignal.atOnce()
            .filter { $0?.title != nil }
            .map { $0!.title! }
            .bindTo(contentView.titleSignal)

        bag += perilsDataSignal.atOnce()
            .filter { $0?.description != nil }
            .map { $0!.description! }
            .bindTo(contentView.subtitleSignal)

        contentView.imageSignal.value = perilsCategory.image

        let expandedContentView = PerilCollection(presentingViewController: presentingViewController)
        bag += perilsDataSignal.atOnce()
            .bindTo(expandedContentView.perilsDataSignal)

        let expandableView = ExpandableRow(content: contentView, expandedContent: expandedContentView)
        bag += expandableView.isOpenSignal.bindTo(contentView.isOpenSignal)

        return (expandableView, bag)
    }
}
