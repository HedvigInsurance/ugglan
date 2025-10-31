import Addons
import Apollo
import Authentication
import Campaign
import ChangeTier
import Chat
import Claims
import Contracts
import CrossSell
import EditCoInsured
import Environment
import Forever
import Foundation
import Home
import InsuranceEvidence
import MoveFlow
import Payment
import PresentableStore
import Profile
import SubmitClaim
import TerminateContracts
import TravelCertificate
import hCore
import hGraphQL

@MainActor
enum DI {
    static func initServices() {
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        Dependencies.shared.add(module: Module { () -> URLOpener in DefaultURLOpener() })
    }

    static func initAndRegisterClient() {
        let authorizationService = AuthenticationClientAuthLib()
        Dependencies.shared.add(module: Module { () -> AuthenticationClient in authorizationService })
        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
        let dateService = DateService()
        Dependencies.shared.add(module: Module { () -> DateService in dateService })
        if ugglanStore.state.isDemoMode {
            let featureFlagsClient = FeatureFlagsDemo()
            let hPaymentService = hPaymentClientDemo()
            let fetchClaimsService = FetchClaimsClientDemo()
            let hClaimFileUploadService = hClaimFileUploadClientDemo()
            let fetchContractsService = FetchContractsClientDemo()
            let foreverService = ForeverClientDemo()
            let profileDemoService = ProfileClientDemo()
            let homeServiceDemo = HomeClientDemo()
            let analyticsService = AnalyticsClientDemo()
            let notificationClient = NotificationClientDemo()
            let submitClaimDemoService = SubmitClaimClientDemo()
            let conversationsClient = ConversationsDemoClient()
            let changeTierClient = ChangeTierClientDemo()
            let addonClient = AddonsClientDemo()
            let fetchClaimDetailsDemoClient = FetchClaimDetailsClientDemo()
            let crossSellClient = CrossSellClientDemo()
            let campaignClient = hCampaignClientDemo()
            let insuranceEvidenceClient = InsuranceEvidenceClientDemo()

            Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in featureFlagsClient })
            Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentService })
            Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in fetchClaimsService })
            Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in hClaimFileUploadService })
            Dependencies.shared.add(module: Module { () -> FetchContractsClient in fetchContractsService })
            Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
            Dependencies.shared.add(module: Module { () -> ProfileClient in profileDemoService })
            Dependencies.shared.add(module: Module { () -> HomeClient in homeServiceDemo })
            Dependencies.shared.add(module: Module { () -> AnalyticsClient in analyticsService })
            Dependencies.shared.add(module: Module { () -> NotificationClient in notificationClient })
            Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimDemoService })
            Dependencies.shared.add(module: Module { () -> ConversationsClient in conversationsClient })
            Dependencies.shared.add(module: Module { () -> ConversationClient in conversationsClient })
            Dependencies.shared.add(module: Module { () -> ChangeTierClient in changeTierClient })
            Dependencies.shared.add(module: Module { () -> AddonsClient in addonClient })
            Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in fetchClaimDetailsDemoClient })
            Dependencies.shared.add(module: Module { () -> CrossSellClient in crossSellClient })
            Dependencies.shared.add(module: Module { () -> hCampaignClient in campaignClient })
            Dependencies.shared.add(module: Module { () -> InsuranceEvidenceClient in insuranceEvidenceClient })
        } else {
            let paymentService = hPaymentClientOctopus()
            let hCampaignsService = hCampaignsClientOctopus()
            let networkClientUrlSession = URLSession(
                configuration: .default,
                delegate: urlSessionTaskDeleage(),
                delegateQueue: nil
            )
            let networkClient = NetworkClient(sessionClient: networkClientUrlSession)
            let moveFlowService = MoveFlowClientOctopus()
            let foreverService = ForeverClientOctopus()
            let profileService = ProfileClientOctopus()
            let editCoInsuredService = EditCoInsuredClientOctopus()
            let homeService = HomeClientOctopus()
            let terminateContractsService = TerminateContractsClientOctopus()
            let fetchContractsService = FetchContractsClientOctopus()
            let hFetchClaimsService = FetchClaimsClientOctopus()
            let travelInsuranceService = TravelInsuranceClientOctopus()
            let featureFlagsClientUnleash = FeatureFlagsUnleash(environment: Environment.current)
            let analyticsService = AnalyticsClientOctopus()
            let notificationService = NotificationClientOctopus()
            let hFetchEntrypointsClient = FetchEntrypointsClientOctopus()
            let submitClaimService = SubmitClaimClientOctopus()
            let conversationClient = ConversationClientOctopus()
            let conversationsClient = ConversationsClientOctopus()
            let changeTierClient = ChangeTierClientOctopus()
            let addonClient = AddonsClientOctopus()
            let fetchClaimDetailsClient = FetchClaimDetailsClientOctopus()
            let crossSellClient = CrossSellClientOctopus()
            let insuranceEvidenceClient = InsuranceEvidenceClientOctopus()
            let claimIntentClient = ClaimIntentClientOctopus()

            switch Environment.current {
            case .staging:
                Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in featureFlagsClientUnleash })
                Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in travelInsuranceService })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in hFetchClaimsService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsClient in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowClient in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileClient in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in editCoInsuredService })
                Dependencies.shared.add(module: Module { () -> HomeClient in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsClient in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsClient in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in hFetchEntrypointsClient })
                Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimService })
                Dependencies.shared.add(module: Module { () -> ConversationClient in conversationClient })
                Dependencies.shared.add(module: Module { () -> ConversationsClient in conversationsClient })
                Dependencies.shared.add(module: Module { () -> ChangeTierClient in changeTierClient })
                Dependencies.shared.add(module: Module { () -> AddonsClient in addonClient })
                Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in fetchClaimDetailsClient })
                Dependencies.shared.add(module: Module { () -> CrossSellClient in crossSellClient })
                Dependencies.shared.add(module: Module { () -> InsuranceEvidenceClient in insuranceEvidenceClient })
                Dependencies.shared.add(module: Module { () -> ClaimIntentClient in claimIntentClient })
            case .production, .custom:
                Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in featureFlagsClientUnleash })
                Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in travelInsuranceService })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in hFetchClaimsService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsClient in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowClient in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileClient in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in editCoInsuredService })
                Dependencies.shared.add(module: Module { () -> HomeClient in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsClient in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsClient in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in hFetchEntrypointsClient })
                Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimService })
                Dependencies.shared.add(module: Module { () -> ConversationClient in conversationClient })
                Dependencies.shared.add(module: Module { () -> ConversationsClient in conversationsClient })
                Dependencies.shared.add(module: Module { () -> ChangeTierClient in changeTierClient })
                Dependencies.shared.add(module: Module { () -> AddonsClient in addonClient })
                Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in fetchClaimDetailsClient })
                Dependencies.shared.add(module: Module { () -> CrossSellClient in crossSellClient })
                Dependencies.shared.add(module: Module { () -> InsuranceEvidenceClient in insuranceEvidenceClient })
                Dependencies.shared.add(module: Module { () -> ClaimIntentClient in claimIntentClient })
            }
        }
    }

    static func initNetworkClients() async {
        let hApollo = await ApolloClient.createClient()
        Dependencies.shared.add(module: Module { hApollo.octopus })
    }
}
