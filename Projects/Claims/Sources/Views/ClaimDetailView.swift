import Chat
import Combine
import Home
import Kingfisher
import Payment
import Photos
import PresentableStore
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
    @EnvironmentObject var router: Router
    private var fromChat: Bool

    public init(
        claim: ClaimModel,
        fromChat: Bool
    ) {
        self._vm = .init(wrappedValue: .init(claim: claim))
        self.fromChat = fromChat
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
                    ClaimStatus(
                        claim: vm.claim,
                        enableTap: false,
                        extendedBottomView: {
                            AnyView(infoAndContactSection)
                        }()
                    )
                }
                .sectionContainerStyle(.transparent)
                memberFreeTextSection
                claimDetailsSection
                    .padding(.vertical, .padding16)
                uploadFilesSection
            }
        }
        .setHomeNavigationBars(
            with: $vm.toolbarOptionType,
            and: .init(describing: ClaimDetailView.self),
            action: { type in
                switch type {
                case .newOffer:
                    break
                case .firstVet:
                    break
                case .chat:
                    if fromChat {
                        router.pop()
                    } else {
                        NotificationCenter.default.post(
                            name: .openChat,
                            object: ChatType.conversationId(id: vm.claim.conversation?.id ?? "")
                        )
                    }
                case .chatNotification:
                    NotificationCenter.default.post(
                        name: .openChat,
                        object: ChatType.conversationId(id: vm.claim.conversation?.id ?? "")
                    )
                }
            }
        )
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
    }

    @ViewBuilder
    private var infoAndContactSection: some View {
        Divider()
            .padding(.horizontal, -16)
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                hText(L10n.ClaimStatus.title, style: .label)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText(statusParagraph, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
    }

    @ViewBuilder
    private var chatSection: some View {
        hRow {
            ContactChatView(
                store: vm.store,
                id: vm.claim.id,
                status: vm.claim.status.rawValue
            )
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
            .padding(.top, .padding16)
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
                .foregroundColor(hTextColor.Opaque.secondary)
            Spacer()
            hText(value)
                .foregroundColor(hTextColor.Opaque.secondary)
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
                    Image(uiImage: hCoreUIAssets.arrowNorthEast.image)
                }
                .onTap {
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
                            description: fetchError
                        )
                        .hErrorViewButtonConfig(
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
                    .padding(.vertical, .padding32)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    private func showFilePickerAlert() {
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
        Dependencies.shared.add(module: Module { () -> hFetchClaimClient in FetchClaimClientDemo() })
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
            fromChat: false
        )
        .environmentObject(HomeNavigationViewModel())
    }
}

public class ClaimDetailViewModel: ObservableObject {
    @PresentableStore var store: ClaimsStore
    @Published var claim: ClaimModel
    var claimService = hFetchClaimService()
    @Published var fetchFilesError: String?
    @Published var hasFiles = false
    @Published var showFilesView: FilesDto?
    @Published var toolbarOptionType: [ToolbarOptionType] = [.chat]
    let fileGridViewModel: FileGridViewModel

    private var cancellables = Set<AnyCancellable>()
    public init(
        claim: ClaimModel
    ) {
        self.claim = claim
        let store: ClaimsStore = globalPresentableStoreContainer.get()
        let files = store.state.files[claim.id] ?? []
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
    }

    private func handleClaimChat() {
        let claimStore: ClaimsStore = globalPresentableStoreContainer.get()
        let claimId = self.claim.id
        claimStore.stateSignal
            .map({ $0.claim(for: claimId) })
            .compactMap({ $0?.conversation?.hasNewMessage })
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] hasNewMessage in
                let claimStore: ClaimsStore = globalPresentableStoreContainer.get()
                let claim = claimStore.state.claim(for: self?.claim.id ?? "")
                let timeStamp = claim?.conversation?.newestMessage?.sentAt
                self?.toolbarOptionType =
                    hasNewMessage ? [.chatNotification(lastMessageTimeStamp: timeStamp ?? Date())] : [.chat]
            }
            .store(in: &cancellables)
        if let hasNewMessage = claim.conversation?.hasNewMessage {
            self.toolbarOptionType =
                hasNewMessage
                ? [.chatNotification(lastMessageTimeStamp: claim.conversation?.newestMessage?.sentAt ?? Date())]
                : [.chat]
        }

        Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            .sink { _ in
                let store: ClaimsStore = globalPresentableStoreContainer.get()
                store.send(.fetchClaims)
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
            withAnimation { [weak self] in
                self?.fileGridViewModel.files = files[self?.claim.id ?? ""] ?? []
            }
        } catch let ex {
            withAnimation { [weak self] in
                self?.fetchFilesError = ex.localizedDescription
            }
        }
    }

    func showAddFiles(with files: [File]) {
        if !files.isEmpty {
            showFilesView = .init(id: claim.id, endPoint: claim.targetFileUploadUri, files: files)
        }
    }

    var showUploadedFiles: Bool {
        return self.claim.signedAudioURL != nil || !fileGridViewModel.files.isEmpty || canAddFiles
    }

    var canAddFiles: Bool {
        return self.claim.status != .closed && fetchFilesError == nil
    }
}

struct FilesDto: Identifiable, Equatable {
    let id: String
    let endPoint: String
    let files: [File]
}
