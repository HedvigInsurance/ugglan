import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct HomeVerticalSection {
    @Inject var client: ApolloClient

    let section: HomeSection

    public init(
        section: HomeSection
    ) {
        self.section = section
    }
}

extension HomeVerticalSection: Viewable {
    public func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let sectionView = SectionView(
            headerView: UILabel(value: section.title, style: .default),
            footerView: nil
        )
        sectionView.dynamicStyle = .brandGroupedInset(separatorType: .standard)

        section.children.forEach { child in
            let row = RowView.titleAndIconRowView(title: child.title, icon: child.icon)
            bag += sectionView.append(row)
                .onValue {
                    child.handler()
                }
        }

        return (sectionView, bag)
    }
}

extension RowView {
    fileprivate static func titleAndIconRowView(title: String, icon: UIImage) -> RowView {
        let row = RowView(
            title: title,
            subtitle: "",
            style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
                style.title = .brand(.headline(color: .primary))
                style.subtitle = .brand(.subHeadline(color: .secondary))
            }
        )

        let imageView = UIImageView()
        imageView.image = icon
        imageView.contentMode = .scaleAspectFit
        row.prepend(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        row.append(UIImageView(image: hCoreUIAssets.chevronRight.image))

        return row
    }
}
