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
                                    .foregroundColor(hLabelColor.primary)

                                if let subtitle = row.subtitle {
                                    hText(subtitle, style: .subheadline)
                                        .foregroundColor(hLabelColor.secondary)
                                }
                            }
                        }
                        .withCustomAccessory {
                            Spacer()
                            VStack {
                                hText(row.value, style: .body)
                                    .foregroundColor(hLabelColor.secondary)
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
                            .foregroundColor(hLabelColor.secondary)
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

public struct DetailAgreementsTable: Codable, Hashable, Identifiable {
    public init(
        sections: [DetailAgreementsTable.Section],
        title: String
    ) {
        self.sections = sections
        self.title = title
    }

    public var id: String {
        return title
    }
    public let sections: [Section]
    public let title: String
    public init(
        fragment: GiraffeGraphQL.DetailsTableFragment
    ) {
        sections = fragment.sections.map { .init(section: $0) }
        title = fragment.title
    }

    public struct Section: Codable, Hashable, Identifiable {
        public init(
            title: String,
            rows: [DetailAgreementsTable.Row]
        ) {
            self.title = title
            self.rows = rows
        }

        public var id: String {
            return title
        }
        public let title: String
        public let rows: [Row]

        init(
            section: GiraffeGraphQL.DetailsTableFragment.Section
        ) {
            title = section.title
            rows = section.rows.map { .init(row: $0) }
        }
    }

    public struct Row: Codable, Hashable {
        public init(
            title: String,
            subtitle: String?,
            value: String
        ) {
            self.title = title
            self.subtitle = subtitle
            self.value = value
        }

        public let title: String
        public let subtitle: String?
        public let value: String
        init(
            row: GiraffeGraphQL.DetailsTableFragment.Section.Row
        ) {
            title = row.title
            subtitle = row.subtitle
            value = row.value
        }
    }
}
