import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hCore
import hGraphQL

public struct DetailAgreementsTableView: View {
    var table: DetailAgreementsTable

    var hasTitle: Bool {
        table.title.count > 0
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if hasTitle {
                    hText(table.title, style: .title3)
                        .padding(.leading, 15)
                }

                ForEach(table.sections, id: \.hashValue) { section in
                    hSection(section.rows, id: \.title) { row in
                        hRow {
                            VStack(alignment: .leading) {
                                hText(row.title, style: .body)
                                    .foregroundColor(hTextColor.primary)

                                if let subtitle = row.subtitle {
                                    hText(subtitle, style: .subheadline)
                                        .foregroundColor(hTextColor.secondary)
                                }
                            }
                        }
                        .withCustomAccessory {
                            Spacer()
                            VStack {
                                hText(row.value, style: .body)
                                    .foregroundColor(hTextColor.secondary)
                            }
                        }
                        .noHorizontalPadding()
                    }
                    .withHeader {
                        if hasTitle {
                            hText(
                                section.title,
                                style: .headline
                            )
                            .foregroundColor(hTextColor.secondary)
                        } else {
                            hText(section.title)
                                .padding(.bottom, -8)
                        }

                    }
                    .sectionContainerStyle(.transparent)

                }
            }
            .padding(.top, 8)
        }
    }
}

struct Previews_DetailAgreementsTableView: PreviewProvider {
    static var previews: some View {
        DetailAgreementsTableView(
            table: DetailAgreementsTable(
                sections: [
                    .init(
                        title: "TITLE",
                        rows: [
                            .init(title: "TITLE 1", subtitle: nil, value: "value 1"),
                            .init(title: "TITLE 2", subtitle: "subtitle 2", value: "value 2"),
                        ]
                    )
                ],
                title: "Mock title"
            )
        )
    }
}

extension DetailAgreementsTable {
    public var view: DetailAgreementsTableView {
        DetailAgreementsTableView(table: self)
    }
}
