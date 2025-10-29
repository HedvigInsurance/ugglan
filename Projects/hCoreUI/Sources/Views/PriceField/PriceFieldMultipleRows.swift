import SwiftUI

public struct PriceFieldMultipleRows: View {
    let viewModels: [PriceFieldModel]
    public init(
        viewModels: [PriceFieldModel]
    ) {
        self.viewModels = viewModels
    }
    public var body: some View {
        hSection(viewModels) { viewModel in
            hRow {
                PriceField(viewModel: viewModel)
            }
        }
        .hWithoutHorizontalPadding([.all])
        .sectionContainerStyle(.transparent)
    }
}
