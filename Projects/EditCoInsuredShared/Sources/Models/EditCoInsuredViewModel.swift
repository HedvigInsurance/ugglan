import Foundation

public class EditCoInsuredViewModel: ObservableObject {
    @Published public var editCoInsuredModelDetent: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelFullScreen: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelMissingAlert: InsuredPeopleConfig?

    public init() {}
}

public struct EditCoInsuredNavigationModel: Equatable, Identifiable {
    public var contractsSupportingCoInsured: [InsuredPeopleConfig]

    public init(
        contractsSupportingCoInsured: () -> [InsuredPeopleConfig]
    ) {
        self.contractsSupportingCoInsured = contractsSupportingCoInsured()
    }

    public var id: String = UUID().uuidString
}

public enum EditCoInsuredRedirectType: Hashable {
    case checkForAlert
}
