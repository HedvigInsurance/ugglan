// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

nonisolated public protocol OctopusGraphQL_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == OctopusGraphQL.SchemaMetadata {}

nonisolated public protocol OctopusGraphQL_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == OctopusGraphQL.SchemaMetadata {}

nonisolated public protocol OctopusGraphQL_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == OctopusGraphQL.SchemaMetadata {}

nonisolated public protocol OctopusGraphQL_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == OctopusGraphQL.SchemaMetadata {}

public extension OctopusGraphQL {
  typealias SelectionSet = OctopusGraphQL_SelectionSet

  typealias InlineFragment = OctopusGraphQL_InlineFragment

  typealias MutableSelectionSet = OctopusGraphQL_MutableSelectionSet

  typealias MutableInlineFragment = OctopusGraphQL_MutableInlineFragment

  nonisolated enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    private static let objectTypeMap: [String: ApolloAPI.Object] = [
      "ActiveAddon": OctopusGraphQL.Objects.ActiveAddon,
      "Addon": OctopusGraphQL.Objects.Addon,
      "AddonActivationOutput": OctopusGraphQL.Objects.AddonActivationOutput,
      "AddonBanner": OctopusGraphQL.Objects.AddonBanner,
      "AddonContractQuote": OctopusGraphQL.Objects.AddonContractQuote,
      "AddonDisplayItem": OctopusGraphQL.Objects.AddonDisplayItem,
      "AddonOffer": OctopusGraphQL.Objects.AddonOffer,
      "AddonOfferDeflect": OctopusGraphQL.Objects.AddonOfferDeflect,
      "AddonOfferQuote": OctopusGraphQL.Objects.AddonOfferQuote,
      "AddonOfferSelectable": OctopusGraphQL.Objects.AddonOfferSelectable,
      "AddonOfferToggleable": OctopusGraphQL.Objects.AddonOfferToggleable,
      "AddonPeril": OctopusGraphQL.Objects.AddonPeril,
      "AddonRemoveOffer": OctopusGraphQL.Objects.AddonRemoveOffer,
      "AddonVariant": OctopusGraphQL.Objects.AddonVariant,
      "Agreement": OctopusGraphQL.Objects.Agreement,
      "AgreementDisplayItem": OctopusGraphQL.Objects.AgreementDisplayItem,
      "AvailableAddon": OctopusGraphQL.Objects.AvailableAddon,
      "ChangeTierDeductibleAddonQuote": OctopusGraphQL.Objects.ChangeTierDeductibleAddonQuote,
      "ChangeTierDeductibleCommitIntentOutput": OctopusGraphQL.Objects.ChangeTierDeductibleCommitIntentOutput,
      "ChangeTierDeductibleCreateIntentOutput": OctopusGraphQL.Objects.ChangeTierDeductibleCreateIntentOutput,
      "ChangeTierDeductibleDisplayItem": OctopusGraphQL.Objects.ChangeTierDeductibleDisplayItem,
      "ChangeTierDeductibleFromAgreement": OctopusGraphQL.Objects.ChangeTierDeductibleFromAgreement,
      "ChangeTierDeductibleIntent": OctopusGraphQL.Objects.ChangeTierDeductibleIntent,
      "ChangeTierDeductibleQuote": OctopusGraphQL.Objects.ChangeTierDeductibleQuote,
      "ChangeTierDeflectOutput": OctopusGraphQL.Objects.ChangeTierDeflectOutput,
      "ChangeTierPriceDetailItem": OctopusGraphQL.Objects.ChangeTierPriceDetailItem,
      "ChatMessageAction": OctopusGraphQL.Objects.ChatMessageAction,
      "ChatMessageDisclaimer": OctopusGraphQL.Objects.ChatMessageDisclaimer,
      "ChatMessageFile": OctopusGraphQL.Objects.ChatMessageFile,
      "ChatMessageMutationOutput": OctopusGraphQL.Objects.ChatMessageMutationOutput,
      "ChatMessagePage": OctopusGraphQL.Objects.ChatMessagePage,
      "ChatMessageText": OctopusGraphQL.Objects.ChatMessageText,
      "ChatMessageTextAction": OctopusGraphQL.Objects.ChatMessageTextAction,
      "Claim": OctopusGraphQL.Objects.Claim,
      "ClaimDisplayItem": OctopusGraphQL.Objects.ClaimDisplayItem,
      "ClaimFile": OctopusGraphQL.Objects.ClaimFile,
      "ClaimIntent": OctopusGraphQL.Objects.ClaimIntent,
      "ClaimIntentFormFieldSearchOutput": OctopusGraphQL.Objects.ClaimIntentFormFieldSearchOutput,
      "ClaimIntentMutationOutput": OctopusGraphQL.Objects.ClaimIntentMutationOutput,
      "ClaimIntentStep": OctopusGraphQL.Objects.ClaimIntentStep,
      "ClaimIntentStepContentAudioRecording": OctopusGraphQL.Objects.ClaimIntentStepContentAudioRecording,
      "ClaimIntentStepContentDeflection": OctopusGraphQL.Objects.ClaimIntentStepContentDeflection,
      "ClaimIntentStepContentDeflectionInfoBlock": OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionInfoBlock,
      "ClaimIntentStepContentDeflectionMessage": OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionMessage,
      "ClaimIntentStepContentDeflectionPartner": OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionPartner,
      "ClaimIntentStepContentDeflectionSimplePartner": OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionSimplePartner,
      "ClaimIntentStepContentFileUpload": OctopusGraphQL.Objects.ClaimIntentStepContentFileUpload,
      "ClaimIntentStepContentFileUploadFile": OctopusGraphQL.Objects.ClaimIntentStepContentFileUploadFile,
      "ClaimIntentStepContentForm": OctopusGraphQL.Objects.ClaimIntentStepContentForm,
      "ClaimIntentStepContentFormField": OctopusGraphQL.Objects.ClaimIntentStepContentFormField,
      "ClaimIntentStepContentFormFieldOption": OctopusGraphQL.Objects.ClaimIntentStepContentFormFieldOption,
      "ClaimIntentStepContentFormFieldSearchData": OctopusGraphQL.Objects.ClaimIntentStepContentFormFieldSearchData,
      "ClaimIntentStepContentInformation": OctopusGraphQL.Objects.ClaimIntentStepContentInformation,
      "ClaimIntentStepContentSelect": OctopusGraphQL.Objects.ClaimIntentStepContentSelect,
      "ClaimIntentStepContentSelectOption": OctopusGraphQL.Objects.ClaimIntentStepContentSelectOption,
      "ClaimIntentStepContentSummary": OctopusGraphQL.Objects.ClaimIntentStepContentSummary,
      "ClaimIntentStepContentSummaryAnswer": OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswer,
      "ClaimIntentStepContentSummaryAnswerAudio": OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswerAudio,
      "ClaimIntentStepContentSummaryAnswerFiles": OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswerFiles,
      "ClaimIntentStepContentSummaryAnswerText": OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswerText,
      "ClaimIntentStepContentSummaryAudioRecording": OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAudioRecording,
      "ClaimIntentStepContentSummaryFileUpload": OctopusGraphQL.Objects.ClaimIntentStepContentSummaryFileUpload,
      "ClaimIntentStepContentSummaryItem": OctopusGraphQL.Objects.ClaimIntentStepContentSummaryItem,
      "ClaimIntentStepContentTask": OctopusGraphQL.Objects.ClaimIntentStepContentTask,
      "ClaimMutationOutput": OctopusGraphQL.Objects.ClaimMutationOutput,
      "Contract": OctopusGraphQL.Objects.Contract,
      "ContractAddon": OctopusGraphQL.Objects.ContractAddon,
      "ContractCoInsured": OctopusGraphQL.Objects.ContractCoInsured,
      "ContractCoOwner": OctopusGraphQL.Objects.ContractCoOwner,
      "ContractDiscountDetails": OctopusGraphQL.Objects.ContractDiscountDetails,
      "ContractDiscountItem": OctopusGraphQL.Objects.ContractDiscountItem,
      "Conversation": OctopusGraphQL.Objects.Conversation,
      "CrossSell": OctopusGraphQL.Objects.CrossSell,
      "CrossSellV2": OctopusGraphQL.Objects.CrossSellV2,
      "Deductible": OctopusGraphQL.Objects.Deductible,
      "FirstVetAction": OctopusGraphQL.Objects.FirstVetAction,
      "FirstVetSection": OctopusGraphQL.Objects.FirstVetSection,
      "InsurableLimit": OctopusGraphQL.Objects.InsurableLimit,
      "InsuranceDocument": OctopusGraphQL.Objects.InsuranceDocument,
      "InsuranceEvidenceInformation": OctopusGraphQL.Objects.InsuranceEvidenceInformation,
      "InsuranceEvidenceOutput": OctopusGraphQL.Objects.InsuranceEvidenceOutput,
      "ItemCost": OctopusGraphQL.Objects.ItemCost,
      "ItemDiscount": OctopusGraphQL.Objects.ItemDiscount,
      "LinkInfo": OctopusGraphQL.Objects.LinkInfo,
      "ManuallyChargeMemberMutationOutput": OctopusGraphQL.Objects.ManuallyChargeMemberMutationOutput,
      "Member": OctopusGraphQL.Objects.Member,
      "MemberActions": OctopusGraphQL.Objects.MemberActions,
      "MemberCharge": OctopusGraphQL.Objects.MemberCharge,
      "MemberChargeBreakdownItem": OctopusGraphQL.Objects.MemberChargeBreakdownItem,
      "MemberChargeBreakdownItemPeriod": OctopusGraphQL.Objects.MemberChargeBreakdownItemPeriod,
      "MemberChargePriceBreakdownItem": OctopusGraphQL.Objects.MemberChargePriceBreakdownItem,
      "MemberFAQ": OctopusGraphQL.Objects.MemberFAQ,
      "MemberFAQItem": OctopusGraphQL.Objects.MemberFAQItem,
      "MemberFAQTopic": OctopusGraphQL.Objects.MemberFAQTopic,
      "MemberImportantMessage": OctopusGraphQL.Objects.MemberImportantMessage,
      "MemberInsuranceCost": OctopusGraphQL.Objects.MemberInsuranceCost,
      "MemberMutationOutput": OctopusGraphQL.Objects.MemberMutationOutput,
      "MemberPaymentAvailablePaymentMethod": OctopusGraphQL.Objects.MemberPaymentAvailablePaymentMethod,
      "MemberPaymentMethod": OctopusGraphQL.Objects.MemberPaymentMethod,
      "MemberPaymentMethods": OctopusGraphQL.Objects.MemberPaymentMethods,
      "MemberReferral": OctopusGraphQL.Objects.MemberReferral,
      "MemberReferralInformation": OctopusGraphQL.Objects.MemberReferralInformation,
      "MemberReferralInformationMutationOutput": OctopusGraphQL.Objects.MemberReferralInformationMutationOutput,
      "MidtermChangeIntent": OctopusGraphQL.Objects.MidtermChangeIntent,
      "MidtermChangeIntentMutationOutput": OctopusGraphQL.Objects.MidtermChangeIntentMutationOutput,
      "MidtermChangePetIdActivationDate": OctopusGraphQL.Objects.MidtermChangePetIdActivationDate,
      "MidtermChangePriceDetailItem": OctopusGraphQL.Objects.MidtermChangePriceDetailItem,
      "Money": OctopusGraphQL.Objects.Money,
      "MoveAddonQuote": OctopusGraphQL.Objects.MoveAddonQuote,
      "MoveAddress": OctopusGraphQL.Objects.MoveAddress,
      "MoveExtraBuildingTypeV2": OctopusGraphQL.Objects.MoveExtraBuildingTypeV2,
      "MoveHomeQuote": OctopusGraphQL.Objects.MoveHomeQuote,
      "MoveIntent": OctopusGraphQL.Objects.MoveIntent,
      "MoveIntentCost": OctopusGraphQL.Objects.MoveIntentCost,
      "MoveIntentMutationOutput": OctopusGraphQL.Objects.MoveIntentMutationOutput,
      "MoveIntentQuoteCost": OctopusGraphQL.Objects.MoveIntentQuoteCost,
      "MoveIntentTotalCost": OctopusGraphQL.Objects.MoveIntentTotalCost,
      "MoveMtaQuote": OctopusGraphQL.Objects.MoveMtaQuote,
      "MoveQuoteDisplayItem": OctopusGraphQL.Objects.MoveQuoteDisplayItem,
      "Mutation": OctopusGraphQL.Objects.Mutation,
      "PartnerClaim": OctopusGraphQL.Objects.PartnerClaim,
      "PartnerData": OctopusGraphQL.Objects.PartnerData,
      "PaymentMethodBankAccountDetails": OctopusGraphQL.Objects.PaymentMethodBankAccountDetails,
      "PaymentMethodInvoiceDetails": OctopusGraphQL.Objects.PaymentMethodInvoiceDetails,
      "PaymentMethodSetupOutput": OctopusGraphQL.Objects.PaymentMethodSetupOutput,
      "PaymentMethodSetupStatusOutput": OctopusGraphQL.Objects.PaymentMethodSetupStatusOutput,
      "PaymentMethodSwishDetails": OctopusGraphQL.Objects.PaymentMethodSwishDetails,
      "PendingContract": OctopusGraphQL.Objects.PendingContract,
      "Peril": OctopusGraphQL.Objects.Peril,
      "PersonalInformation": OctopusGraphQL.Objects.PersonalInformation,
      "ProductVariant": OctopusGraphQL.Objects.ProductVariant,
      "ProductVariantComparison": OctopusGraphQL.Objects.ProductVariantComparison,
      "ProductVariantComparisonCell": OctopusGraphQL.Objects.ProductVariantComparisonCell,
      "ProductVariantComparisonRow": OctopusGraphQL.Objects.ProductVariantComparisonRow,
      "Query": OctopusGraphQL.Objects.Query,
      "RecommendedAddonCrossSell": OctopusGraphQL.Objects.RecommendedAddonCrossSell,
      "RecommendedCrossSell": OctopusGraphQL.Objects.RecommendedCrossSell,
      "RecommendedCrossSellBackgroundPillowImages": OctopusGraphQL.Objects.RecommendedCrossSellBackgroundPillowImages,
      "SasPartnerData": OctopusGraphQL.Objects.SasPartnerData,
      "ShopSession": OctopusGraphQL.Objects.ShopSession,
      "ShopSessionDisplay": OctopusGraphQL.Objects.ShopSessionDisplay,
      "StoryblokImageAsset": OctopusGraphQL.Objects.StoryblokImageAsset,
      "TerminationFlowActionDeleteInsurance": OctopusGraphQL.Objects.TerminationFlowActionDeleteInsurance,
      "TerminationFlowActionTerminateWithDate": OctopusGraphQL.Objects.TerminationFlowActionTerminateWithDate,
      "TerminationFlowContractMutationOutput": OctopusGraphQL.Objects.TerminationFlowContractMutationOutput,
      "TerminationFlowExtraCoverageItem": OctopusGraphQL.Objects.TerminationFlowExtraCoverageItem,
      "TerminationFlowNotification": OctopusGraphQL.Objects.TerminationFlowNotification,
      "TerminationFlowSurvey": OctopusGraphQL.Objects.TerminationFlowSurvey,
      "TerminationFlowSurveyOption": OctopusGraphQL.Objects.TerminationFlowSurveyOption,
      "TerminationFlowSurveyOptionRedirection": OctopusGraphQL.Objects.TerminationFlowSurveyOptionRedirection,
      "TerminationFlowSurveyOptionRedirectionImage": OctopusGraphQL.Objects.TerminationFlowSurveyOptionRedirectionImage,
      "TerminationFlowSurveyOptionSuggestion": OctopusGraphQL.Objects.TerminationFlowSurveyOptionSuggestion,
      "TotalCost": OctopusGraphQL.Objects.TotalCost,
      "TravelCertificate": OctopusGraphQL.Objects.TravelCertificate,
      "TravelCertificateContractSpecification": OctopusGraphQL.Objects.TravelCertificateContractSpecification,
      "TravelCertificateSpecification": OctopusGraphQL.Objects.TravelCertificateSpecification,
      "UserError": OctopusGraphQL.Objects.UserError
    ]

    @_spi(Execution) public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      objectTypeMap[typename]
    }
  }

  nonisolated enum Objects {}
  nonisolated enum Interfaces {}
  nonisolated enum Unions {}

}