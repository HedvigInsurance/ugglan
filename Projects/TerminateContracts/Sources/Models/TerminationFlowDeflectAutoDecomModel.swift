public struct TerminationFlowDeflectAutoDecomModel: FlowStepModel {
    let message: String
    let title: String
    let explanations: [TerminationFlowDeflectAutoDecomExplanation]
    let info: String?
    public init(
        message: String,
        title: String,
        explanations: [TerminationFlowDeflectAutoDecomExplanation],
        info: String?
    ) {
        self.message = message
        self.title = title
        self.explanations = explanations
        self.info = info
    }

    public struct TerminationFlowDeflectAutoDecomExplanation: Codable, Sendable, Equatable, Hashable {
        let title: String?
        let text: String

        public init(
            title: String?,
            text: String
        ) {
            self.title = title
            self.text = text
        }
    }
}
