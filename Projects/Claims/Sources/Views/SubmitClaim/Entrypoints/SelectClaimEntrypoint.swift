import AVFoundation
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
        store.send(.fetchEntrypointGroups)
    }

    public var body: some View {
        LoadingViewWithContent(.fetchClaimEntrypoints) {
            hForm {
            }
            .hUseNewStyle
            .hFormTitle(.small, L10n.claimTriagingNavigationTitle)
            .hDisableScroll
            .hUseBlur
            .hFormAttachToBottom {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.claimEntrypointGroups
                    }
                ) { claimEntrypointGroup in
                    VStack {
                        ShowTagList(
                            tagsToShow: entrypointGroupToStringArray(input: claimEntrypointGroup),
                            onTap: { tag in
                                selectedClaimGroup = tag

                                for claimGroup in claimEntrypointGroup {
                                    if claimGroup.displayName == selectedClaimGroup {
                                        claimEntrypoints = claimGroup.entrypoints
                                    }
                                }
                            },
                            onButtonClick: {
                                if selectedClaimGroup != nil {
                                    selectedEntrypoints(claimEntrypoints)
                                    store.send(
                                        .commonClaimOriginSelected(
                                            commonClaim: ClaimsOrigin.commonClaimsWithOption(
                                                id: "",
                                                optionId: "",
                                                hasEntrypointTypes: hasClaimEntrypoints,
                                                hasEntrypointOptions: true
                                            )
                                        )
                                    )
                                }
                            },
                            oldValue: $selectedClaimGroup
                        )
                    }
                }
            }
        }
    }

    var hasClaimEntrypoints: Bool {
        if claimEntrypoints != [] {
            return true
        } else {
            return false
        }
    }

    func entrypointGroupToStringArray(input: [ClaimEntryPointGroupResponseModel]) -> [String] {
        var arr: [String] = []
        for i in input {
            arr.append(i.displayName)
        }
        return arr
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
        .hUseNewStyle
        .hFormTitle(.small, L10n.claimsTriagingWhatHappenedTitle)
        .hDisableScroll
        .hUseBlur
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
                            store.send(
                                .commonClaimOriginSelected(
                                    commonClaim: ClaimsOrigin.commonClaimsWithOption(
                                        id: mapNametoEntrypointId(input: entrypoints.selectedEntrypoints ?? []),
                                        optionId: "",
                                        hasEntrypointTypes: true,
                                        hasEntrypointOptions: hasClaimEntrypointOptions
                                    )
                                )
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

    public init() {}

    var body: some View {
        hForm {
        }
        .hUseNewStyle
        .hFormTitle(.small, L10n.claimsTriagingWhatItemTitle)
        .hDisableScroll
        .hUseBlur
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
                            store.send(
                                .startClaimRequest(
                                    entrypointId: entrypoints.selectedEntrypointId ?? "",
                                    entrypointOptionId: mapNametoEntrypointOptionId(
                                        input: entrypoints.selectedEntrypointOptions ?? []
                                    )
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
    var tagsToShow: [String]
    var onTap: (String) -> Void
    var onButtonClick: () -> Void
    @State var notValid = false
    @State var animate = false
    @State var selection: String? = nil
    @Binding var oldValue: String?
    @State private var showTags = false
    var body: some View {
        VStack(spacing: 24) {
            showNotValid
            TagList(tags: tagsToShow) { tag in
                if showTags {
                    HStack {
                        hTextNew(tag, style: .body)
                            .foregroundColor(hLabelColorNew.secondary)
                            .lineLimit(1)
                    }
                    .onAppear {
                        selection = oldValue
                    }
                    .onTapGesture {
                        onTap(tag)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = tag
                            animate = true
                        }
                        withAnimation(.easeInOut(duration: 0.2).delay(0.2)) {
                            animate = false
                        }
                        notValid = false
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(getColorAndShadow(claimId: tag))
                    .scaleEffect(animate && selection == tag ? 1.05 : 1)
                    .transition(
                        .scale.animation(
                            .spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1)
                                .delay(Double.random(in: 0.3...0.6))
                        )
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            hButton.LargeButtonFilled {
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
                hTextNew(L10n.saveAndContinueButtonLabel, style: .body)
            }
            .padding([.trailing, .leading], 16)
        }
        .padding([.leading, .trailing], 16)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    showTags = true
                }
            }
        }
    }

    @ViewBuilder
    var showNotValid: some View {
        if notValid {
            HStack {
                Image(uiImage: hCoreUIAssets.infoSmall.image)
                    .foregroundColor(hAmberColorNew.amber600)
                hTextNew(L10n.claimsSelectCategory, style: .body)
            }
        }
    }

    @ViewBuilder
    func getColorAndShadow(claimId: String) -> some View {
        if selection == claimId {
            Squircle.default()
                .foregroundColor(hGreenColorNew.green50)
                .hShadow()

        } else {
            Squircle.default()
                .foregroundColor(hGrayscaleTranslucentColorNew.greyScaleTranslucentField)
        }
    }
}
