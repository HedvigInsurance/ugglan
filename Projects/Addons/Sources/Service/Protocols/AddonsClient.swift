public protocol AddonsClient {
    func getAddons() async throws -> [AddonModel]
}
