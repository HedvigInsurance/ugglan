import Apollo
import Authentication
import Chat
import Claims
import Contracts
import EditCoInsured
import EditCoInsuredShared
import Forever
import Foundation
import Home
import MoveFlow
import Payment
import Profile
import StoreContainer
import TerminateContracts
import TravelCertificate
import hCore
import hGraphQL

extension ApolloClient {
    public static func initAndRegisterClient() {
        let authorizationService = AuthenticationClientAuthLib()
        Dependencies.shared.add(module: Module { () -> AuthenticationClient in authorizationService })
        let ugglanStore: UgglanStore = hGlobalPresentableStoreContainer.get()
        let dateService = DateService()
        Dependencies.shared.add(module: Module { () -> DateService in dateService })
        if ugglanStore.state.isDemoMode {
            let featureFlags = FeatureFlagsDemo()
            let hPaymentService = hPaymentClientDemo()
            let fetchClaimService = FetchClaimClientDemo()
            let hClaimFileUploadService = hClaimFileUploadClientDemo()
            let fetchContractsService = FetchContractsClientDemo()
            let foreverService = ForeverClientDemo()
            let profileDemoService = ProfileClientDemo()
            let homeServiceDemo = HomeClientDemo()
            let analyticsService = AnalyticsClientDemo()
            let notificationClient = NotificationClientDemo()
            let submitClaimDemoService = SubmitClaimClientDemo()
            let conversationsClient = ConversationsDemoClient()
            let conversationClient = ConversationDemoClient()
            let adyenClient = AdyenClientDemo()
            Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlags })
            Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentService })
            Dependencies.shared.add(module: Module { () -> hFetchClaimClient in fetchClaimService })
            Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in hClaimFileUploadService })
            Dependencies.shared.add(module: Module { () -> FetchContractsClient in fetchContractsService })
            Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
            Dependencies.shared.add(module: Module { () -> ProfileClient in profileDemoService })
            Dependencies.shared.add(module: Module { () -> HomeClient in homeServiceDemo })
            Dependencies.shared.add(module: Module { () -> AnalyticsClient in analyticsService })
            Dependencies.shared.add(module: Module { () -> NotificationClient in notificationClient })
            Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimDemoService })
            Dependencies.shared.add(module: Module { () -> ConversationsClient in conversationsClient })
            Dependencies.shared.add(module: Module { () -> ConversationClient in conversationClient })
            Dependencies.shared.add(module: Module { () -> AdyenClient in adyenClient })
        } else {
            let hApollo = self.createClient()
            let paymentService = hPaymentClientOctopus()
            let hCampaignsService = hCampaingsClientOctopus()
            let networkClient = NetworkClient()
            let messagesClient = FetchMessagesClientOctopus()
            let sendMessage = SendMessagesClientOctopus()
            let moveFlowService = MoveFlowClientOctopus()
            let foreverService = ForeverClientOctopus()
            let profileService = ProfileClientOctopus()
            let editCoInsuredService = EditCoInsuredClientOctopus()
            let editCoInsuredSharedService = EditCoInsuredSharedClientOctopus()
            let homeService = HomeClientOctopus()
            let terminateContractsService = TerminateContractsClientOctopus()
            let fetchContractsService = FetchContractsClientOctopus()
            let hFetchClaimService = FetchClaimClientOctopus()
            let travelInsuranceService = TravelInsuranceClientOctopus()
            let featureFlagsUnleash = FeatureFlagsUnleash(environment: Environment.current)
            let analyticsService = AnalyticsClientOctopus()
            let notificationService = NotificationClientOctopus()
            let hFetchEntrypointsService = FetchEntrypointsClientOctopus()
            let submitClaimService = SubmitClaimClientOctopus()
            let conversationClient = ConversationClientOctopus()
            let conversationsClient = ConversationsClientOctopus()
            switch Environment.current {
            case .staging:
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlagsUnleash })
                Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in travelInsuranceService })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchMessagesClient in messagesClient })
                Dependencies.shared.add(module: Module { () -> SendMessageClient in sendMessage })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> AdyenClient in networkClient })
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimClient in hFetchClaimService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsClient in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowClient in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileClient in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in editCoInsuredService })
                Dependencies.shared.add(
                    module: Module { () -> EditCoInsuredSharedClient in editCoInsuredSharedService }
                )
                Dependencies.shared.add(module: Module { () -> HomeClient in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsClient in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsClient in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in hFetchEntrypointsService })
                Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimService })
                Dependencies.shared.add(module: Module { () -> ConversationClient in conversationClient })
                Dependencies.shared.add(module: Module { () -> ConversationsClient in conversationsClient })
            case .production, .custom:
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlagsUnleash })
                Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in travelInsuranceService })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchMessagesClient in messagesClient })
                Dependencies.shared.add(module: Module { () -> SendMessageClient in sendMessage })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> AdyenClient in networkClient })
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimClient in hFetchClaimService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsClient in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowClient in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileClient in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in editCoInsuredService })
                Dependencies.shared.add(
                    module: Module { () -> EditCoInsuredSharedClient in editCoInsuredSharedService }
                )
                Dependencies.shared.add(module: Module { () -> HomeClient in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsClient in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsClient in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in hFetchEntrypointsService })
                Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimService })
                Dependencies.shared.add(module: Module { () -> ConversationClient in conversationClient })
                Dependencies.shared.add(module: Module { () -> ConversationsClient in conversationsClient })

            }
        }
    }
}
