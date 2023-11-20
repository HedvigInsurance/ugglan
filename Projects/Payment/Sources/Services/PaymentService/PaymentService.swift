public protocol hPaymentService {
    func getPaymentData() async throws -> PaymentData
    func getPaymentStatusData() async throws -> PaymentStatusData
    func getPaymentDiscountsData() async throws -> PaymentDiscountsData
    func getPaymentHistoryData() async throws -> [PaymentHistoryListData]
}
