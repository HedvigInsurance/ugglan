import Combine
import Home
import Kingfisher
import Photos
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    @State var player: AudioPlayer?
    @State var showImagePicker = false
    @State var showFilePicker = false
    @State var showCamera = false
    @StateObject var vm: ClaimDetailViewModel

    @EnvironmentObject var homeVm: HomeNavigationViewModel

    public init(
        claim: ClaimModel
    ) {
        self._vm = .init(wrappedValue: .init(claim: claim))
        if let url = URL(string: claim.signedAudioURL) {
            self._player = State(initialValue: AudioPlayer(url: url))
        }
    }

    private var statusParagraph: String {
        vm.claim.statusParagraph
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    ClaimStatus(claim: vm.claim, enableTap: false)
                        .padding(.top, 8)
                }
                .sectionContainerStyle(.transparent)

                infoAndContactSection
                memberFreeTextSection
                claimDetailsSection
                    .padding(.vertical, 16)
                uploadFilesSection
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { images in
                vm.showAddFiles(with: images)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showFilePicker) {
            FileImporterView { files in
                vm.showAddFiles(with: files)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView { image in
                guard let data = image.jpegData(compressionQuality: 0.9),
                    let thumbnailData = image.jpegData(compressionQuality: 0.1)
                else { return }
                let file: FilePickerDto = .init(
                    id: UUID().uuidString,
                    size: Double(data.count),
                    mimeType: .JPEG,
                    name: "image_\(Date()).jpeg",
                    data: data,
                    thumbnailData: thumbnailData
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.showAddFiles(with: [file])
                }

            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var infoAndContactSection: some View {
        hSection {
            hRow {
                hText(statusParagraph)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            hRow {
                ContactChatView(
                    store: vm.store,
                    id: vm.claim.id,
                    status: vm.claim.status.rawValue
                )
                .padding(.bottom, 4)
            }
        }
    }

    @ViewBuilder
    private var memberFreeTextSection: some View {
        if let inputText = vm.claim.memberFreeText {
            hSection {
                hRow {
                    hText(inputText)
                }
            }
            .withHeader {
                hText(L10n.ClaimStatusDetail.submittedMessage)
                    .padding(.leading, 2)
            }
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var claimDetailsSection: some View {
        VStack(spacing: 16) {
            hSection {
                VStack(spacing: 8) {
                    claimDetailsRow(title: L10n.ClaimStatus.ClaimDetails.type, value: vm.claim.claimType)
                    if let incidentDate = vm.claim.incidentDate {
                        claimDetailsRow(
                            title: L10n.ClaimStatus.ClaimDetails.incidentDate,
                            value: incidentDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        )
                    }
                    if let submitted = vm.claim.submittedAt {
                        claimDetailsRow(
                            title: L10n.ClaimStatus.ClaimDetails.submitted,
                            value: submitted.localDateToIso8601Date?.displayDateDDMMMYYYYFormat ?? ""
                        )
                    }
                }
            }
            .withHeader {
                HStack {
                    hText(L10n.ClaimStatus.ClaimDetails.title)
                    Spacer()
                    InfoViewHolder(
                        title: L10n.ClaimStatus.ClaimDetails.title,
                        description: L10n.ClaimStatus.ClaimDetails.infoText
                    )
                }
            }
            .hWithoutDivider
            .sectionContainerStyle(.transparent)

            termsAndConditions
        }
    }

    @ViewBuilder
    private func claimDetailsRow(title: String, value: String) -> some View {
        HStack {
            hText(title)
                .foregroundColor(hTextColor.secondary)
            Spacer()
            hText(value)
                .foregroundColor(hTextColor.secondary)
        }
    }

    @ViewBuilder
    private var termsAndConditions: some View {
        if let termsAndConditionsDocument = vm.claim.productVariant?.documents
            .first(where: { $0.type == .termsAndConditions })
        {
            hSection {
                hRow {
                    hAttributedTextView(
                        text: AttributedPDF().attributedPDFString(for: termsAndConditionsDocument.displayName)
                    )
                    .id("sds_\(String(describing: vm.claim.productVariant?.displayName))")
                }
                .withCustomAccessory {
                    Image(uiImage: hCoreUIAssets.neArrowSmall.image)
                }
                .onTap {
                    //                        vm.store.send(.openDocument(url: url, title: termsAndConditionsDocument.displayName))
                    //                        homeVm.externalNavigationRedirect.append(termsAndConditionsDocument)
                    homeVm.isDocumentPresented = true
                    homeVm.document = termsAndConditionsDocument
                }
            }
        }
    }

    @ViewBuilder
    private var uploadFilesSection: some View {
        VStack(spacing: 16) {
            if vm.showUploadedFiles {
                hSection {
                    if let player {
                        TrackPlayerView(
                            audioPlayer: player
                        )
                        .onReceive(player.objectWillChange.filter({ $0.playbackState == .finished })) { player in }
                    }
                }
                .withHeader {
                    hText(L10n.ClaimStatusDetail.uploadedFiles)
                        .padding(.leading, 2)
                }
                if let fetchError = vm.fetchFilesError {
                    hSection {
                        GenericErrorView(
                            description: fetchError,
                            buttons: .init(
                                actionButton: .init(
                                    buttonAction: {
                                        Task {
                                            await vm.fetchFiles()
                                        }
                                    }),
                                dismissButton: nil
                            )
                        )
                        .hWithoutTitle
                    }
                    .sectionContainerStyle(.transparent)
                } else {
                    hSection {
                        FilesGridView(vm: vm.fileGridViewModel)
                    }
                    .sectionContainerStyle(.transparent)
                }
            }

            if vm.canAddFiles {
                hSection {
                    VStack(spacing: 16) {
                        hRow {
                            hText(L10n.ClaimStatus.UploadedFiles.uploadText)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .verticalPadding(0)
                        hButton.MediumButton(type: .primary) {
                            showFilePickerAlert()
                        } content: {
                            hText(L10n.ClaimStatus.UploadedFiles.uploadButton)
                        }
                        .fixedSize()
                    }
                    .padding(.vertical, 32)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    private func showFilePickerAlert() {
        vm.fileUploadManager.resetuploadFilesPath()
        FilePicker.showAlert { selected in
            switch selected {
            case .camera:
                showCamera = true
            case .imagePicker:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                    switch status {
                    case .notDetermined, .restricted, .denied:
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        DispatchQueue.main.async { UIApplication.shared.open(settingsUrl) }
                    case .authorized, .limited:
                        DispatchQueue.main.async {
                            showImagePicker = true
                        }
                    @unknown default:
                        DispatchQueue.main.async {
                            showImagePicker = true
                        }
                    }
                }
            case .filePicker:
                showFilePicker = true
            }
        }
    }
}

struct ClaimDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let claim = ClaimModel(
            id: "claimId",
            status: .beingHandled,
            outcome: .none,
            submittedAt: "2023-11-11",
            signedAudioURL: "https://filesamples.com/samples/audio/m4a/sample3.m4a",
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken item",
            incidentDate: "2024-02-15",
            productVariant: nil
        )
        return ClaimDetailView(claim: claim)
    }
}

public class ClaimDetailViewModel: ObservableObject {
    @PresentableStore var store: ClaimsStore
    @Published var claim: ClaimModel
    @Inject var claimService: hFetchClaimService
    @Published var fetchFilesError: String?
    @Published var hasFiles = false

    let fileUploadManager = FileUploadManager()
    var fileGridViewModel: FileGridViewModel
    private var cancellables = Set<AnyCancellable>()
    public init(claim: ClaimModel) {
        self.claim = claim
        let store: ClaimsStore = globalPresentableStoreContainer.get()
        let files = store.state.files[claim.id] ?? []
        self.fileGridViewModel = .init(files: files, options: [])
        Task {
            await fetchFiles()
        }
        store.actionSignal.publisher
            .filter { action in
                if case .refreshFiles = action {
                    return true
                }
                return false
            }
            .sink { _ in

            } receiveValue: { value in
                Task { [weak self] in
                    await self?.fetchFiles()
                }
            }
            .store(in: &cancellables)
        fileGridViewModel.$files
            .sink { _ in

            } receiveValue: { files in
                self.hasFiles = !files.isEmpty
            }
            .store(in: &cancellables)

    }

    @MainActor
    func fetchFiles() async {
        withAnimation {
            fetchFilesError = nil
        }
        do {
            let files = try await claimService.getFiles()
            store.send(.setFiles(files: files))
            self.fileGridViewModel.files = files[claim.id] ?? []
        } catch let ex {
            withAnimation {
                fetchFilesError = ex.localizedDescription

            }
        }
    }

    func showAddFiles(with files: [FilePickerDto]) {
        if !files.isEmpty {
            let filess = files.compactMap(
                {
                    return $0.asFile()
                }
            )
            store.send(.navigation(action: .openFilesFor(claim: claim, files: filess)))
        }
    }

    var showUploadedFiles: Bool {
        return self.claim.signedAudioURL != nil || !fileGridViewModel.files.isEmpty || canAddFiles
    }

    var canAddFiles: Bool {
        return self.claim.status != .closed && fetchFilesError == nil
    }
}
