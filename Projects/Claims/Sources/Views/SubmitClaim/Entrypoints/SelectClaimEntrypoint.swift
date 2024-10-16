import AVFoundation
import PresentableStore
import SwiftUI
import TagKit
import hCore
import hCoreUI

public struct SelectClaimEntrypointGroup: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selectedClaimGroup: String? = nil
    @State var claimEntrypoints: [ClaimEntryPointResponseModel] = []
    var selectedEntrypoints: ([ClaimEntryPointResponseModel]) -> Void

    public init(
        selectedEntrypoints: @escaping ([ClaimEntryPointResponseModel]) -> Void
    ) {
        self.selectedEntrypoints = selectedEntrypoints
    }

    public var body: some View {
        hForm {}
            .hFormTitle(title: .init(.small, .displayXSLong, L10n.claimTriagingNavigationTitle))
            .hDisableScroll
            .hFormAttachToBottom {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.claimEntrypointGroups
                    }
                ) { claimEntrypointGroup in
                    VStack {
                        ShowTagList(
                            tagsToShow: claimEntrypointGroup.map({ $0.displayName }),
                            onTap: { tag in
                                selectedClaimGroup = tag
                                claimEntrypoints =
                                    claimEntrypointGroup.first(where: { $0.displayName == selectedClaimGroup })?
                                    .entrypoints ?? []
                            },
                            onButtonClick: {
                                if selectedClaimGroup != nil {
                                    selectedEntrypoints(claimEntrypoints)
                                }
                            },
                            oldValue: $selectedClaimGroup
                        )
                    }
                }
            }
            .claimErrorTrackerFor([.fetchClaimEntrypointGroups])
    }

    var hasClaimEntrypoints: Bool {
        if claimEntrypoints != [] {
            return true
        } else {
            return false
        }
    }
}

struct SelectClaimEntrypointType: View {
    @PresentableStore var store: SubmitClaimStore
    var selectedEntrypointOptions: ([ClaimEntryPointOptionResponseModel], String?) -> Void
    @State var entrypointList: [ClaimEntryPointResponseModel] = []
    @State var claimOptions: [ClaimEntryPointOptionResponseModel] = []
    @State var selectedClaimEntrypoint: String? = nil

    public init(
        selectedEntrypointOptions: @escaping ([ClaimEntryPointOptionResponseModel], String?) -> Void
    ) {
        self.selectedEntrypointOptions = selectedEntrypointOptions
    }

    var body: some View {
        hForm {
        }
        .hFormTitle(title: .init(.small, .displayXSLong, L10n.claimsTriagingWhatHappenedTitle))
        .hDisableScroll
        .hFormAttachToBottom {

            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.entrypoints
                }
            ) { entrypoints in

                ShowTagList(
                    tagsToShow: entrypointsToStringArray(entrypoints: entrypoints.selectedEntrypoints ?? []),
                    onTap: { tag in
                        selectedClaimEntrypoint = tag
                        for claimEntrypoint in entrypoints.selectedEntrypoints ?? [] {
                            if claimEntrypoint.displayName == selectedClaimEntrypoint {
                                claimOptions = claimEntrypoint.options
                            }
                        }
                    },
                    onButtonClick: {
                        if selectedClaimEntrypoint != nil {
                            selectedEntrypointOptions(
                                claimOptions,
                                mapNametoEntrypointId(input: entrypoints.selectedEntrypoints ?? [])
                            )
                        }
                    },
                    oldValue: $selectedClaimEntrypoint
                )
            }
        }
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

    var hasClaimEntrypointOptions: Bool {
        if claimOptions != [] {
            return true
        } else {
            return false
        }
    }
}

struct SelectClaimEntrypointOption: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selectedClaimOption: String? = nil
    var onButtonClick: (String, String) -> Void

    public init(
        onButtonClick: @escaping (String, String) -> Void
    ) {
        self.onButtonClick = onButtonClick
    }

    var body: some View {
        hForm {
        }
        .hFormTitle(title: .init(.small, .displayXSLong, L10n.claimsTriagingWhatItemTitle))
        .hDisableScroll
        .hFormAttachToBottom {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.entrypoints
                }
            ) { entrypoints in

                ShowTagList(
                    tagsToShow: entrypointOptionsToStringArray(input: entrypoints.selectedEntrypointOptions ?? []),
                    onTap: { tag in
                        selectedClaimOption = tag
                    },
                    onButtonClick: {
                        if selectedClaimOption != nil {
                            onButtonClick(
                                entrypoints.selectedEntrypointId ?? "",
                                mapNametoEntrypointOptionId(
                                    input: entrypoints.selectedEntrypointOptions ?? []
                                )
                            )
                        }
                    },
                    oldValue: $selectedClaimOption
                )
            }
        }
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
    var body: some View {
        hSection {
            VStack(spacing: 16) {
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
                    }
                }
                .disableOn(SubmitClaimStore.self, [.startClaim])
                hButton.LargeButton(type: .primary) {
                    if selection != nil && selection != "" {
                        notValid = false
                        onButtonClick()
                    } else {
                        withAnimation {
                            notValid = true
                        }
                        selection = ""
                    }
                } content: {
                    hText(L10n.generalContinueButton, style: .body1)
                }
                .trackLoading(SubmitClaimStore.self, action: .startClaim)
                .presentableStoreLensAnimation(.default)
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
                Image(uiImage: hCoreUIAssets.infoFilledSmall.image)
                    .foregroundColor(hAmberColor.amber600)
                hText(L10n.claimsSelectCategory, style: .body1)
            }
        }
    }

    @ViewBuilder
    func getColorAndShadow(claimId: String) -> some View {
        if selection == claimId {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(hButtonColor.PrimaryAlt.resting)
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
