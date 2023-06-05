import AVFoundation
import SwiftUI
import TagKit
import hCore
import hCoreUI

struct SelectClaimEntrypointGroup: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selection: String? = nil
    @State var addPadding = true
    @State var notValid = false

    @State var selectedClaimGroup: String? = nil
    @State var claimEntrypoints: [ClaimEntryPointResponseModel] = []
    var selectedEntrypoints: ([ClaimEntryPointResponseModel]) -> Void

    public init(
        selectedEntrypoints: @escaping ([ClaimEntryPointResponseModel]) -> Void
    ) {
        self.selectedEntrypoints = selectedEntrypoints
        store.send(.fetchEntrypointGroups)
    }

    var body: some View {
        LoadingViewWithContent(.fetchClaimEntrypoints) {
            hForm {
                ProgressBar()
                getTitle
            }
            .hDisableScroll
            .hUseBlur
            .hFormAttachToBottom {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.claimEntrypointGroups
                    }
                ) { claimEntrypointGroup in
                    showValid
                    showTagList(
                        tagsToShow: entrypointGroupToStringArray(input: claimEntrypointGroup),
                        onTap: { tag in
                            selectedClaimGroup = tag
                            selection = tag  // needed?

                            for claimGroup in claimEntrypointGroup {
                                if claimGroup.displayName == selectedClaimGroup {
                                    claimEntrypoints = claimGroup.entrypoints
                                }
                            }
                        },
                        onButtonClick: {
                            selectedEntrypoints(claimEntrypoints)
                            store.send(
                                .commonClaimOriginSelected(
                                    commonClaim: ClaimsOrigin.commonClaimsWithOption(
                                        id: "",
                                        optionId: ""
                                    )
                                )
                            )
                        }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var showValid: some View {
        if notValid {
            hTextNew("Välj en kategori", style: .body)
        }
    }

    private var getTitle: some View {
        hTextNew("Vem eller vad har tagit skada?", style: .title2)
            .multilineTextAlignment(.center)
            .padding([.top, .leading, .trailing], 16)
    }

    private func showTagList(
        tagsToShow: [String],
        onTap: @escaping (String) -> Void,
        onButtonClick: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            TagList(tags: tagsToShow) { tag in
                HStack {
                    hText(tag, style: .body)
                        .foregroundColor(hLabelColorNew.secondary)
                        .lineLimit(1)
                }
                .onTapGesture {
                    onTap(tag)
                    addPadding = true
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        addPadding = false
                    }
                }
                .padding(.horizontal, ((selection == tag) && addPadding) ? 20 : 16)
                //                            .padding(.horizontal, ((selectedClaimGroup == tag) && addPadding) ? 20 : 16)
                .padding(.vertical, 8)
                .background(getColorAndShadow(claimId: tag))
            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 24)

            hButton.LargeButtonFilled {
                if selection != "" {
                    notValid = false
                    onButtonClick()
                } else {
                    notValid = true
                }
                selection = ""
            } content: {
                hText("Spara och fortsätt")
            }
            .padding([.trailing, .leading], 16)
        }
    }

    func entrypointGroupToStringArray(input: [ClaimEntryPointGroupResponseModel]) -> [String] {
        var arr: [String] = []
        for i in input {
            arr.append(i.displayName)
        }
        return arr
    }

    //    private func getVerticalPadding(claimId: String) -> CGFloat {
    //        if selectedClaimGroup == claimId && addPadding {
    //            return 12
    //        } else {
    //            return 8
    //        }
    //    }

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

struct SelectClaimEntrypointType: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selection: String? = nil
    @State var addPadding = true
    @State var notValid = false
    var selectedEntrypointOptions: ([ClaimEntryPointOptionResponseModel], String?) -> Void

    @State var claimOptions: [ClaimEntryPointOptionResponseModel] = []
    @State var selectedClaimEntrypoint: String? = nil

    public init(
        selectedEntrypointOptions: @escaping ([ClaimEntryPointOptionResponseModel], String?) -> Void
    ) {
        self.selectedEntrypointOptions = selectedEntrypointOptions
    }

    var body: some View {
        hForm {
            ProgressBar()
            getTitle
        }
        .hDisableScroll
        .hUseBlur
        .hFormAttachToBottom {
            showValid

            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.entrypoints
                }
            ) { entrypoints in

                showTagList(
                    tagsToShow: entrypointsToStringArray(entrypoints: entrypoints.selectedEntrypoints ?? []),
                    onTap: { tag in
                        selectedClaimEntrypoint = tag
                        selection = tag

                        for claimEntrypoint in entrypoints.selectedEntrypoints ?? [] {
                            if claimEntrypoint.displayName == selectedClaimEntrypoint {
                                claimOptions = claimEntrypoint.options
                            }
                        }
                    },
                    onButtonClick: {
                        selectedEntrypointOptions(
                            claimOptions,
                            mapNametoEntrypointId(input: entrypoints.selectedEntrypoints ?? [])
                        )
                        store.send(
                            .commonClaimOriginSelected(
                                commonClaim: ClaimsOrigin.commonClaimsWithOption(
                                    id: mapNametoEntrypointId(input: entrypoints.selectedEntrypoints ?? []),
                                    optionId: ""
                                )
                            )
                        )
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var showValid: some View {
        if notValid {
            hTextNew("Välj en kategori", style: .body)
        }
    }

    private var getTitle: some View {
        hTextNew("Vad är det som har hänt?", style: .title2)
            .multilineTextAlignment(.center)
            .padding([.top, .leading, .trailing], 16)
    }

    private func showTagList(
        tagsToShow: [String],
        onTap: @escaping (String) -> Void,
        onButtonClick: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            TagList(tags: tagsToShow) { tag in
                HStack {
                    hText(tag, style: .body)
                        .foregroundColor(hLabelColorNew.secondary)
                        .lineLimit(1)
                }
                .onTapGesture {
                    onTap(tag)
                    addPadding = true
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        addPadding = false
                    }
                }
                .padding(.horizontal, ((selection == tag) && addPadding) ? 20 : 16)
                .padding(.vertical, 8)
                .background(getColorAndShadow(claimId: tag))
            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 24)

            hButton.LargeButtonFilled {
                if selection != "" {
                    notValid = false
                    onButtonClick()
                } else {
                    notValid = true
                }
                selection = ""
            } content: {
                hText("Spara och fortsätt")
            }
            .padding([.trailing, .leading], 16)
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

struct SelectClaimEntrypointOption: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selection: String? = nil
    @State var addPadding = true
    @State var notValid = false

    @State var selectedClaimOption: String? = nil

    public init() {}

    var body: some View {
        hForm {
            ProgressBar()
            getTitle
        }
        .hDisableScroll
        .hUseBlur
        .hFormAttachToBottom {
            showValid

            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.entrypoints
                }
            ) { entrypoints in

                showTagList(
                    tagsToShow: entrypointOptionsToStringArray(input: entrypoints.selectedEntrypointOptions ?? []),
                    onTap: { tag in
                        selectedClaimOption = tag
                        selection = tag
                    },
                    onButtonClick: {

                        store.send(
                            .commonClaimOriginSelected(
                                commonClaim: ClaimsOrigin.commonClaimsWithOption(
                                    id: entrypoints.selectedEntrypointId ?? "",
                                    optionId: mapNametoEntrypointOptionId(
                                        input: entrypoints.selectedEntrypointOptions ?? []
                                    )
                                )
                            )
                        )
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var showValid: some View {
        if notValid {
            hTextNew("Välj en kategori", style: .body)
        }
    }

    private var getTitle: some View {
        hTextNew("Vad är det som har gått sönder?", style: .title2)
            .multilineTextAlignment(.center)
            .padding([.top, .leading, .trailing], 16)
    }

    private func showTagList(
        tagsToShow: [String],
        onTap: @escaping (String) -> Void,
        onButtonClick: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            TagList(tags: tagsToShow) { tag in
                HStack {
                    hText(tag, style: .body)
                        .foregroundColor(hLabelColorNew.secondary)
                        .lineLimit(1)
                }
                .onTapGesture {
                    onTap(tag)
                    addPadding = true
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        addPadding = false
                    }
                }
                .padding(.horizontal, ((selection == tag) && addPadding) ? 20 : 16)
                .padding(.vertical, 8)
                .background(getColorAndShadow(claimId: tag))
            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 24)

            hButton.LargeButtonFilled {
                if selection != "" {
                    notValid = false
                    onButtonClick()
                } else {
                    notValid = true
                }
                selection = ""
            } content: {
                hText("Spara och fortsätt")
            }
            .padding([.trailing, .leading], 16)
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
