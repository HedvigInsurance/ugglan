import SwiftSyntaxMacrosGenericTestSupport
import Testing

// Macro assertions report via XCTFail, which Swift Testing does not see; this records them as issues.
func recordMacroFailure(_ failure: TestFailureSpec) {
    Issue.record(
        Comment(rawValue: failure.message),
        sourceLocation: SourceLocation(
            fileID: failure.location.fileID,
            filePath: failure.location.filePath,
            line: failure.location.line,
            column: failure.location.column
        )
    )
}
