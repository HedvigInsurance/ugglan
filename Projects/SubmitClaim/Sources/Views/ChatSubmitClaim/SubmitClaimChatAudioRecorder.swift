@preconcurrency import Apollo
import Environment
import OSLog
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatAudioRecorder: View {
    @ObservedObject var viewModel: SubmitClaimChatViewModel
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder

    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @AccessibilityFocusState private var saveAndContinueFocused: Bool

    @StateObject var audioRecordingVm = SubmitClaimAudioRecordingScreenModel()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let onSubmit: (_ url: URL) -> Void
    let uploadURI: String

    public init(
        viewModel: SubmitClaimChatViewModel,
        uploadURI: String
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        let url = URL(string: uploadURI)
        self._audioPlayer = ObservedObject(wrappedValue: AudioPlayer(url: url))
        self.uploadURI = url?.absoluteString ?? ""

        let tmpDir = FileManager.default.temporaryDirectory
        let path =
            tmpDir
            .appendingPathComponent("claims")
            .appendingPathComponent("audio-file-recording")
            .appendingPathExtension(AudioRecorder.audioFileExtension)
        self._audioRecorder = ObservedObject(wrappedValue: AudioRecorder(filePath: path))

        func myFunc(url: URL) {
            viewModel.audioRecordingUrl = url
        }
        self.onSubmit = myFunc
    }

    public var body: some View {
        hSection {
            ZStack(alignment: .bottom) {
                Group {
                    if let url = audioRecorder.recording?.url {
                        playRecordingButton(url: url)
                    } else if let url = viewModel.audioRecordingUrl {
                        playRecordingButton(url: url)
                    } else {
                        recordNewButton
                    }
                }
            }
            .environmentObject(audioRecorder)
        }
        .sectionContainerStyle(.transparent)
    }

    private func playRecordingButton(url: URL) -> some View {
        VStack(spacing: .padding12) {
            TrackPlayerView(audioPlayer: audioPlayer, withoutBackground: true)
                .onAppear {
                    minutes = 0; seconds = 0
                }

            if viewModel.audioRecordingUrl == nil {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.saveAndContinueButtonLabel),
                    {
                        onSubmit(url)
                        Task {
                            do {
                                // 1) Build final upload URL
                                let uploadURL = resolveUploadURL(uploadURI)
                                logger.info("Resolved upload URL: \(uploadURL.absoluteString, privacy: .public)")

                                // 2) Retrieve token (optional; headers() adds it automatically)
                                let tokenObj = try await ApolloClient.retreiveToken()
                                let bearerToken = tokenObj?.accessToken

                                // 3) Upload file (multipart, tries multiple field names)
                                let reference = try await uploadAudio(
                                    uploadURL: uploadURL,
                                    fileURL: url,
                                    bearerToken: bearerToken
                                )

                                // 4) Send UUID reference to backend
                                await viewModel.sendAudioReferenceToBackend(
                                    translatedText: "",
                                    url: reference.uuidString,
                                    freeText: nil
                                )

                                // 5) Clean up local temp
                                try? FileManager.default.removeItem(at: url)
                            } catch {
                                logger.error("Audio upload/send failed: \(String(describing: error))")
                            }
                        }
                    }
                )
                .disabled(audioRecordingVm.viewState == .loading)
                .hButtonIsLoading(audioRecordingVm.viewState == .loading)
                .accessibilityFocused($saveAndContinueFocused)
                .accessibilityLabel(Text(L10n.saveAndContinueButtonLabel))

                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.embarkRecordAgain),
                    {
                        withAnimation(.spring()) { audioRecorder.restart() }
                    }
                )
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear { audioPlayer.url = url }
    }

    private var recordNewButton: some View {
        VStack(spacing: .padding8) {
            RecordButton(isRecording: audioRecorder.isRecording) {
                withAnimation(.spring()) { audioRecorder.toggleRecording() }
            }
            .frame(height: audioRecorder.isRecording ? 144 : 72)
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300)))

            if !audioRecorder.isRecording {
                hText(L10n.claimsStartRecordingLabel, style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)
            } else {
                hText(String(format: "%02d:%02d", minutes, seconds), style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .onReceive(timer) { _ in
                        if (seconds % 59) == 0, seconds != 0 { minutes += 1; seconds = 0 } else { seconds += 1 }
                    }
            }
        }
        .onChange(of: audioRecorder.isRecording) { isRecording in
            if !isRecording {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIAccessibility.post(notification: .announcement, argument: " ")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        saveAndContinueFocused = true
                    }
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityHint(audioRecorder.isRecording ? L10n.embarkStopRecording : L10n.claimsStartRecordingLabel)
    }
}

