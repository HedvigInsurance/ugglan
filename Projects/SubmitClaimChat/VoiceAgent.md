# Voice claim agent (ElevenLabs) — setup

The voice claim POC (`Sources/Voice/`) talks to one **public** ElevenLabs agent. The app sends the system prompt,
first message and language on every call (`VoiceAgentPrompt.swift`), so the dashboard only holds what the app can't
send: the tools, the voice and the security settings.

**The POC agent exists:** "Hedvig voice claim (POC)", `agent_0501m7w3ataqefxb1x22vvbaxe8k`, in Hedvig's ElevenLabs
workspace, wired into staging in `Environment.elevenLabsClaimAgentId`. It is set up exactly as the sections below
describe (LLM, voices, TTS model, English language preset, 15-minute call cap), plus a 50-calls-a-day /
3-concurrent limit. Recreate it from them.

## 1. Create the agent

ElevenLabs dashboard → Agents → New agent (blank).

| Setting | Value |
|---|---|
| Voice | Swedish: `QLfvbukvQvrPOx9HXQ3x` (the voice used in hedvig-claims-poc). English: `oVXQ3H21hRI9OtM4YH5K` (Freya, conversational, female, English with a Swedish accent; added to My Voices), set in the `en` language preset with clone strength 0.5 (trying: on v4 she drifted into a British accent, and clone strength keeps a professional voice closer to its recordings); the Swedish voice drifted into other accents in English. (Belle, `cNYrMw9glwJZXR8RwbuR`, was the English voice in the old workspace; it isn't in Hedvig's, so English calls fell back to the default male voice.) A Voice Library voice must be added to the workspace first, or calls fall back to the default male voice |
| TTS model | `eleven_v4_turbo` (Eleven v4 Turbo, the real-time v4 for agents; plain `eleven_v4` is for produced audio), stability 0.65 (0.45 was more expressive but Freya drifted into a British accent), speed 0.95 (v4 has no speed slider, so likely ignored). Before: `eleven_v3_conversational`, expressive mode, same settings |
| Languages | Swedish (default) + English |
| LLM | `gpt-6-luna`, reasoning effort low, fast tier (trying; at none it started in 0.5–1.4 s but followed tone less closely); backup after 3 s (`cascade_timeout_seconds`). `gemini-4-hydrogen` at low averaged 1.5 s to its first token and ran past 3 s on about 1 in 5 turns. `claude-haiku-5-5` at none started replies in 0.5–1 s. `gemini-3.8-flash` at default effort answered 1–5 s late; at low effort on the fast tier it worked |
| System prompt / first message | Anything; the app overrides both |
| Turn eagerness | Patient |
| Speech to text | Scribe v3 Live (`asr.provider: scribe_v3_live`), trying since 2026-11-20: ElevenLabs reports about 40% fewer errors than Scribe v2 Realtime (`scribe_realtime`, the previous setting). Watch Swedish accuracy and turn latency; switch back if either gets worse |
| Background voice detection | **On** (Advanced → Automatic Speech Recognition → *Filter background speech*; `vad.background_voice_detection` in the API). Filters out voices that aren't the member's (TV, people nearby); the app's WebRTC noise suppression only removes steady noise, not other speech. Trying since 2026-11-20 |
| Interruption ignore terms | Default terms for `sv` + `en` merged in, plus `mm`, `mhm`, `mmm`, `ja`, `jaa`, `jo`, `okej`, `ok`, `aha`, `precis`, `japp`, `yes`, `yeah`, `uh-huh`, `right`, so backchannels and short background sounds don't cut the agent off |
| Noisy environment detection | **Off: not available on our ElevenLabs workspace** (turning it on returns 403 `noisy_environment_detection_not_available`). The messages are ready for when it is: Swedish (default) "Förlåt, jag hör en del ljud i bakgrunden. Kan du gå någonstans där det är lite tystare?", English in the `en` language preset (`overrides.turn.noisy_environment_message`). The `en` preset map is replaced as a whole on save, so keep the English voice in it too |
| Soft timeout | **Off.** Its LLM filler stacked on the agent's own reactions, mixed in Swedish and spoke its reasoning aloud |
| Max conversation duration | 15 min |
| Data retention | POC: default. Zero retention needs the enterprise plan |
| Spend cap | Set one: the agent is public and its ID ships in the app. When the account runs out of credits, every call fails at start with "The AI agent you are trying to reach is not available" (code 3000); the app shows "call ended" |

