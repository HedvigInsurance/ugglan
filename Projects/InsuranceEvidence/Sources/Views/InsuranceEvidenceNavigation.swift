import SwiftUI
import hCore
import hCoreUI

@MainActor
class InsuranceEvidenceNavigationViewModel: ObservableObject {
    let service = InsuranceEvidenceService()
    lazy fileprivate var insuranceEvidenceInputScreenViewModel = InsuranceEvidenceInputScreenViewModel(
        InsuranceEvidenceNavigationViewModel: self
    )
    let router = Router()
}

public struct InsuranceEvidenceNavigation: View {
    @State private var vm = InsuranceEvidenceNavigationViewModel()
    @EnvironmentObject var router: Router
    public init() {}

    public var body: some View {
        RouterHost(router: vm.router, tracking: self) {
            InsuranceEvidenceInputScreen(
                vm: vm.insuranceEvidenceInputScreenViewModel
            )
            .routerDestination(for: InsuranceEvidenceNavigationRouterType.self, options: [.hidesBackButton]) { type in
                switch type {
                case .processing(let input):
                    let processingViewModel = ProcessingViewModel(input: input, navigation: vm)
                    InsuranceEvidenceProcessingScreen(vm: processingViewModel)
                }
            }
            .withDismissButton()
        }
    }
}

extension InsuranceEvidenceNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: InsuranceEvidenceInputScreen.self)
    }
}

enum InsuranceEvidenceNavigationRouterType: Hashable, TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .processing:
            return .init(describing: InsuranceEvidenceInputScreen.self)
        }
    }

    case processing(input: InsuranceEvidenceInput)
}
