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
    let perilsDataSignal: ReadWriteSignal<DashboardQuery.Data.Insurance.PerilCategory?> = ReadWriteSignal(nil)
    let index: Int
    let presentingViewController: UIViewController

    init(index: Int, presentingViewController: UIViewController) {
        self.index = index
        self.presentingViewController = presentingViewController
    }
}

enum PerilCategoryIcon: Int {
    case coinsured = 0
    case home = 1
    case items = 2
}

extension PerilCategoryIcon {
    var image: ImageAsset {
        switch self {
        case .coinsured: return Asset.coinsuredPlain
        case .home: return Asset.homePlain
        case .items: return Asset.itemsPlain
        }
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

        if let imageAsset = PerilCategoryIcon(rawValue: index)?.image {
            contentView.imageSignal.value = imageAsset
        } else {
            contentView.imageSignal.value = Asset.moreInfoPlain
        }

        let expandedContentView = PerilCollection(presentingViewController: presentingViewController)
        bag += perilsDataSignal.atOnce()
            .bindTo(expandedContentView.perilsDataSignal)

        let expandableView = ExpandableRow(content: contentView, expandedContent: expandedContentView)
        bag += expandableView.isOpenSignal.bindTo(contentView.isOpenSignal)

        return (expandableView, bag)
    }
}
