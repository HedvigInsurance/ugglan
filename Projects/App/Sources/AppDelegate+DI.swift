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
import Presentation
import Profile
import TerminateContracts
import TravelCertificate
import hCore
import hGraphQL

extension ApolloClient {
    public static func initAndRegisterClient() {
        let authorizationService = AuthenticationClientAuthLib()
        Dependencies.shared.add(module: Module { () -> AuthenticationClient in authorizationService })
        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
        if ugglanStore.state.isDemoMode {
            let featureFlags = FeatureFlagsDemo()
            let hPaymentService = hPaymentClientDemo()
            let fetchClaimService = FetchClaimClientDemo()
            let hClaimFileUploadService = hClaimFileUploadClientDemo()
            let fetchContractsService = FetchContractsServiceDemo()
            let foreverService = ForeverDemoClient()
            let profileDemoService = ProfileClientDemo()
            let homeServiceDemo = HomeServiceDemo()
            let analyticsService = AnalyticsServiceDemo()
            let notificationClient = NotificationClientDemo()
            let submitClaimDemoService = SubmitClaimClientDemo()
            Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlags })
            Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentService })
            Dependencies.shared.add(module: Module { () -> hFetchClaimClient in fetchClaimService })
            Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in hClaimFileUploadService })
            Dependencies.shared.add(module: Module { () -> FetchContractsService in fetchContractsService })
            Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
            Dependencies.shared.add(module: Module { () -> ProfileClient in profileDemoService })
            Dependencies.shared.add(module: Module { () -> HomeService in homeServiceDemo })
            Dependencies.shared.add(module: Module { () -> AnalyticsService in analyticsService })
            Dependencies.shared.add(module: Module { () -> NotificationClient in notificationClient })
            Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimDemoService })
        } else {
            let hApollo = self.createClient()
            let paymentService = hPaymentClientOctopus()
            let hCampaignsService = hCampaingsClientOctopus()
            let networkClient = NetworkClient()
            let messagesClient = FetchMessagesClientOctopus()
            let sendMessage = SendMessagesClientOctopus()
            let moveFlowService = MoveFlowServiceOctopus()
            let foreverService = ForeverClientOctopus()
            let profileService = ProfileClientOctopus()
            let editCoInsuredService = EditCoInsuredClientOctopus()
            let editCoInsuredSharedService = EditCoInsuredSharedClientOctopus()
            let homeService = HomeServiceOctopus()
            let terminateContractsService = TerminateContractsOctopus()
            let fetchContractsService = FetchContractsServiceOctopus()
            let hFetchClaimService = FetchClaimClientOctopus()
            let travelInsuranceService = TravelInsuranceClientOctopus()
            let featureFlagsUnleash = FeatureFlagsUnleash(environment: Environment.current)
            let analyticsService = AnalyticsServiceOctopus()
            let notificationService = NotificationClientOctopus()
            let hFetchEntrypointsService = FetchEntrypointsClientOctopus()
            let submitClaimService = SubmitClaimClientOctopus()
            switch Environment.current {
            case .staging:
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlagsUnleash })
                Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in travelInsuranceService })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchMessagesClient in messagesClient })
                Dependencies.shared.add(module: Module { () -> SendMessageClient in sendMessage })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> AdyenService in networkClient })
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimClient in hFetchClaimService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsService in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowService in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileClient in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in editCoInsuredService })
                Dependencies.shared.add(
                    module: Module { () -> EditCoInsuredSharedClient in editCoInsuredSharedService }
                )
                Dependencies.shared.add(module: Module { () -> HomeService in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsService in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsService in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in hFetchEntrypointsService })
                Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimService })
            case .production, .custom:
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlagsUnleash })
                Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in travelInsuranceService })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchMessagesClient in messagesClient })
                Dependencies.shared.add(module: Module { () -> SendMessageClient in sendMessage })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> AdyenService in networkClient })
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimClient in hFetchClaimService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsService in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowService in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverClient in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileClient in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in editCoInsuredService })
                Dependencies.shared.add(
                    module: Module { () -> EditCoInsuredSharedClient in editCoInsuredSharedService }
                )
                Dependencies.shared.add(module: Module { () -> HomeService in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsService in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsService in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in hFetchEntrypointsService })
                Dependencies.shared.add(module: Module { () -> SubmitClaimClient in submitClaimService })
            }
        }
    }
}
