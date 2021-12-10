import Foundation
import SwiftUI
import hCore

private struct DataCollectionSessionID: EnvironmentKey {
    static let defaultValue: UUID? = nil
}

extension EnvironmentValues {
    var dataCollectionSessionID: UUID? {
        get { self[DataCollectionSessionID.self] }
        set { self[DataCollectionSessionID.self] = newValue }
    }
}

struct ReadDataCollectionSession<Content: View>: View {
    @Environment(\.dataCollectionSessionID) var sessionID

    var content: (_ session: DataCollectionSession) -> Content

    init(
        @ViewBuilder _ content: @escaping (_ session: DataCollectionSession) -> Content
    ) {
        self.content = content
    }

    var body: some View {
        PresentableStoreLens(DataCollectionStore.self, getter: { state in state.sessionFor(sessionID) }) { session in
            if let session = session {
                content(session)
            }
        }
    }
}
