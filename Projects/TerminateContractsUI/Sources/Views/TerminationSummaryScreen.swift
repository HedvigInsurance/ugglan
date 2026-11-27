import SwiftUI
import TerminateContractsCore
import hCore
import hCoreUI

struct TerminationSummaryScreen: View {
    @Environment(TerminationFlowNavigationViewModel.self) var terminationNavigationVm

    init() {}

    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    titleText,
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .heading2,
                    L10n.terminationFlowSummarySubtitle
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding16) {
                    VStack(spacing: .padding4) {
                        insuranceDetailsView
                        terminationDateView
                        withdrawalEmailView
                        withdrawalInfoCard
                        infoCard
                    }

                    hSection {
                        VStack(spacing: .padding8) {
                            hButton(
                                .large,
                                .primary,
                                content: .init(title: terminateButtonTitle)
                            ) {
                                terminationNavigationVm.isConfirmTerminationPresented = true
                            }
                            hButton(
                                .large,
                                .ghost,
                                content: .init(title: L10n.terminationKeepInsuranceButton)
                            ) { terminationNavigationVm.router.dismiss() }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .onReceive(NotificationCenter.default.publisher(for: .memberEmailUpdated)) { notification in
                if let email = notification.object as? String {
                    terminationNavigationVm.updateWithdrawalEmail(email)
                }
            }
    }

    private var titleText: String {
        terminationNavigationVm.isWithdrawal
            ? L10n.terminationFlowWithdrawalTitle : L10n.terminationFlowCancellationTitle
    }

    private var terminateButtonTitle: String {
        terminationNavigationVm.isWithdrawal ? L10n.terminationFlowWithdrawalButton : L10n.terminationButton
    }

    @ViewBuilder
    private var mainContent: some View {
        HStack(spacing: .padding12) {
            let image =
                terminationNavigationVm.config?.typeOfContract?.pillowType.bgImage ?? hCoreUIAssets.pillowHome.view

            image
                .resizable()
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                hText(terminationNavigationVm.config?.contractDisplayName ?? "")
                hText(terminationNavigationVm.config?.contractExposureName ?? "")
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .padding(.bottom, .padding16)
    }

    private var addonContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.terminationAddonCoverageTitle)
            ForEach(terminationNavigationVm.extraCoverage, id: \.self) { item in
                getRow(for: item)
            }
        }
    }

    private func getRow(for item: ExtraCoverageItem) -> some View {
        HStack {
            hText(item.displayName)
            Spacer()
            if let displayValue = item.displayValue {
                hText(displayValue)
            }
        }
        .foregroundColor(hTextColor.Translucent.secondary)
    }

    /// The member's email, where the withdrawal confirmation is sent.
    @ViewBuilder
    private var withdrawalEmailView: some View {
        if let email = terminationNavigationVm.withdrawal?.email, !email.isEmpty {
            hSection {
                LockedTerminationField(
                    value: email,
                    placeholder: L10n.terminationFlowWithdrawalConfirmationSentTo
                ) {
                    terminationNavigationVm.isChangeEmailInfoPresented = true
                }
            }
        }
    }

    /// The status text returned when the withdrawal was started.
    @ViewBuilder
    private var withdrawalInfoCard: some View {
        if let statusText = terminationNavigationVm.withdrawal?.statusText, !statusText.isEmpty {
            hSection {
                InfoCard(text: statusText, type: .neutral)
            }
            .accessibilitySortPriority(1)
        }
    }

    /// For a withdrawal the notification is shown in the confirmation sheet instead.
    @ViewBuilder
    private var infoCard: some View {
        if !terminationNavigationVm.isWithdrawal, let notification = terminationNavigationVm.notification {
            hSection {
                TerminationNotificationCard(notification: notification)
            }
            .accessibilitySortPriority(1)
        }
    }

    private var insuranceDetailsView: some View {
        let withAddonView = !terminationNavigationVm.extraCoverage.isEmpty
        return hSection {
            StatusCard(
                onSelected: {},
                mainContent: mainContent,
                bottomComponent: !withAddonView
                    ? nil
                    : {
                        addonContent
                    }
            )
            .hCardWithoutSpacing
            .hCardWithDivider
        }
    }

    @ViewBuilder
    private var terminationDateView: some View {
        if let date = terminationNavigationVm.selectedDate {
            hSection {
                if terminationNavigationVm.isWithdrawal {
                    // A withdrawal ends on a date set by the backend, so the member can't change it.
                    LockedTerminationField(value: date.displayDateDDMMMYYYYFormat)
                } else {
                    hFloatingField(
                        value: date.displayDateDDMMMYYYYFormat,
                        placeholder: L10n.terminationFlowDateFieldText
                    ) {}
                }
            }
        }
    }
}

struct TerminationNotificationCard: View {
    let notification: TerminationNotification

    var body: some View {
        InfoCard(text: notification.message, type: type)
    }

    private var type: NotificationType {
        switch notification.type {
        case .info:
            return .info
        case .warning:
            return .attention
        }
    }
}

@MainActor
private func previewNavigationModel(contractId: String) -> TerminationFlowNavigationViewModel {
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    func config(_ contractId: String) -> TerminationConfirmConfig {
        .init(
            contractId: contractId,
            contractDisplayName: "Homeowner",
            contractExposureName: "Bellmansgsatan 19A",
            activeFrom: "2024-12-15",
            typeOfContract: .seApartmentBrf
        )
    }

    let navigationModel = TerminationFlowNavigationViewModel(
        configs: [config("1"), config("2")],
        terminateInsuranceViewModel: .init()
    )
    navigationModel.config = config(contractId)
    navigationModel.notification = .init(
        message: "This is a message for the user to see in the notification.",
        type: .info
    )
    return navigationModel
}

#Preview {
    let navigationModel = previewNavigationModel(contractId: "2")
    navigationModel.selectedDate = Date()

    return TerminationSummaryScreen()
        .environment(navigationModel)
}

#Preview {
    TerminationSummaryScreen()
        .environment(previewNavigationModel(contractId: ""))
}

#Preview("Withdrawal") {
    let navigationModel = previewNavigationModel(contractId: "2")
    navigationModel.withdrawal = .init(
        statusText: "You can withdraw your insurance within 14 days of purchase.",
        action: .terminateWithDate(minDate: "2024-12-15", maxDate: "2024-12-15", extraCoverage: []),
        email: "member@hedvig.com"
    )
    navigationModel.selectedDate = Date()

    return TerminationSummaryScreen()
        .environment(navigationModel)
}
