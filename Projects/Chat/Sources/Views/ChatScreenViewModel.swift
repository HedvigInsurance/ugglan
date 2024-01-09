import SwiftUI

class ChatScreenViewModel: ObservableObject {
    @Published var messages: [Message] = []
}
