import SwiftUI

struct ChatScreen: View {

    @StateObject var vm: ChatScreenViewModel

    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
    }
}

#Preview{
    ChatScreen(vm: .init())
}
