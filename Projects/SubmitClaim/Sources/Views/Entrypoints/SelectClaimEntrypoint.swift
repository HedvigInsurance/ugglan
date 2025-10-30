import AVFoundation
import SwiftUI
import TagKit
import hCore
import hCoreUI

public struct SelectClaimEntrypointGroup: View {
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @ObservedObject var vm: SelectClaimEntrypointViewModel
    @State var buttonIsLoading: Bool = false

    public init(
        vm: SelectClaimEntrypointViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    L10n.claimTriagingNavigationTitle,
                    alignment: .leading
                )
            )
            .hFormAttachToBottom {
                VStack {
                    ShowTagList(
                        tagsToShow: claimsNavigationVm.selectClaimEntrypointVm.claimEntrypointGroups.map(\.displayName),
                        onTap: { tag in
                            claimsNavigationVm.selectClaimEntrypointVm.selectedClaimGroup = tag
                            claimsNavigationVm.selectClaimEntrypointVm.claimEntrypoints =
                                claimsNavigationVm.selectClaimEntrypointVm.claimEntrypointGroups.first(where: {
                                    $0.displayName == claimsNavigationVm.selectClaimEntrypointVm.selectedClaimGroup
                                })?
                                .entrypoints ?? []
                        },
                        onButtonClick: {
                            if claimsNavigationVm.selectClaimEntrypointVm.selectedClaimGroup != nil {
                                claimsNavigationVm.previousProgress = 0

                                if claimsNavigationVm.selectClaimEntrypointVm.claimEntrypoints.isEmpty {
                                    claimsNavigationVm.entrypoints.selectedEntrypoints =
                                        claimsNavigationVm.selectClaimEntrypointVm.claimEntrypoints

                                    buttonIsLoading = true
                                    Task {
                                        await claimsNavigationVm.startClaimRequest(
                                            entrypointId: nil,
                                            entrypointOptionId: nil
                                        )
                                        buttonIsLoading = false
                                    }
                                } else {
                                    if claimsNavigationVm.selectClaimEntrypointVm.claimEntrypoints.first?.options == []
                                    {
                                        claimsNavigationVm.progress = 0.2
                                    } else {
                                        claimsNavigationVm.progress = 0.1
                                    }

                                    claimsNavigationVm.entrypoints.selectedEntrypoints =
                                        claimsNavigationVm.selectClaimEntrypointVm.claimEntrypoints
                                    claimsNavigationVm.router.push(SubmitClaimRouterActions.triagingEntrypoint)
                                }
                            }
                        },
                        oldValue: $claimsNavigationVm.selectClaimEntrypointVm.selectedClaimGroup,
                        buttonIsLoading: $buttonIsLoading
                    )
                }
            }
            .trackErrorState(for: $vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            vm.fetchClaimEntrypointGroups()
                        }),
                    dismissButton: .init(
                        buttonTitle: L10n.openChat,
                        buttonAction: {
                            claimsNavigationVm.router.dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                            }
                        }
                    )
                )
            )
            .claimErrorTrackerForState($claimsNavigationVm.startClaimState)
    }
}

struct SelectClaimEntrypointType: View {
    @State var claimOptions: [ClaimEntryPointOptionResponseModel] = []
    @State var selectedClaimEntrypoint: String? = nil
    @State var buttonIsLoading: Bool = false

    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @EnvironmentObject var router: Router

    init() {}

    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    L10n.claimsTriagingWhatHappenedTitle,
                    alignment: .leading
                )
            )
            .hFormAttachToBottom {
                ShowTagList(
                    tagsToShow: entrypointsToStringArray(
                        entrypoints: claimsNavigationVm.entrypoints.selectedEntrypoints ?? []
                    ),
                    onTap: { tag in
                        selectedClaimEntrypoint = tag
                        for claimEntrypoint in claimsNavigationVm.entrypoints.selectedEntrypoints ?? [] {
                            if claimEntrypoint.displayName == selectedClaimEntrypoint {
                                claimOptions = claimEntrypoint.options
                            }
                        }
                    },
                    onButtonClick: {
                        if selectedClaimEntrypoint != nil {
                            claimsNavigationVm.previousProgress = claimsNavigationVm.progress
                            claimsNavigationVm.progress = 0.2

                            claimsNavigationVm.entrypoints.selectedEntrypointOptions = claimOptions
                            claimsNavigationVm.entrypoints.selectedEntrypointId = mapNametoEntrypointId(
                                input: claimsNavigationVm.entrypoints.selectedEntrypoints ?? []
                            )

                            if claimOptions.isEmpty {
                                buttonIsLoading = true
                                Task {
                                    await claimsNavigationVm.startClaimRequest(
                                        entrypointId: claimsNavigationVm.entrypoints.selectedEntrypointId,
                                        entrypointOptionId: nil
                                    )
                                    buttonIsLoading = false
                                }
                            } else {
                                router.push(SubmitClaimRouterActions.triagingOption)
                            }
                        }
                    },
                    oldValue: $selectedClaimEntrypoint,
                    buttonIsLoading: $buttonIsLoading
                )
            }
            .claimErrorTrackerForState($claimsNavigationVm.startClaimState)
    }

    func entrypointsToStringArray(entrypoints: [ClaimEntryPointResponseModel]) -> [String] {
        var arr: [String] = []
        var maxNum = 0
        for i in entrypoints {
            if maxNum <= 8 {
                arr.append(i.displayName)
                maxNum += 1
            }
        }
        return arr
    }

    func mapNametoEntrypointId(input: [ClaimEntryPointResponseModel]) -> String {
        for entrypoint in input {
            if entrypoint.displayName == selectedClaimEntrypoint {
                return entrypoint.id
            }
        }
        return ""
    }
}

