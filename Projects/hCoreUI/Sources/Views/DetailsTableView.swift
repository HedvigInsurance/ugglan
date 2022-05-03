import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hCore
import hGraphQL

public struct DetailAgreementsTableView: View {
    var table: DetailAgreementsTable

    public var body: some View {
        ForEach(table.sections, id: \.hashValue) { section in
            hSection(section.rows, id: \.title) { row in
                hRow {
                    VStack {
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
                hText(section.title)
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
