import Testing

@Suite(.serialized)
struct OnboardingDependencySuite {
    // Serialized because these tests set the process-wide FeatureFlags.shared.data.
}
