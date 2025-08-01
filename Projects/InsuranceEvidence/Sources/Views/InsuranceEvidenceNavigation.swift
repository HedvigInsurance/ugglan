import SwiftUI
import hCore
import hCoreUI

@MainActor
class InsuranceEvidenceNavigationViewModel: ObservableObject {
    let service = InsuranceEvidenceService()
    @Published var isInfoViewPresented = false
    fileprivate lazy var insuranceEvidenceInputScreenViewModel = InsuranceEvidenceInputScreenViewModel(
        InsuranceEvidenceNavigationViewModel: self
    )
    let router = Router()
}

public struct InsuranceEvidenceNavigation: View {
    @StateObject private var vm = InsuranceEvidenceNavigationViewModel()
    @EnvironmentObject var router: Router
    public init() {}

    public var body: some View {
        RouterHost(router: vm.router, tracking: self) {
            InsuranceEvidenceInputScreen(
                vm: vm.insuranceEvidenceInputScreenViewModel
            )
            .routerDestination(for: InsuranceEvidenceNavigationRouterType.self, options: [.hidesBackButton]) { type in
                switch type {
                case let .processing(input):
                    let processingViewModel = ProcessingViewModel(input: input, navigation: vm)
                    InsuranceEvidenceProcessingScreen(vm: processingViewModel)
                }
            }
            .withDismissButton()
        }
        .detent(
            presented: $vm.isInfoViewPresented,

            options: .constant(.withoutGrabber)
        ) {
            InfoView(
                title: L10n.InsuranceEvidence.readMoreTitle,
                description: L10n.InsuranceEvidence.readMoreDescription
            )
        }
    }
}

extension InsuranceEvidenceNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: InsuranceEvidenceInputScreen.self)
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