struct SelectClaimEntrypointOption: View {
    @State var selectedClaimOption: String? = nil
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @State var buttonIsLoading: Bool = false

    init() {}

    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    L10n.claimsTriagingWhatItemTitle,
                    alignment: .leading
                )
            )
            .hFormAttachToBottom {
                ShowTagList(
                    tagsToShow: entrypointOptionsToStringArray(
                        input: claimsNavigationVm.entrypoints.selectedEntrypointOptions ?? []
                    ),
                    onTap: { tag in
                        selectedClaimOption = tag
                    },
                    onButtonClick: {
                        if selectedClaimOption != nil {
                            buttonIsLoading = true
                            Task {
                                await claimsNavigationVm.startClaimRequest(
                                    entrypointId: claimsNavigationVm.entrypoints.selectedEntrypointId ?? "",
                                    entrypointOptionId: mapNametoEntrypointOptionId(
                                        input: claimsNavigationVm.entrypoints.selectedEntrypointOptions ?? []
                                    )
                                )
                                buttonIsLoading = false
                            }
                        }
                    },
                    oldValue: $selectedClaimOption,
                    buttonIsLoading: $buttonIsLoading
                )
            }
            .claimErrorTrackerForState($claimsNavigationVm.startClaimState)
    }

    func mapNametoEntrypointOptionId(input: [ClaimEntryPointOptionResponseModel]) -> String {
        for option in input {
            if option.displayName == selectedClaimOption {
                return option.id
            }
        }
        return ""
    }

    func entrypointOptionsToStringArray(input: [ClaimEntryPointOptionResponseModel]) -> [String] {
        var arr: [String] = []
        var maxNum = 0
        for i in input {
            if maxNum <= 8 {
                arr.append(i.displayName)
                maxNum += 1
            }
        }
        return arr
    }
}

struct ShowTagList: View {
    private let scaleSize = 1.05
    var tagsToShow: [String]
    var onTap: (String) -> Void
    var onButtonClick: () -> Void
    @State var notValid = false
    @State var animate = false
    @State var selection: String? = nil
    @Binding var oldValue: String?
    @State private var showTags = false

    @Binding var buttonIsLoading: Bool

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                showNotValid
                TagList(tags: tagsToShow, horizontalSpacing: 4, verticalSpacing: 4) { tag in
                    if showTags {
                        HStack(spacing: 0) {
                            getPillText(claimId: tag)
                                .lineLimit(1)
                        }
                        .onAppear {
                            selection = oldValue
                        }
                        .onTapGesture {
                            onTap(tag)
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selection = tag
                                animate = true
                            }
                            withAnimation(.easeInOut(duration: 0.15).delay(0.15)) {
                                animate = false
                            }
                            notValid = false
                            ImpactGenerator.soft()
                        }
                        .padding(.horizontal, .padding12)  // 16 - tag list horizontal spacing
                        .padding(.vertical, .padding8)
                        .background(
                            getColorAndShadow(claimId: tag)
                                .scaleEffect(animate && selection == tag ? scaleSize : 1)
                        )
                        .transition(
                            .scale.animation(
                                .spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1)
                                    .delay(Double.random(in: 0.3...0.6))
                            )
                        )
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAddTraits(selection == tag ? .isSelected : [])
                    }
                }
                hContinueButton {
                    if selection != nil, selection != "" {
                        notValid = false
                        onButtonClick()
                    } else {
                        withAnimation {
                            notValid = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                UIAccessibility.post(notification: .announcement, argument: L10n.claimsSelectCategory)
                            }
                        }
                        selection = ""
                    }
                }
                .hButtonIsLoading(buttonIsLoading)
                .accessibilityHint(selection == nil || selection == "" ? L10n.voiceoverSubmitClaimsTriagingInfo : "")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        showTags = true
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    var showNotValid: some View {
        if notValid {
            HStack {
                hCoreUIAssets.infoFilledSmall.view
                    .foregroundColor(hAmberColor.amber600)
                hText(L10n.claimsSelectCategory, style: .body1)
            }
        }
    }

    @ViewBuilder
    func getColorAndShadow(claimId: String) -> some View {
        if selection == claimId {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(PrimaryAlt().resting)
                .asAnyView
                .hShadow()
        } else {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(hGrayscaleOpaqueColor.greyScale100)
        }
    }

    @ViewBuilder
    func getPillText(claimId: String) -> some View {
        if selection == claimId {
            hText(claimId, style: .body1)
                .foregroundColor(hTextColor.Opaque.primary)
                .colorScheme(.light)
        } else {
            hText(claimId, style: .body1)
        }
    }
}

@MainActor
public class SelectClaimEntrypointViewModel: ObservableObject {
    private var service = FetchEntrypointsService()
    @Published var viewState: ProcessingState = .loading
    @Published var claimEntrypointGroups: [ClaimEntryPointGroupResponseModel] = []
    @Published var claimEntrypoints: [ClaimEntryPointResponseModel] = []
    @Published var selectedClaimGroup: String? = nil

    init() {
        fetchClaimEntrypointGroups()
    }

    func fetchClaimEntrypointGroups() {
        withAnimation {
            self.viewState = .loading
        }

        Task { @MainActor in
            do {
                let data = try await service.get()
                self.claimEntrypointGroups = data

                withAnimation {
                    self.viewState = .success
                }
            } catch let exception {
                withAnimation {
                    self.viewState = .error(errorMessage: exception.localizedDescription)
                }
            }
        }
    }
}
