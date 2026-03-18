import Foundation

@MainActor
public var disableSubmitChatClaimAnimations = false

@MainActor
enum ClaimChatConstants {
    /// Timing constants for animations and delays
    @MainActor
    enum Timing {
        /// Standard animation duration for text reveal and UI transitions (1.0 second)
        static var standardAnimation: Float { disableSubmitChatClaimAnimations ? 0 : 1.0 }

        /// Short delay for UI state transitions and accessibility focus (0.5 seconds)
        static var shortDelay: Float { disableSubmitChatClaimAnimations ? 0 : 0.5 }

        /// Brief delay for scroll calculations and layout updates (0.1 seconds)
        static var layoutUpdate: Float { disableSubmitChatClaimAnimations ? 0 : 0.1 }

        /// Delay before showing options in select views (0.2 seconds)
        static var optionReveal: Float { disableSubmitChatClaimAnimations ? 0 : 0.2 }

        /// Quick delay for regret operation scroll positioning (0.4 seconds)
        static var regretScrollDelay: Float { disableSubmitChatClaimAnimations ? 0 : 0.4 }

        /// Minimal delay for UI coordination between async operations (0.05 seconds)
        static var minimalDelay: Float { disableSubmitChatClaimAnimations ? 0 : 0.05 }

        /// Haptic feedback delay (0.15 seconds)
        static var hapticDelay: Float { disableSubmitChatClaimAnimations ? 0 : 0.15 }

        /// Countdown step duration between numbers (1.0 second)
        static var countdownStep: Float { disableSubmitChatClaimAnimations ? 0 : 1.0 }
    }
}