**Security → Overrides:** turn on *System prompt*, *First message* and *Language*. Without these, starting a call
fails.

**Authentication:** off (public agent). Move to conversation tokens from claims-service before a pilot.

## 2. Client tools

Add each tool as a **client tool** with **Wait for response** on and a **response timeout of 60 s** (engine turns can
take up to 30 s). Every parameter is a string unless noted. The names must match `VoiceTool` in
`VoiceClaimToolbox.swift`.

| Tool | Parameters | Description to give the LLM |
|---|---|---|
| `note_story` | `category`, `subcategory` (triage option ids, enums), `date` (YYYY-MM-DD), `item_count` (integer), `item` (search text), all optional | Called once after the recap. The app answers the opening steps the story settles itself (triage, description, date/choice forms the engine pre-filled, the item count), runs the item search, and returns the first open step. Saves one LLM round trip per step. Pre-tool speech *Force* |
| `get_current_step` | – | Get the claim's current step from Hedvig. Call after the member's opening story, and whenever unsure. |
| `answer_select` | `step_id`, `option_id` | Answer a select step with one option id, after the member has confirmed it. |
| `answer_form` | `step_id`, `fields` (array of objects `{field_id: string, values: array of string}`) | Answer every field of a form step. Dates YYYY-MM-DD. |
| `answer_free_text` | `step_id`, `member_words` | Answer a free-text step once the member has finished talking. The app sends the member's transcript. |
| `search_field` | `step_id`, `field_id`, `query` | Search options for a field of type "search" (e.g. the item: "Samsung washing machine"). |
| `acknowledge_notice` | `step_id` | The member has heard a notice. |
| `skip_step` | `step_id` | Skip a skippable step (e.g. no photos right now). |
| `request_photos` | `step_id` | Open the photo/document picker on the phone for an upload step. |
| `show_summary` | `step_id` | Show the claim summary on screen so the member can tap submit. |
| `hand_off_to_chat` | `reason` | End the call and continue the claim in the app's chat. |

**Pre-tool speech:** *Force* on `answer_free_text` (the member has always just spoken), *Auto* on the rest, so steps the
story already answers go by silently. That one line before the tool call is the only filler; the prompt forbids a
second. Keep example phrases out of tool descriptions: the agent copies them, in their language.

**Tool call sound:** *Typing*, played *Always*, on every tool that waits for the engine's next question (all but
`request_photos`, `show_summary` and `hand_off_to_chat`, which open something on screen or end the call), so the wait
sounds like someone jotting the answer down.

Don't add the built-in *End call* system tool: the app ends the call itself after the summary or a handoff.

## 3. Point the app at it

Put the agent ID in `LocalModules/Environment/Sources/Environment/Environment.swift` →
`elevenLabsClaimAgentId` (staging first), and turn on the Unleash flag `enable_voice_claim_submission` for internal
members. With either missing, the honesty pledge shows the normal Continue button and nothing else changes.

## How a call runs

1. Pledge → **Talk it through**. The app asks for the microphone (denied → normal chat), starts a new claim intent,
   then connects the agent.
2. The agent asks what happened, when and where. It then calls `get_current_step` and answers the triage steps from
   the story, confirming out loud.
3. Each tool answers with the engine's next step as JSON (`VoiceStepPayload`), including an `instruction`. Task steps
   (the engine thinking) are polled inside the app and never reach the agent.
4. A triage answer that can't reach an agent playbook (bike, travel, other…) or a deflection makes the toolbox return
   `status: handoff`. The agent says so and calls `hand_off_to_chat`, and the chat resumes the same draft.
5. Upload and summary steps open the existing views over the orb. When the member finishes, the app tells the agent
   with an `[APP] …` message. The member taps submit; the agent says goodbye; the success screen shows.
