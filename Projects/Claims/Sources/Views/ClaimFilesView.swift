import SwiftUI
import hCore
import hCoreUI

struct ClaimFilesView: View {

    var body: some View {
        hText("")
    }
}

class ClaimFilesViewModel: ObservableObject {
    @Published var files: [FileWrapper] = []
}

#Preview{
    ClaimFilesView()
}
