import hGraphQL
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
