import Flow
import Form
import Presentation
import UIKit
import hCore
import hGraphQL
import SwiftUI

public struct DetailAgreementsTableView: View {
    var table: DetailAgreementsTable
    
    public var body: some View {
        ForEach(table.sections, id: \.hashValue) { section in
            hSection(header: hText(section.title)) {
                ForEach(section.rows, id: \.value) { row in
                    hRow {
                        VStack {
                            hText(row.title, style: .body)
                                .foregroundColor(hLabelColor.primary)
                            
                            if let subtitle = row.subtitle {
                                hText(subtitle, style: .subheadline)
                                    .foregroundColor(hLabelColor.secondary)
                            }
                        }
                    }.withCustomAccessory {
                        Spacer()
                        VStack {
                            hText(row.value, style: .body)
                                .foregroundColor(hLabelColor.secondary)
                        }
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
