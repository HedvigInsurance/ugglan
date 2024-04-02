import Apollo
import Authentication
import Chat
import Claims
import Contracts
import EditCoInsured
import Forever
import Foundation
import Home
import MoveFlow
import Payment
import Presentation
import Profile
import TerminateContracts
import TravelCertificateShared
import hCore
import hGraphQL

extension ApolloClient {
    public static func initAndRegisterClient() {
        let authorizationService = AuthentificationServiceAuthLib()
        Dependencies.shared.add(module: Module { () -> AuthentificationService in authorizationService })
        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
        if ugglanStore.state.isDemoMode {
            let featureFlags = FeatureFlagsDemo()
            let hPaymentService = hPaymentServiceDemo()
            let fetchClaimService = FetchClaimServiceDemo()
            let hClaimFileUploadService = hClaimFileUploadServiceDemo()
            let fetchContractsService = FetchContractsServiceDemo()
            let foreverService = ForeverServiceDemo()
            let profileDemoService = ProfileDemoService()
            let homeServiceDemo = HomeServiceDemo()
            let analyticsService = AnalyticsServiceDemo()
            let notificationClient = NotificationClientDemo()
            let submitClaimDemoService = SubmitClaimDemoService()
            Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlags })
            Dependencies.shared.add(module: Module { () -> hPaymentService in hPaymentService })
            Dependencies.shared.add(module: Module { () -> hFetchClaimService in fetchClaimService })
            Dependencies.shared.add(module: Module { () -> hClaimFileUploadService in hClaimFileUploadService })
            Dependencies.shared.add(module: Module { () -> FetchContractsService in fetchContractsService })
            Dependencies.shared.add(module: Module { () -> ForeverService in foreverService })
            Dependencies.shared.add(module: Module { () -> ProfileService in profileDemoService })
            Dependencies.shared.add(module: Module { () -> HomeService in homeServiceDemo })
            Dependencies.shared.add(module: Module { () -> AnalyticsService in analyticsService })
            Dependencies.shared.add(module: Module { () -> NotificationClient in notificationClient })
            Dependencies.shared.add(module: Module { () -> SubmitClaimService in submitClaimDemoService })
        } else {
            let hApollo = self.createClient()
            let paymentService = hPaymentServiceOctopus()
            let hCampaignsService = hCampaingsServiceOctopus()
            let networkClient = NetworkClient()
            let messagesClient = FetchMessagesClientOctopus()
            let sendMessage = SendMessagesClientOctopus()
            let moveFlowService = MoveFlowServiceOctopus()
            let foreverService = ForeverServiceOctopus()
            let profileService = ProfileServiceOctopus()
            let editCoInsuredService = EditCoInsuredServiceOctopus()
            let homeService = HomeServiceOctopus()
            let terminateContractsService = TerminateContractsOctopus()
            let fetchContractsService = FetchContractsServiceOctopus()
            let hFetchClaimService = FetchClaimServiceOctopus()
            let travelInsuranceService = TravelInsuranceClientOctopus()
            let featureFlagsUnleash = FeatureFlagsUnleash(environment: Environment.current)
            let analyticsService = AnalyticsServiceOctopus()
            let notificationService = NotificationClientOctopus()
            let hFetchEntrypointsService = FetchEntrypointsServiceOctopus()
            let submitClaimService = SubmitClaimServiceOctopus()
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
                Dependencies.shared.add(module: Module { () -> hPaymentService in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimService in hFetchClaimService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadService in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsService in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowService in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverService in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileService in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredService in editCoInsuredService })
                Dependencies.shared.add(module: Module { () -> HomeService in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsService in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsService in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsService in hFetchEntrypointsService })
                Dependencies.shared.add(module: Module { () -> SubmitClaimService in submitClaimService })
            case .production, .custom:
                Dependencies.shared.add(module: Module { hApollo.octopus })
                Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlagsUnleash })
                Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in travelInsuranceService })
                Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchMessagesClient in messagesClient })
                Dependencies.shared.add(module: Module { () -> SendMessageClient in sendMessage })
                Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
                Dependencies.shared.add(module: Module { () -> AdyenService in networkClient })
                Dependencies.shared.add(module: Module { () -> hPaymentService in paymentService })
                Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsService })
                Dependencies.shared.add(module: Module { () -> hFetchClaimService in hFetchClaimService })
                Dependencies.shared.add(module: Module { () -> hClaimFileUploadService in networkClient })
                Dependencies.shared.add(module: Module { () -> FetchContractsService in fetchContractsService })
                Dependencies.shared.add(module: Module { () -> MoveFlowService in moveFlowService })
                Dependencies.shared.add(module: Module { () -> ForeverService in foreverService })
                Dependencies.shared.add(module: Module { () -> ProfileService in profileService })
                Dependencies.shared.add(module: Module { () -> EditCoInsuredService in editCoInsuredService })
                Dependencies.shared.add(module: Module { () -> HomeService in homeService })
                Dependencies.shared.add(module: Module { () -> TerminateContractsService in terminateContractsService })
                Dependencies.shared.add(module: Module { () -> AnalyticsService in analyticsService })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
                Dependencies.shared.add(module: Module { () -> hFetchEntrypointsService in hFetchEntrypointsService })
                Dependencies.shared.add(module: Module { () -> SubmitClaimService in submitClaimService })
            }
        }
    }
}
