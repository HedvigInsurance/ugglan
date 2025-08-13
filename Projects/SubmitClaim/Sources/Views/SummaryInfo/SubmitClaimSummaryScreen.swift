import Claims
import Kingfisher
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @StateObject fileprivate var vm: SubmitClaimSummaryScreenViewModel
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel

    public init(
        claimsNavigationVm: SubmitClaimNavigationViewModel
    ) {
        self.claimsNavigationVm = claimsNavigationVm
        _vm = StateObject(
            wrappedValue: SubmitClaimSummaryScreenViewModel(
                fileUploadStep: claimsNavigationVm.summaryModel?.fileUploadModel
            )
        )
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                hSection {
                    VStack(spacing: 0) {
                        matter
                        damageType
                        subtitle
                        selectedContractExposure
                        damageDate
                        place
                        model
                        dateOfPurchase
                        purchasePrice
                    }
                }
                .withHeader(title: L10n.changeAddressDetails)
                .padding(.top, .padding16)
                .sectionContainerStyle(.transparent)

                hSection {
                    hRowDivider()
                }
                memberFreeTextSection
                uploadedFilesView
            }
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    InfoCard(text: L10n.claimsComplementClaim, type: .info)
                        .accessibilitySortPriority(2)
                        .padding(.bottom, .padding8)
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.embarkSubmitClaim),
                        {
                            if let model = claimsNavigationVm.summaryModel {
                                Task {
                                    let step = await vm.summaryRequest(
                                        context: claimsNavigationVm.currentClaimContext ?? "",
                                        model: model
                                    )

                                    if let step {
                                        claimsNavigationVm.navigate(data: step)
                                    }
                                }
                            }
                        }
                    )
                    .disabled(vm.viewState == .loading)
                    .hButtonIsLoading(vm.viewState == .loading)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .claimErrorTrackerForState($vm.viewState)
    }

    @ViewBuilder
    private var matter: some View {
        createRow(with: L10n.claimsCase, and: claimsNavigationVm.summaryModel?.summaryStep?.title ?? "")
    }

    @ViewBuilder
    private var damageType: some View {
        let singleItemStep = claimsNavigationVm.summaryModel?.singleItemStepModel
        createRow(with: L10n.claimsDamages, and: singleItemStep?.getAllChoosenDamagesAsText())
    }

    @ViewBuilder
    private var subtitle: some View {
        if let subtitle = claimsNavigationVm.summaryModel?.summaryStep?.subtitle {
            createRow(with: L10n.claimsSummaryWhatIsAbout, and: subtitle)
        }
    }

    @ViewBuilder
    private var selectedContractExposure: some View {
        if let selectedContractExposure = claimsNavigationVm.summaryModel?.summaryStep?.selectedContractExposure {
            createRow(with: L10n.claimsSummaryDetailInfo, and: selectedContractExposure)
        }
    }

    @ViewBuilder
    private var damageDate: some View {
        let dateOfOccurenceStep = claimsNavigationVm.summaryModel?.dateOfOccurenceModel
        createRow(
            with: L10n.Claims.Item.Screen.Date.Of.Incident.button,
            and: dateOfOccurenceStep?.dateOfOccurence?.localDateToDate?.displayDateDDMMMYYYYFormat
        )
    }

    @ViewBuilder
    private var place: some View {
        let locationStep = claimsNavigationVm.summaryModel?.locationModel
        createRow(with: L10n.Claims.Location.Screen.title, and: locationStep?.getSelectedOption()?.displayName)
    }

    @ViewBuilder
    private var model: some View {
        let singleItemStep = claimsNavigationVm.summaryModel?.singleItemStepModel
        createRow(with: L10n.Claims.Item.Screen.Model.button, and: singleItemStep?.getBrandOrModelName())
    }

    @ViewBuilder
    private var dateOfPurchase: some View {
        let singleItemStep = claimsNavigationVm.summaryModel?.singleItemStepModel
        createRow(
            with: L10n.Claims.Item.Screen.Date.Of.Purchase.button,
            and: singleItemStep?.purchaseDate?.localDateToDate?.displayDateDDMMMYYYYFormat
        )
    }

    @ViewBuilder
    private var purchasePrice: some View {
        let singleItemStep = claimsNavigationVm.summaryModel?.singleItemStepModel
        createRow(
            with: L10n.Claims.Item.Screen.Purchase.Price.button,
            and: singleItemStep?.returnDisplayStringForSummaryPrice
        )
    }

    @ViewBuilder
    private var uploadedFilesView: some View {
        let audioRecordingStep = claimsNavigationVm.summaryModel?.audioRecordingModel
        if audioRecordingStep?.audioContent != nil || vm.model?.fileGridViewModel.files.count ?? 0 > 0 {
            hSection {
                VStack(spacing: .padding8) {
                    if let audioRecordingStep, audioRecordingStep.audioContent != nil {
                        let audioPlayer = AudioPlayer(url: audioRecordingStep.getUrl())
                        TrackPlayerView(
                            audioPlayer: audioPlayer
                        )
                    }
                    if let files = vm.model?.fileGridViewModel.files {
                        let fileGridVm = FileGridViewModel(files: files, options: [])
                        FilesGridView(vm: fileGridVm)
                    }
                }
            }
            .withHeader(title: L10n.ClaimStatusDetail.uploadedFiles)
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding8)
        }
    }

    @ViewBuilder
    func createRow(with title: String?, and value: String?) -> some View {
        if let title, let value {
            HStack(alignment: .top) {
                title.hText(.body1).foregroundColor(hTextColor.Opaque.secondary)
                Spacer()
                value.hText(.body1).foregroundColor(hTextColor.Opaque.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private var memberFreeTextSection: some View {
        let audioStep = claimsNavigationVm.summaryModel?.audioRecordingModel
        if let inputText = audioStep?.inputTextContent, audioStep?.optionalAudio == true {
            hSection {
                hRow {
                    hText(inputText)
                }
            }
            .withHeader(title: L10n.ClaimStatusDetail.submittedMessage)
            .padding(.top, .padding16)
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })
        Dependencies.shared.add(module: Module { () -> SubmitClaimClient in SubmitClaimClientDemo() })
        Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
        return SubmitClaimSummaryScreen(claimsNavigationVm: .init())
    }
}

@MainActor
class SubmitClaimSummaryScreenViewModel: ObservableObject {
    let model: FilesUploadViewModel?
    private let service = SubmitClaimService()
    @Published var viewState: ProcessingState = .success

    init(
        fileUploadStep: FlowClaimFileUploadStepModel?
    ) {
        if let fileUploadStep {
            model = FilesUploadViewModel(model: fileUploadStep)
        } else {
            model = nil
        }
    }

    @MainActor
    func summaryRequest(
        context: String,
        model: SubmitClaimStep.SummaryStepModels
    ) async -> SubmitClaimStepResponse? {
        withAnimation {
            viewState = .loading
        }
        do {
            let data = try await service.summaryRequest(context: context, model: model)

            withAnimation {
                viewState = .success
            }

            return data
        } catch let exception {
            withAnimation {
                viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
        return nil
    }
}
