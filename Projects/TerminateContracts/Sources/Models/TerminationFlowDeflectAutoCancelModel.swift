public struct TerminationFlowDeflectAutoCancelModel: FlowStepModel {
    let message: String
    let title: String
    let extraMessage: String?

    public init(title: String, message: String, extraMessage: String?) {
        self.title = title
        self.message = message
        self.extraMessage = extraMessage
    }
}
