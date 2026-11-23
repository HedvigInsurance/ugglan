import AVFoundation
import Combine
import ElevenLabs
import Foundation
import os

/// Startup timings, readable with `log stream --predicate 'subsystem == "com.hedvig.voiceclaim"'`.
private let startupLog = Logger(subsystem: "com.hedvig.voiceclaim", category: "startup")

enum VoiceCallStatus: Equatable {
    case idle
    case connecting
    case listening
    case thinking
    case speaking
    case ended
    case failed(String)
}

/// How loud each side of the call is right now, 0...1.
struct VoiceAudioLevels: Sendable {
    var agent: Double
    var member: Double
}

struct VoiceAgentStartConfig {
    let agentId: String
    let prompt: String
    let firstMessage: String
    /// ElevenLabs language code, "sv" or "en".
    let languageCode: String
    let dynamicVariables: [String: String]
}

/// The voice call itself: speech in and out, turn-taking and the conversation LLM, hosted by ElevenLabs.
/// A protocol so `VoiceClaimViewModel` can be tested without a network or microphone.
@MainActor
protocol VoiceAgentSession: AnyObject {
    var onStatusChange: ((VoiceCallStatus) -> Void)? { get set }
    var onMuteChange: ((Bool) -> Void)? { get set }
    /// The member's words, one final transcript per turn.
    var onMemberTranscript: ((String) -> Void)? { get set }
    /// What the agent said, one response at a time.
    var onAgentText: ((String) -> Void)? { get set }
    /// Answers every client tool call: tool name and parameters in, the JSON result out.
    var toolHandler: (@MainActor (String, [String: Any]) async -> String)? { get set }
    /// The agent's and the member's audio levels right now. Read every frame by the orb.
    var audioLevels: @Sendable () -> VoiceAudioLevels { get }

    func start(_ config: VoiceAgentStartConfig) async throws
    func setMuted(_ muted: Bool) async
    /// A message from the app (not the member) that the agent responds to, e.g. "[APP] photos uploaded".
    func sendAppMessage(_ text: String) async
    func end() async
}

/// `VoiceAgentSession` on the ElevenLabs Agents SDK (WebRTC via LiveKit), with a public agent ID.
@MainActor
final class ElevenLabsVoiceAgentSession: VoiceAgentSession {
    var onStatusChange: ((VoiceCallStatus) -> Void)?
    var onMuteChange: ((Bool) -> Void)?
    var onMemberTranscript: ((String) -> Void)?
    var onAgentText: ((String) -> Void)?
    var toolHandler: (@MainActor (String, [String: Any]) async -> String)?

    private let client = ConversationClient()
    private let agentTap = AudioLevelTap()
    private let micTap = AudioLevelTap()
    private var cancellables = Set<AnyCancellable>()
    private var startedAt: Date?

    var audioLevels: @Sendable () -> VoiceAudioLevels {
        { [agentTap, micTap] in VoiceAudioLevels(agent: agentTap.level, member: micTap.level) }
    }

    init() {
        client.$state
            .combineLatest(client.$agentState)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state, agentState in
                guard let self else { return }
                if case let .connecting(stage) = state, let startedAt = self.startedAt {
                    let elapsed = String(format: "%.2f", Date().timeIntervalSince(startedAt))
                    startupLog.info(
                        "stage \(String(describing: stage), privacy: .public) at \(elapsed, privacy: .public)s"
                    )
                }
                self.onStatusChange?(Self.status(state, agentState))
            }
            .store(in: &cancellables)
        client.$isMicMuted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] muted in self?.onMuteChange?(muted) }
            .store(in: &cancellables)
        client.addAgentAudioObserver(agentTap)
        client.addMicAudioObserver(micTap)
    }

    func start(_ config: VoiceAgentStartConfig) async throws {
        var callbacks = ConversationCallbacks()
        callbacks.onUserTranscript = { [weak self] text, _ in
            Task { @MainActor in self?.onMemberTranscript?(text) }
        }
        callbacks.onAgentResponse = { [weak self] text, _ in
            Task { @MainActor in self?.onAgentText?(text) }
        }
        // Every tool goes through one handler, so the tool list lives in VoiceClaimToolbox, not here.
        callbacks.onUnhandledClientToolCall = { [weak self] call in
            guard let handler = self?.toolHandler else {
                throw ClientToolError("The app isn't ready for tool calls yet.")
            }
            let parameters = (try? call.getParameters()) ?? [:]
            return .result(await handler(call.toolName, parameters))
        }
        client.callbacks = callbacks

        let conversationConfig = ConversationConfig(
            agentOverrides: AgentOverrides(
                prompt: config.prompt,
                firstMessage: config.firstMessage,
                language: Language(rawValue: config.languageCode)
            ),
            dynamicVariables: config.dynamicVariables.mapValues { .string($0) },
            // WebRTC's voice processing on: echo cancellation, noise suppression and gain control, so background
            // noise and Hedvig's own voice through the speaker don't reach the agent as speech. It's process-wide,
            // so say it explicitly rather than relying on whatever an earlier call left.
            audioConfiguration: AudioPipelineConfiguration(
                voiceProcessingBypassed: false,
                voiceProcessingAGCEnabled: true
            )
        )
        startedAt = Date()
        let result = try await client.startVoiceConversation(
            .publicAgent(id: config.agentId),
            config: conversationConfig
        )
        startupLog.info("connected: \(String(describing: result.metrics), privacy: .public)")
    }

    func setMuted(_ muted: Bool) async {
        try? await client.setMicMuted(muted)
    }

    func sendAppMessage(_ text: String) async {
        try? await client.sendMessage(text)
    }

    func end() async {
        await client.endConversation()
        client.removeAgentAudioObserver(agentTap)
        client.removeMicAudioObserver(micTap)
    }

    private static func status(_ state: ConversationState, _ agentState: AgentState) -> VoiceCallStatus {
        switch state {
        case .idle: return .idle
        case .connecting: return .connecting
        case .ended: return .ended
        case let .error(error): return .failed(String(describing: error))
        case .connected:
            switch agentState {
            case .listening: return .listening
            case .thinking: return .thinking
            case .speaking: return .speaking
            }
        }
    }
}

/// Loudness of a PCM stream, for the orb. `didReceive` runs on the audio thread, so it only stores a number.
final class AudioLevelTap: ConversationAudioObserver {
    /// The last level and when it was measured; a stream that stops sending (the agent done talking) reads as silent.
    private let storage = OSAllocatedUnfairLock(initialState: (level: 0.0, at: Date.distantPast))

    var level: Double {
        let (level, at) = storage.withLock { ($0.level, $0.at) }
        return Date().timeIntervalSince(at) < 0.2 ? level : 0
    }

    func didReceive(_ buffer: AVAudioPCMBuffer) {
        let frames = Int(buffer.frameLength)
        guard frames > 0 else { return }
        var sumOfSquares: Float = 0
        if let samples = buffer.floatChannelData?[0] {
            for index in 0..<frames { sumOfSquares += samples[index] * samples[index] }
        } else if let samples = buffer.int16ChannelData?[0] {
            for index in 0..<frames {
                let sample = Float(samples[index]) / Float(Int16.max)
                sumOfSquares += sample * sample
            }
        } else {
            return
        }
        let rms = sqrt(sumOfSquares / Float(frames))
        // -50 dB and quieter is silence, 0 dB is full.
        let decibels = 20 * log10(max(rms, 0.000_01))
        let level = Double(min(max((decibels + 50) / 50, 0), 1))
        storage.withLock { $0 = (level, Date()) }
    }
}
