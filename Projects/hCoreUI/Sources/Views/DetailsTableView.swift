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
                    }

                }
            }
        }
    }
}

struct Previews_DetailAgreementsTableView: PreviewProvider {
    static var previews: some View {
        DetailAgreementsTableView(
            table: DetailAgreementsTable(sections: [], title: "Mock title")
        )
    }
}

extension DetailAgreementsTable {
    public var view: DetailAgreementsTableView {
        DetailAgreementsTableView(table: self)
    }
}
