struct AnalyticsClientDemo: AnalyticsClient {
    func fetchUserId() -> String { "" }
    func setWith(userId _: String) {}
    func setDeviceInfo(model: MemberLogDeviceModel) async {
        //no implemenation since it is a demo
    }
}
