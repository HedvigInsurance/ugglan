import AVFoundation
import SwiftUI
import TagKit
import hCore
import hCoreUI

struct SelectClaimEntrypoint: View {
    @PresentableStore var store: SubmitClaimStore
    @State var selection: String? = nil
    @State var addPadding = true
    @State var notValid = false

    @State var selectedClaimGroup: String? = nil

    @State var selectedClaimEntrypoint: String? = nil
    @State var claimEntrypoints: [ClaimEntryPointResponseModel] = []

    @State var selectedClaimOption: String? = nil
    @State var claimOptions: [ClaimEntryPointOptionResponseModel] = []

    @State var hasSelectedWhatTookDamage = false
    @State var hasSelectedWhatHappened = false
    @State var hasSelectedWhatBroke = false

    public init() {
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
                    ZStack {
                        if !hasSelectedWhatTookDamage {
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
                                    hasSelectedWhatTookDamage = true
                                }
                            )

                        } else if !hasSelectedWhatHappened {
                            showTagList(
                                tagsToShow: entrypointsToStringArray,
                                onTap: { tag in
                                    selectedClaimEntrypoint = tag
                                    selection = tag

                                    for claimGroup in claimEntrypointGroup {
                                        if claimGroup.displayName == selectedClaimGroup {
                                            for claimEntrypoint in claimGroup.entrypoints {
                                                if claimEntrypoint.displayName == selectedClaimEntrypoint {
                                                    claimOptions = claimEntrypoint.options
                                                }
                                            }
                                        }
                                    }
                                },
                                onButtonClick: {
                                    hasSelectedWhatHappened = true
                                }
                            )

                        } else {
                            showTagList(tagsToShow: entrypointOptionsToStringArray) { tag in
                                selectedClaimOption = tag
                                selection = tag
                            } onButtonClick: {
                                hasSelectedWhatBroke = true
                                store.send(
                                    .commonClaimOriginSelected(
                                        commonClaim: ClaimsOrigin.commonClaimsWithOption(
                                            id: mapNametoEntrypointId(input: claimEntrypoints),
                                            optionId: mapNametoEntrypointOptionId(input: claimOptions)
                                        )
                                    )
                                )
                            }
                        }
                    }
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
        Group {
            if !hasSelectedWhatTookDamage {
                hTextNew("Vem eller vad har tagit skada?", style: .title2)
            } else if !hasSelectedWhatHappened {
                hTextNew("Vad är det som har hänt?", style: .title2)
            } else {
                hTextNew("Vad är det som har gått sönder?", style: .title2)
            }
        }
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

    var entrypointsToStringArray: [String] {
        var arr: [String] = []
        var maxNum = 0
        for i in claimEntrypoints {
            if maxNum <= 8 {
                arr.append(i.displayName)
                maxNum += 1
            }
        }
        return arr
    }

    var entrypointOptionsToStringArray: [String] {
        for claims in claimEntrypoints {
            if claims.displayName == selectedClaimEntrypoint {
                var arr: [String] = []
                var maxNum = 0
                for option in claims.options {
                    if maxNum <= 8 {
                        arr.append(option.displayName)
                        maxNum += 1
                    }

                }
                return arr
            }
        }
        return []
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

    func mapEntrypoint(input: [ClaimEntryPointResponseModel]) -> ClaimEntryPointResponseModel? {
        for claimType in input {
            if claimType.displayName == selectedClaimEntrypoint {
                return claimType
            }
        }
        return nil
    }

    func mapNametoEntrypointId(input: [ClaimEntryPointResponseModel]) -> String {
        for entrypoint in input {
            if entrypoint.displayName == selectedClaimEntrypoint {
                return entrypoint.id
            }
        }
        return ""
    }

    func mapNametoEntrypointOptionId(input: [ClaimEntryPointOptionResponseModel]) -> String {
        for option in input {
            if option.displayName == selectedClaimOption {
                return option.id
            }
        }
        return ""
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

struct SelectClaimEntrypoint_Previews: PreviewProvider {
    static var previews: some View {
        SelectClaimEntrypoint()
    }
}
