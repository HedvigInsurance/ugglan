import Foundation

@MainActor var disableSubmitChatClaimAnimations = false

@MainActor
enum ClaimChatConstants {
    /// Timing constants for animations and delays
    @MainActor
    enum Timing {
        /// Standard animation duration for text reveal and UI transitions (1.0 second)
        static var standardAnimation: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 1.0 }

        /// Short delay for UI state transitions and accessibility focus (0.5 seconds)
        static var shortDelay: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.5 }

        /// Brief delay for scroll calculations and layout updates (0.1 seconds)
        static var layoutUpdate: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.1 }

        /// Delay before showing options in select views (0.2 seconds)
        static var optionReveal: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.2 }

        /// Delay between picking an option and auto submitting it in select views (0.5 seconds)
        static var autoSubmitDelay: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.25 }

        /// Delay between pressing skip and performing the skip request (0.25 seconds)
        static var skipDelay: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.25 }

        /// Quick delay for regret operation scroll positioning (0.4 seconds)
        static var regretScrollDelay: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.4 }

        /// Minimal delay for UI coordination between async operations (0.05 seconds)
        static var minimalDelay: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.05 }

        /// Haptic feedback delay (0.15 seconds)
        static var hapticDelay: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.15 }

        /// Countdown step duration between numbers (1.0 second)
        static var countdownStep: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 1.0 }

        /// Delay between scrolling the question into view and revealing the text/voice input card (0.6 seconds)
        static var inputCardReveal: TimeInterval { disableSubmitChatClaimAnimations ? 0 : 0.6 }
    }
}