// MARK: - URL helpers

private func resolveBase() -> URL {
    URL(string: "https://gateway.test.hedvig.com")!
}

private func resolveUploadURL(_ pathOrUrl: String) -> URL {
    // If backend already gave you an absolute URL, just use it:
    if let absolute = URL(string: pathOrUrl), absolute.scheme != nil {
        return absolute
    }
    // Otherwise join with the gateway base, ensuring exactly one slash
    var base = resolveBase()
    let trimmed = pathOrUrl.hasPrefix("/") ? String(pathOrUrl.dropFirst()) : pathOrUrl
    base.appendPathComponent(trimmed)
    return base
}

// MARK: - Logger + decoding

private let logger = Logger(subsystem: "SubmitClaim", category: "Upload")

private struct FlexibleReference: Decodable {
    let value: String
    private struct One: Decodable { let reference: String }
    private struct OneUUID: Decodable { let reference: UUID }
    private struct ManyFiles: Decodable { struct F: Decodable { let reference: String }; let files: [F] }
    private struct ManyRefs: Decodable { let references: [String] }

    init(from decoder: Decoder) throws {
        if let s = try? One(from: decoder) { self.value = s.reference; return }
        if let u = try? OneUUID(from: decoder) { self.value = u.reference.uuidString; return }
        if let m = try? ManyFiles(from: decoder), let first = m.files.first?.reference { self.value = first; return }
        if let r = try? ManyRefs(from: decoder), let first = r.references.first { self.value = first; return }
        if let plain = try? String(from: decoder) { self.value = plain; return }
        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Could not find reference"))
    }
}

private func extractUUIDLike(from string: String) -> String? {
    let pattern = #"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
    let range = NSRange(string.startIndex..<string.endIndex, in: string)
    guard let match = regex.firstMatch(in: string, options: [], range: range),
        let r = Range(match.range, in: string)
    else { return nil }
    return String(string[r])
}

// MARK: - Upload logic
private struct UploadHTTPError: LocalizedError {
    let status: Int
    let body: String
    let method: String
    let fieldName: String?
    var errorDescription: String? {
        "Upload failed (\(status)) via \(method)\(fieldName.map { " field=\($0)" } ?? ""). Body: \(body)"
    }
}

private func decodeReference(data: Data, http: HTTPURLResponse) -> UUID? {
    // try JSON shapes
    if let ref = try? JSONDecoder().decode(FlexibleReference.self, from: data).value,
        let uuid = UUID(uuidString: ref)
    {
        return uuid
    }
    // try Location header
    if let loc = http.value(forHTTPHeaderField: "Location"),
        let uuidStr = extractUUIDLike(from: loc),
        let uuid = UUID(uuidString: uuidStr)
    {
        return uuid
    }
    // try uuid in raw body
    if let bodyStr = String(data: data, encoding: .utf8),
        let uuidStr = extractUUIDLike(from: bodyStr),
        let uuid = UUID(uuidString: uuidStr)
    {
        return uuid
    }
    return nil
}

