import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @StateObject var viewModel = SubmitClaimChatViewModel()

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                ForEach(viewModel.messages, id: \.self) { message in
                    HStack {
                        spacing(message.sender == .member)
                        VStack(alignment: .leading, spacing: 0) {
                            SubmitClaimChatMesageView(message: message, viewModel: viewModel)
                            senderStamp(sender: message.sender)
                        }
                        spacing(message.sender == .hedvig)
                    }
                }
            }
            .padding(.horizontal, .padding16)
        }
        .hFormAttachToBottom {
            SubmitClaimChatInputView()
        }
        .detent(
            item: $viewModel.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) { datePickerVm in
            DatePickerView(vm: datePickerVm)
                .embededInNavigation(options: .largeNavigationBar, tracking: self)
        }
    }

    @ViewBuilder
    func spacing(_ addSpacing: Bool) -> some View {
        if addSpacing {
            Spacer()
        }
    }

    @ViewBuilder
    func senderStamp(sender: SubmitClaimChatMesage.SubmitClaimChatMesageSender) -> some View {
        if sender == .hedvig {
            HStack {
                Circle()
                    .frame(width: 16)
                    .foregroundColor(hSignalColor.Green.element)
                hText("Hedvig AI Assistent", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .padding(.leading, .padding16)
        }
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String {
        ""
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return SubmitClaimChatScreen()
}

class SubmitClaimChatViewModel: ObservableObject {
    @Published var isDatePickerPresented: DatePickerViewModel?
    @Published var date: Date = .init()
    var hasSelectedDate: Bool = false
    let messages: [SubmitClaimChatMesage]

    init() {
        messages = [
            .init(
                sender: .member,
                type: .text(message: "My computer broke")
            ),
            .init(
                sender: .hedvig,
                type: .text(message: "Ok I see. Please tell us when it happened")
            ),
            .init(
                sender: .member,
                type: .date
            ),
        ]
    }
}

struct SubmitClaimChatMesage: Hashable, Equatable {
    let sender: SubmitClaimChatMesageSender
    let type: SubmitClaimChatMesageType

    enum SubmitClaimChatMesageSender {
        case hedvig
        case member
    }

    enum SubmitClaimChatMesageType: Equatable, Hashable {
        case text(message: String)
        case audio
        case date
    }
}
