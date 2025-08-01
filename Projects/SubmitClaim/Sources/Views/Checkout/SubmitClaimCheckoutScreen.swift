import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimCheckoutScreen: View {
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @ObservedObject var vm: SubmitClaimCheckoutViewModel
    public init(vm: SubmitClaimCheckoutViewModel) {
        self.vm = vm
    }

    public var body: some View {
        let singleItemCheckoutStep = claimsNavigationVm.singleItemCheckoutModel
        hForm {
            getFormContent(from: singleItemCheckoutStep)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 16) {
                    let repairCost = singleItemCheckoutStep?.compensation.repairCompensation?.repairCost
                    if repairCost == nil {
                        InfoCard(text: L10n.claimsCheckoutNotice, type: .info)
                            .accessibilitySortPriority(2)
                    }
                    hButton(
                        .large,
                        .primary,
                        content: .init(
                            title: L10n.Claims.Payout.Button.label(
                                singleItemCheckoutStep?.compensation.payoutAmount.formattedAmount ?? ""
                            )
                        ),
                        {
                            if let model = claimsNavigationVm.singleItemCheckoutModel {
                                claimsNavigationVm.isCheckoutTransferringPresented = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                    Task {
                                        let step = await vm.singleItemRequest(
                                            context: claimsNavigationVm.currentClaimContext ?? "",
                                            model: model
                                        )

                                        if let step {
                                            claimsNavigationVm.isCheckoutTransferringPresented = false
                                            claimsNavigationVm.navigate(data: step)
                                        }
                                    }
                                }
                            }
                        }
                    )
                    .disabled(vm.viewState == .loading)
                    .hButtonIsLoading(vm.viewState == .loading)
                }
            }
            .padding(.vertical, .padding16)
            .sectionContainerStyle(.transparent)
        }
    }

    func getFormContent(from singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        VStack(spacing: 16) {
            hSection {
                VStack(alignment: .center) {
                    hText(
                        singleItemCheckoutStep?.compensation.payoutAmount.formattedAmount ?? "",
                        style: .display1
                    )
                    .foregroundColor(hTextColor.Opaque.primary)
                }
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .padding(.vertical, .padding6)
            }
            .padding(.vertical, .padding8)

            let repairCost = singleItemCheckoutStep?.compensation.repairCompensation?.repairCost

            hSection {
                VStack {
                    if let repairCost {
                        displayField(
                            withTitle: L10n.claimsCheckoutRepairTitle(
                                singleItemCheckoutStep?.singleItemModel?.getBrandOrModelName() ?? ""
                            ),
                            andFor: repairCost
                        )
                    } else {
                        displayField(
                            withTitle: L10n.keyGearItemViewValuationPageTitle,
                            andFor: singleItemCheckoutStep?.compensation.valueCompensation?.price
                        )
                        displayField(
                            withTitle: L10n.Claims.Payout.Age.deduction,
                            andFor: singleItemCheckoutStep?.compensation.valueCompensation?.depreciation.negative
                        )
                    }
                    displayField(
                        withTitle: L10n.Claims.Payout.Age.deductable,
                        andFor: singleItemCheckoutStep?.compensation.deductible.negative
                    )
                }
            }
            .withHeader(
                title: L10n.claimsCheckoutCountTitle,
                infoButtonDescription: repairCost != nil
                    ? L10n.claimsCheckoutRepairCalculationText : L10n.claimsCheckoutNoRepairCalculationText
            )
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding16)

            hSection {
                VStack(spacing: 16) {
                    displayField(
                        withTitle: L10n.claimsPayoutHedvigLabel,
                        useDarkTitle: true,
                        andFor: singleItemCheckoutStep?.compensation.payoutAmount
                    )
                    if repairCost != nil {
                        InfoCard(text: L10n.claimsCheckoutRepairInfoText, type: .info)
                            .accessibilitySortPriority(2)
                    }
                }
            }
            .sectionContainerStyle(.transparent)

            if repairCost == nil {
                hSection {
                    hRowDivider()
                        .hWithoutHorizontalPadding([.divider])
                }
            }

            hSection {
                if let checkoutStep = singleItemCheckoutStep {
                    let payoutMethods = checkoutStep.payoutMethods
                    let shouldShowCheckmark = payoutMethods.count > 1
                    ForEach(payoutMethods, id: \.id) { element in
                        hSection {
                            hRow {
                                hText(element.getDisplayName(), style: .heading2)
                                    .foregroundColor(hTextColor.Opaque.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .withSelectedAccessory(
                                checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark
                            )
                            .noSpacing()
                            .padding(.vertical, .padding8)
                            .onTapGesture {
                                withAnimation {
                                    claimsNavigationVm.singleItemCheckoutModel?.selectedPayoutMethod = element
                                }
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                }
            }
            .withHeader(title: L10n.Claims.Payout.Summary.method, infoButtonDescription: L10n.claimsCheckoutPayoutText)
        }
    }

    @ViewBuilder
    func displayField(withTitle title: String, useDarkTitle: Bool = false, andFor model: MonetaryAmount?) -> some View {
        hRow {
            HStack {
                if useDarkTitle {
                    hText(title, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                } else {
                    hText(title, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                Spacer()

                hText(
                    model?.formattedAmount ?? "",
                    style: .body1
                )
                .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .noSpacing()
        .hWithoutDivider
    }

    @ViewBuilder

    func displayPaymentMethodField(checkoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        if let checkoutStep = checkoutStep {
            let payoutMethods = checkoutStep.payoutMethods
            let shouldShowCheckmark = payoutMethods.count > 1
            ForEach(payoutMethods, id: \.id) { element in
                hRow {
                    hText(element.getDisplayName(), style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, .padding4)
                }
                .withSelectedAccessory(checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark)
                .cornerRadius(.cornerRadiusL)
                .padding(.bottom, .padding8)
            }
        }
    }
}

@MainActor
public class SubmitClaimCheckoutViewModel: ObservableObject {
    private let service = SubmitClaimService()
    @Published var viewState: ProcessingState = .success

    @MainActor
    func singleItemRequest(
        context: String,
        model: FlowClaimSingleItemCheckoutStepModel
    ) async -> SubmitClaimStepResponse? {
        withAnimation {
            viewState = .loading
        }
        do {
            let data = try await service.singleItemCheckoutRequest(context: context, model: model)

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

struct SubmitClaimCheckoutNoRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })

        return SubmitClaimCheckoutScreen(vm: .init())
            .environmentObject(SubmitClaimNavigationViewModel())
    }
}
