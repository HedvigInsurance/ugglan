import Foundation

public enum OnboardingPresentationState {
    private static let hasBeenPresentedKey = "onboarding_has_been_presented"

    public static var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasBeenPresentedKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasBeenPresentedKey) }
    }
}
