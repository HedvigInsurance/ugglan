import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

public struct HomeVerticalSection {
    @Inject var client: ApolloClient

    let section: HomeSection

    public init(section: HomeSection) {
        self.section = section
    }
}

extension HomeVerticalSection: Viewable {
    public func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let sectionView = SectionView()
        sectionView.dynamicStyle = .brandGrouped(separatorType: .none)

        let titleLabel = MultilineLabel(
            value: section.title,
            style: .brand(.title2(color: .primary))
        )
        bag += sectionView.append(titleLabel)

        let stackView = UIStackView()
        stackView.axis = .horizontal

        sectionView.appendSpacing(.inbetween)

        section.children.forEach { child in
            let row = RowView.titleAndIconRowView(title: child.title, icon: child.icon)
            bag += sectionView.append(row).onValue {
                guard let viewController = sectionView.viewController else { return }
                child.handler(viewController)
            }
        }

        return (sectionView, bag)
    }
}

private extension RowView {
    static func titleAndIconRowView(title: String, icon: UIImage) -> RowView {
        let row = RowView(
            title: title,
            subtitle: "",
            style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
                style.title = .brand(.headline(color: .primary))
                style.subtitle = .brand(.subHeadline(color: .secondary))
            }
        )

        row.backgroundColor = .brand(.secondaryBackground())
        row.layer.cornerRadius = 8

        let imageView = UIImageView()
        imageView.image = icon
        imageView.contentMode = .scaleAspectFit
        row.prepend(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        return row
    }
}
