import Foundation

enum ClaimChatConstants {
    /// Timing constants for animations and delays
    enum Timing {
        /// Standard animation duration for text reveal and UI transitions (1.0 second)
        static let standardAnimation: Float = 1.0

        /// Short delay for UI state transitions and accessibility focus (0.5 seconds)
        static let shortDelay: Float = 0.5

        /// Brief delay for scroll calculations and layout updates (0.1 seconds)
        static let layoutUpdate: Float = 0.1

        /// Delay before showing options in select views (0.2 seconds)
        static let optionReveal: Float = 0.2

        /// Quick delay for regret operation scroll positioning (0.4 seconds)
        static let regretScrollDelay: Float = 0.4

        /// Minimal delay for UI coordination between async operations (0.05 seconds)
        static let minimalDelay: Float = 0.05

        /// Haptic feedback delay (0.15 seconds)
        static let hapticDelay: Float = 0.15
    }
}
