import Testing

@Suite(.serialized)
struct OnboardingDependencySuite {
    // Serialized because these tests set the container-wide FeatureFlagsStore data.
}
