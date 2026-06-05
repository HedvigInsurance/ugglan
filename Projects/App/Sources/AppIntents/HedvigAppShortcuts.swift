import AppIntents

@available(iOS 16.0, *)
public struct HedvigAppShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FileClaimAppIntent(),
            phrases: [
                "File a claim with \(.applicationName)",
                "Start a \(.applicationName) claim",
                "Report a claim with \(.applicationName)",
                "New \(.applicationName) claim",
            ],
            shortTitle: "File Claim",
            systemImageName: "exclamationmark.bubble"
        )
    }
}
