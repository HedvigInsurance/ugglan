import Apollo
import Flow
import Form
import Foundation
import SafariServices
import hCore
import hCoreUI
import hGraphQL

struct ImportantMessagesSection { @Inject var client: ApolloClient }

extension ImportantMessagesSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let outerSection = SectionView()

        let sectionView = SectionView()
        sectionView.dynamicStyle = .brandGroupedCaution
        outerSection.append(sectionView)

        client.fetch(query: GraphQL.ImportantMessagesQuery(langCode: Localization.Locale.currentLocale.code))
            .compactMap { $0.importantMessages.first }.compactMap { $0 }
            .onValue { importantMessage in let row = RowView()
                bag += row.append(
                    MultilineLabel(
                        value: importantMessage.message ?? "",
                        style: .brand(.subHeadline(color: .secondary(state: .positive)))
                    )
                )

                let chevronImageView = UIImageView()
                chevronImageView.tintColor = .black
                chevronImageView.image = hCoreUIAssets.chevronRight.image

                row.append(chevronImageView)

                chevronImageView.snp.makeConstraints { make in
                    make.width.equalTo(hCoreUIAssets.chevronRight.image.size.width)
                }

                bag += sectionView.append(row).compactMap { row.viewController }
                    .onValue { viewController in
                        guard let url = URL(string: importantMessage.link) else { return }
                        let safariViewController = SFSafariViewController(url: url)
                        safariViewController.modalPresentationStyle = .formSheet
                        viewController.present(safariViewController, animated: true)
                    }

                outerSection.appendSpacing(.top)
            }

        return (outerSection, bag)
    }
}
