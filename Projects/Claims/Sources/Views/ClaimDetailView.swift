import Chat
import Combine
import Kingfisher
import Payment
import Photos
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    @State var showImagePicker = false
    @State var showFilePicker = false
    @State var showCamera = false
    @ObservedObject var vm: ClaimDetailViewModel
    @EnvironmentObject var router: Router

    public init(
        claim: ClaimModel?,
        type: FetchClaimDetailsType
    ) {
        self._vm = .init(wrappedValue: .init(claim: claim, type: type))
    }

    private var statusParagraph: String? {
        vm.claim?.statusParagraph
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding8) {
                if let claim = vm.claim {
                    claimCardSection(claim: claim)
                    infoAndContactSection
                    memberFreeTextSection
                    claimDetailsSection
                    uploadFilesSection
                    termsAndConditions
                }
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
                guard let data = image.jpegData(compressionQuality: 0.9)
                else { return }
                let file = File(
                    id: UUID().uuidString,
                    size: Double(data.count),
                    mimeType: .JPEG,
                    name: "image_\(Date()).jpeg",
                    source: .data(data: data)
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.showAddFiles(with: [file])
                }

            }
            .ignoresSafeArea()
        }
        .modally(item: $vm.showFilesView) { [weak vm] item in
            ClaimFilesView(endPoint: item.endPoint, files: item.files) { _ in
                let claimStore: ClaimsStore = globalPresentableStoreContainer.get()
                claimStore.send(.fetchClaims)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let nav = UIApplication.shared.getTopViewControllerNavigation()
                    nav?.setNavigationBarHidden(false, animated: true)
                    vm?.showFilesView = nil
                    Task {
                        await vm?.fetchFiles()
                    }
                }
            }
            .withDismissButton()
            .configureTitle(L10n.ClaimStatusDetail.addedFiles)
            .embededInNavigation(tracking: ClaimDetailDetentType.fileUpload)

        }
        .detent(
            item: $vm.document,
            style: [.large]
        ) { document in
            PDFPreview(document: document)
        }
        .loading($vm.claimProcessingState)
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(buttonAction: {
                    vm.fetchClaimDetails()
                })
            )
        )
    }

    private func claimCardSection(claim: ClaimModel) -> some View {
        hSection {
            ClaimStatus(
                claim: claim,
                enableTap: false
            )
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var infoAndContactSection: some View {
        hSection {
            VStack(spacing: 0) {
                hRow {
                    if let statusParagraph {
                        hText(statusParagraph, style: .body1)
                    }
                }
                Divider()

                hRow {
                    HStack {
                        VStack(alignment: .leading) {
                            hText("Updates and messages", style: .label)
                                .foregroundColor(hTextColor.Translucent.secondary)
                            hText("Go to conversation")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()

                        if vm.toolbarOptionType.contains(.chat) {
                            Image(uiImage: hCoreUIAssets.inbox.image)
                        } else {
                            Image(uiImage: hCoreUIAssets.inboxNotification.image)
                        }
                    }
                }
                .withEmptyAccessory
                .onTap {
                    /* TODO: OBSERVE CHANGES */
                    if vm.toolbarOptionType.contains(.chat) {
                        if case .conversation = vm.type {
                            router.pop()
                        } else {
                            NotificationCenter.default.post(
                                name: .openChat,
                                object: ChatType.conversationId(id: vm.claim?.conversation?.id ?? "")
                            )
                        }
                    } else {
                        NotificationCenter.default.post(
                            name: .openChat,
                            object: ChatType.conversationId(id: vm.claim?.conversation?.id ?? "")
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var chatSection: some View {
        if let claim = vm.claim {
            hRow {
                ContactChatView(
                    store: vm.store,
                    id: claim.id,
                    status: claim.status.rawValue
                )
            }
        }
    }

    @ViewBuilder
    private var memberFreeTextSection: some View {
        if let inputText = vm.claim?.memberFreeText {
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

    @ViewBuilder
    private var claimDetailsSection: some View {
        if let claim = vm.claim {
            VStack(spacing: .padding16) {
                hSection {
                    VStack(spacing: .padding8) {
                        claimDetailsRow(title: L10n.ClaimStatus.ClaimDetails.type, value: claim.claimType)
                            .accessibilityHidden(claim.claimType == "")
                        if let incidentDate = claim.incidentDate {
                            claimDetailsRow(
                                title: L10n.ClaimStatus.ClaimDetails.incidentDate,
                                value: incidentDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                            )
                        }
                        if let submitted = claim.submittedAt {
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
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint(L10n.ClaimStatus.ClaimDetails.title)
                    }
                }
                .hWithoutDivider
                .sectionContainerStyle(.transparent)
            }
            .padding(.vertical, .padding8)
        }
    }

    @ViewBuilder
    private func claimDetailsRow(title: String, value: String) -> some View {
        HStack {
            hText(title)
                .foregroundColor(hTextColor.Opaque.secondary)
            Spacer()
            hText(value)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var uploadFilesSection: some View {
        VStack(spacing: .padding8) {
            if vm.showUploadedFiles {
                hSection {
                    if let player = vm.player {
                        TrackPlayerView(
                            audioPlayer: player
                        )
                        .onReceive(player.objectWillChange.filter({ $0.playbackState == .finished })) { player in }
                    }
                }
                if let fetchError = vm.fetchFilesError {
                    hSection {
                        GenericErrorView(
                            description: fetchError,
                            formPosition: .center
                        )
                        .hStateViewButtonConfig(
                            .init(
                                actionButton: .init(
                                    buttonAction: {
                                        Task {
                                            await vm.fetchFiles()
                                        }
                                    }),
                                dismissButton: nil
                            )
                        )
                    }
                    .sectionContainerStyle(.transparent)
                } else {
                    if !vm.fileGridViewModel.files.isEmpty {
                        hSection {
                            FilesGridView(vm: vm.fileGridViewModel)
                        }
                        .sectionContainerStyle(.transparent)
                    }
                }

                if vm.canAddFiles {
                    hSection {
                        VStack(spacing: .padding16) {
                            hRow {
                                hText(L10n.ClaimStatus.UploadedFiles.uploadText)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .verticalPadding(0)
                            .fixedSize(horizontal: false, vertical: true)
                            hButton.MediumButton(type: .primary) {
                                showFilePickerAlert()
                            } content: {
                                hText(L10n.ClaimStatus.UploadedFiles.uploadButton)
                            }
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
        .padding(.bottom, .padding8)
    }

    @ViewBuilder
    private var termsAndConditions: some View {
        //        let termsAndConditionsDocument = vm.claim?.productVariant?.documents
        //            .first(where: { $0.type == .termsAndConditions })
        let termsAndConditionsDocument: hPDFDocument = .init(
            displayName: "Terms standard",
            url: "",
            type: .termsAndConditions
        )

        //                let appealInstructionDocument = vm.claim?.productVariant?.documents
        //            .first(where: { $0.type == .appealInstruction })
        let appealInstructionDocument: hPDFDocument = .init(
            displayName: "Appeal instruction",
            url: "",
            type: .appealInstruction
        )

        let documents = [termsAndConditionsDocument, appealInstructionDocument]

        if !documents.isEmpty {
            InsuranceTermView(
                documents: documents,
                withHeader: "Instructions and terms"
            ) { document in
                vm.document = document
            }
        }
    }

    private func showFilePickerAlert() {
        FilePicker.showAlert { selected in
            Task { @MainActor in
                switch selected {
                case .camera:
                    showCamera = true
                case .imagePicker:
                    let access = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                    switch access {
                    case .notDetermined, .restricted, .denied:
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        await UIApplication.shared.open(settingsUrl)
                    case .authorized, .limited:
                        showImagePicker = true
                    @unknown default:
                        showImagePicker = true
                    }
                case .filePicker:
                    showFilePicker = true
                }
            }
        }
    }
}

private enum ClaimDetailDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .fileUpload:
            return .init(describing: ClaimFilesView.self)
        }
    }

    case fileUpload
}

struct ClaimDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
        Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in FetchClaimDetailsClientDemo() })
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        let featureFlags = FeatureFlagsDemo()
        Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlags })

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
            productVariant: nil,
            conversation: .init(
                id: "",
                type: .claim,
                newestMessage: nil,
                createdAt: nil,
                statusMessage: nil,
                status: .open,
                hasClaim: true,
                claimType: "claim type",
                unreadMessageCount: 0
            )
        )
        return ClaimDetailView(
            claim: claim,
            type: .claim(id: claim.id)
        )
    }
}

@MainActor
public class ClaimDetailViewModel: ObservableObject {
    @PresentableStore var store: ClaimsStore
    @Published public var document: hPDFDocument? = nil
    @Published private(set) var claim: ClaimModel? {
        didSet {
            self.setupToolbarOptionType(for: claim)
            if let url = URL(string: claim?.signedAudioURL) {
                self.player = AudioPlayer(url: url)
            }
        }
    }
    private(set) var player: AudioPlayer?
    private var claimDetailsService: FetchClaimDetailsService
    @Published var fetchFilesError: String?
    @Published var claimProcessingState: ProcessingState = .loading

    @Published var hasFiles = false
    @Published var showFilesView: FilesDto?
    @Published var toolbarOptionType: [ToolbarOptionType] = [.chat]
    let fileGridViewModel: FileGridViewModel
    let type: FetchClaimDetailsType
    private var cancellables = Set<AnyCancellable>()
    public init(
        claim: ClaimModel?,
        type: FetchClaimDetailsType
    ) {
        self.claim = claim
        self.claimDetailsService = .init(type: type)
        let store: ClaimsStore = globalPresentableStoreContainer.get()
        self.type = type
        let files = store.state.files[claim?.id ?? ""] ?? []
        self.fileGridViewModel = .init(files: files, options: [])
        Task {
            await fetchFiles()
        }
        store.actionSignal
            .filter { action in
                if case .refreshFiles = action {
                    return true
                }
                return false
            }
            .sink { _ in

            } receiveValue: { [weak self] value in
                Task { [weak self] in
                    await self?.fetchFiles()
                }
            }
            .store(in: &cancellables)
        fileGridViewModel.$files
            .sink { _ in

            } receiveValue: { [weak self] files in
                self?.hasFiles = !files.isEmpty
            }
            .store(in: &cancellables)

        handleClaimChat()
        if let claim {
            claimProcessingState = .success
            if let url = URL(string: claim.signedAudioURL) {
                self.player = AudioPlayer(url: url)
            }
        } else {
            fetchClaimDetails()
        }
    }

    private func handleClaimChat() {
        self.setupToolbarOptionType(for: claim)
        Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                Task {
                    do {
                        if let claim = try await self?.claimDetailsService.get() {
                            self?.setupToolbarOptionType(for: claim)
                        }
                    } catch {

                    }
                }
            }
            .store(in: &cancellables)

    }

    private func setupToolbarOptionType(for claimModel: ClaimModel?) {
        guard let claimModel, let conversation = claimModel.conversation else {
            withAnimation {
                self.toolbarOptionType = []
            }
            return
        }
        let hasNewMessage = conversation.hasNewMessage
        let timeStamp = conversation.newestMessage?.sentAt
        withAnimation {
            self.toolbarOptionType =
                hasNewMessage ? [.chatNotification(lastMessageTimeStamp: timeStamp ?? Date())] : [.chat]
        }
    }

    func fetchClaimDetails() {
        claimProcessingState = .loading
        Task {
            do {
                let claim = try await claimDetailsService.get()
                self.claim = claim
                claimProcessingState = .success
            } catch {
                claimProcessingState = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    @MainActor
    func fetchFiles() async {
        withAnimation {
            fetchFilesError = nil
        }
        do {
            let data = try await claimDetailsService.getFiles()
            store.send(.setFilesForClaim(claimId: data.claimId, files: data.files))
            withAnimation { [weak self] in
                self?.fileGridViewModel.files = data.files
            }
        } catch let ex {
            withAnimation { [weak self] in
                self?.fetchFilesError = ex.localizedDescription
            }
        }
    }

    func showAddFiles(with files: [File]) {
        if let claim = claim {
            if !files.isEmpty {
                showFilesView = .init(id: claim.id, endPoint: claim.targetFileUploadUri, files: files)
            }
        }
    }

    var showUploadedFiles: Bool {
        return self.claim?.signedAudioURL != nil || !fileGridViewModel.files.isEmpty || canAddFiles
    }

    var canAddFiles: Bool {
        return self.claim?.status != .closed && fetchFilesError == nil
    }
}

struct FilesDto: Identifiable, Equatable {
    let id: String
    let endPoint: String
    let files: [File]
}
