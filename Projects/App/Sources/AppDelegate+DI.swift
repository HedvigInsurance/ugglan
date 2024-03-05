import Apollo
import Chat
import Claims
import Contracts
import EditCoInsured
import Forever
import Foundation
import Home
import MoveFlow
import Payment
import Profile
import TerminateContracts
import TravelCertificate
import hCore
import hGraphQL

extension ApolloClient {
    public static func initAndRegisterClient() {
        if ApplicationContext.shared.isDemoMode {
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
            //            Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in TravelInsuranceClientDemo() })
            //            Dependencies.shared.add(module: Module { () -> ChatFileUploaderClient in networkClient })
            //            Dependencies.shared.add(module: Module { () -> FetchMessagesClient in messagesClient })
            //            Dependencies.shared.add(module: Module { () -> SendMessageClient in sendMessage })
            //            Dependencies.shared.add(module: Module { () -> FileUploaderClient in networkClient })
            //            Dependencies.shared.add(module: Module { () -> AdyenService in networkClient })
            Dependencies.shared.add(module: Module { () -> hPaymentService in hPaymentServiceDemo() })
            //            Dependencies.shared.add(module: Module { () -> hForeverCodeService in hForeverCodeService })
            //            Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsService })
            Dependencies.shared.add(module: Module { () -> hFetchClaimService in FetchClaimServiceDemo() })
            //            Dependencies.shared.add(module: Module { () -> hClaimFileUploadService in networkClient })
            Dependencies.shared.add(module: Module { () -> FetchContractsService in FetchContractsServiceDemo() })
            //            Dependencies.shared.add(module: Module { () -> MoveFlowService in moveFlowService })
            Dependencies.shared.add(module: Module { () -> ForeverService in ForeverServiceDemo() })
            Dependencies.shared.add(module: Module { () -> ProfileService in ProfileDemoService() })
            //            Dependencies.shared.add(module: Module { () -> EditCoInsuredService in editCoInsuredService })
            Dependencies.shared.add(module: Module { () -> HomeService in HomeServiceDemo() })
            //            Dependencies.shared.add(module: Module { () -> TerminateContractsService in terminateContractsService })
            Dependencies.shared.add(module: Module { () -> AnalyticsCoordinator in AnalyticsCoordinatorDemo() })

            Dependencies.shared.add(module: Module { () -> NotificationClient in NotificationClientDemo() })
        } else {
            let hApollo = self.createClient()
            let paymentService = hPaymentServiceOctopus()
            let hForeverCodeService = hForeverCodeServiceOctopus()
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
            let analyticsCoordinator = AnalyticsCoordinatorOctopus()
            let notificationService = NotificationClientOctopus()
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
                Dependencies.shared.add(module: Module { () -> hForeverCodeService in hForeverCodeService })
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
                Dependencies.shared.add(module: Module { () -> AnalyticsCoordinator in analyticsCoordinator })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
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
                Dependencies.shared.add(module: Module { () -> hForeverCodeService in hForeverCodeService })
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
                Dependencies.shared.add(module: Module { () -> AnalyticsCoordinator in analyticsCoordinator })
                Dependencies.shared.add(module: Module { () -> NotificationClient in notificationService })
            }
        }
    }
}
