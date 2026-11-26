import Logger

@MainActor
final class RecordingLogger: Logging {
    struct Line {
        let level: String
        let message: String
    }

    var lines: [Line] = []

    private nonisolated func record(_ level: String, _ message: String) {
        MainActor.assumeIsolated { lines.append(Line(level: level, message: message)) }
    }

    nonisolated func debug(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("debug", message)
    }

    nonisolated func info(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("info", message)
    }

    nonisolated func notice(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("notice", message)
    }

    nonisolated func warn(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("warn", message)
    }

    nonisolated func error(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("error", message)
    }

    nonisolated func critical(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("critical", message)
    }

    nonisolated func addUserAction(
        type _: LoggingAction,
        name _: String,
        error _: Error?,
        attributes _: [AttributeKey: AttributeValue]?
    ) {}

    nonisolated func addError(error _: Error, type _: ErrorSource, attributes _: [AttributeKey: AttributeValue]?) {}
}
