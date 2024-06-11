import SwiftUI

struct ConversationsView: View {
    @StateObject var vm = ConversationsViewModel()
    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
    }
}

class ConversationsViewModel: ObservableObject {
    let service = ConversationsService()
}

#Preview{
    ConversationsView()
}
