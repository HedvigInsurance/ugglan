import Kingfisher
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @StateObject fileprivate var vm: SubmitClaimSummaryScreenViewModel
    @ObservedObject var claimsNavigationVm: ClaimsNavigationViewModel

    public init(
        claimsNavigationVm: ClaimsNavigationViewModel
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
            VStack(spacing: 16) {
                hSection {
                    VStack(spacing: 0) {
                        matter
                        damageType
                        damageDate
                        place
                        model
                        dateOfPurchase
                        purchasePrice
                    }
                }
                .withHeader {
                    HStack {
                        L10n.changeAddressDetails.hText(.body1).foregroundColor(hTextColor.Opaque.primary)
                            .padding(.top, .padding16)
                    }
                }
                .sectionContainerStyle(.transparent)
                .accessibilityElement(children: .combine)

                hSection {
                    hRowDivider()
                }
                memberFreeTextSection
                uploadedFilesView

            }
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    InfoCard(text: L10n.claimsComplementClaim, type: .info)
                        .padding(.bottom, .padding8)
                    hButton.LargeButton(type: .primary) {
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
                    } content: {
                        hText(L10n.embarkSubmitClaim)
                    }
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
                VStack(spacing: 8) {
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
            .withHeader {
                hText(L10n.ClaimStatusDetail.uploadedFiles)
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    func createRow(with title: String?, and value: String?) -> some View {
        if let title, let value {
            HStack {
                title.hText(.body1).foregroundColor(hTextColor.Opaque.secondary)
                Spacer()
                value.hText(.body1).foregroundColor(hTextColor.Opaque.secondary)
            }
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
            .withHeader {
                hText(L10n.ClaimStatusDetail.submittedMessage)
                    .padding(.leading, 2)
            }
            .padding(.top, .padding16)
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen(claimsNavigationVm: .init())
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
            self.model = FilesUploadViewModel(model: fileUploadStep)
        } else {
            self.model = nil
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