private func uploadAudio(
    uploadURL: URL,
    fileURL: URL,
    bearerToken: String?,
    fieldNameCandidates: [String] = ["file", "files", "files[]"],
    mime: String = "audio/m4a",
    requestTimeout: TimeInterval = 20,
    resourceTimeout: TimeInterval = 60
) async throws -> UUID {
    let fileData = try Data(contentsOf: fileURL)
    logger.info(
        "Uploading audio. size=\(fileData.count, privacy: .public) bytes name=\(fileURL.lastPathComponent, privacy: .public)"
    )

    // Common headers (adds Authorization if token exists)
    let hedvigHeaders = await ApolloClient.headers()

    func configuredSession() -> URLSession {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = requestTimeout
        cfg.timeoutIntervalForResource = resourceTimeout
        cfg.waitsForConnectivity = false
        return URLSession(configuration: cfg)
    }

    // ---------- Attempt 1: POST multipart (try multiple field names)
    for field in fieldNameCandidates {
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: uploadURL, timeoutInterval: requestTimeout)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        hedvigHeaders.forEach { k, v in req.setValue(v, forHTTPHeaderField: k) }
        if let bearerToken, !bearerToken.isEmpty {
            req.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        // Build multipart
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(fileURL.lastPathComponent)\"\r\n")
        body.append("Content-Type: \(mime)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n")
        req.httpBody = body

        logger.info(
            """
            ▶️ POST \(uploadURL.absoluteString, privacy: .public)
               Field: \(field, privacy: .public)
               Headers: \(String(describing: req.allHTTPHeaderFields), privacy: .public)
               Body: \(body.count, privacy: .public) bytes
            """
        )

        let (respData, resp) = try await configuredSession().data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        let bodyStr = String(data: respData, encoding: .utf8) ?? "<binary>"
        logger.info("⬅️ POST status=\(http.statusCode, privacy: .public) Body: \(bodyStr, privacy: .public)")

        if (200..<300).contains(http.statusCode) {
            if let uuid = decodeReference(data: respData, http: http) { return uuid }
            throw UploadHTTPError(
                status: http.statusCode,
                body: "Missing/invalid reference in 2xx response",
                method: "POST",
                fieldName: field
            )
        }

        // If last field candidate, throw a rich error
        if field == fieldNameCandidates.last {
            throw UploadHTTPError(status: http.statusCode, body: bodyStr, method: "POST", fieldName: field)
        }

        // Otherwise try next field name
    }

    // ---------- Attempt 2: PUT raw (for presigned/raw endpoints)
    do {
        var req = URLRequest(url: uploadURL, timeoutInterval: requestTimeout)
        req.httpMethod = "PUT"
        req.httpBody = fileData
        req.setValue(mime, forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        hedvigHeaders.forEach { k, v in req.setValue(v, forHTTPHeaderField: k) }
        if let bearerToken, !bearerToken.isEmpty {
            req.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        logger.info(
            """
            ▶️ PUT \(uploadURL.absoluteString, privacy: .public)
               Headers: \(String(describing: req.allHTTPHeaderFields), privacy: .public)
               Body: \(fileData.count, privacy: .public) bytes
            """
        )

        let (respData, resp) = try await configuredSession().data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        let bodyStr = String(data: respData, encoding: .utf8) ?? "<binary>"
        logger.info("⬅️ PUT status=\(http.statusCode, privacy: .public) Body: \(bodyStr, privacy: .public)")

        guard (200..<300).contains(http.statusCode) else {
            throw UploadHTTPError(status: http.statusCode, body: bodyStr, method: "PUT", fieldName: nil)
        }

        if let uuid = decodeReference(data: respData, http: http) { return uuid }
        throw UploadHTTPError(
            status: http.statusCode,
            body: "PUT succeeded but no reference returned",
            method: "PUT",
            fieldName: nil
        )
    } catch {
        // If PUT path also failed, surface the last error (already rich)
        throw error
    }
}

extension Data {
    fileprivate mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
