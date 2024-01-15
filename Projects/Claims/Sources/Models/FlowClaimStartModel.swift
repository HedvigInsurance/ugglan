public struct FlowClaimStartModel: FlowClaimStepModel {
    public var flowClaimFetchAllSupportedSteps: [String] {
        let supportedSteps = [
            "FlowClaimAudioRecordingStep",
            "FlowClaimContractSelectStep",
            "FlowClaimConfirmEmergencyStep",
            "FlowClaimContractSelectStep",
            "FlowClaimDateOfOccurrencePlusLocationStep",
            "FlowClaimDateOfOccurrenceStep",
            "FlowClaimDeflectEmergencyStep",
            "FlowClaimDeflectGlassDamageStep",
            "FlowClaimDeflectPestsStep",
            "FlowClaimFailedStep",
            "FlowClaimFileUploadStep",
            "FlowClaimLocationStep",
            "FlowClaimPhoneNumberStep",
            "FlowClaimSingleItemCheckoutStep",
            "FlowClaimSingleItemStep",
            "FlowClaimSuccessStep",
            "FlowClaimSummaryStep",
        ]
        return supportedSteps
    }
}
