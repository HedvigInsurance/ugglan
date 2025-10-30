import SwiftUI
import hCoreUI

struct SubmitClaimChatMesageView: View {
    let message: SubmitClaimChatMesage
    @ObservedObject var viewModel: SubmitClaimChatViewModel

    var body: some View {
        Group {
            switch message.type {
            case let .text(message):
                hText(message)
            case .audio:
                hText("audio")
            case .date:
                dropDownView(
                    message: viewModel.hasSelectedDate ? viewModel.date.displayDateDDMMMYYYYFormat : "Selected date"
                )
            }
        }
        .padding(.horizontal, .padding12)
        .padding(.vertical, .padding8)
        .background(backgroundColor)
        .foregroundColor(hTextColor.Opaque.primary)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
        .frame(
            maxWidth: 300,
            alignment: message.sender == .hedvig ? .leading : .trailing
        )
        .onTapGesture {
            switch message.type {
            case .text:
                break
            case .audio:
                print("Tapped audio")
            case .date:
                viewModel.isDatePickerPresented = .init(
                    continueAction: {
                        viewModel.hasSelectedDate = true
                        viewModel.isDatePickerPresented = nil
                    },
                    cancelAction: {
                        viewModel.isDatePickerPresented = nil
                    },
                    date: $viewModel.date,
                    config: .init(placeholder: "placeholder", title: "Select date")
                )
            }
        }
    }

    func dropDownView(message: String) -> some View {
        HStack(spacing: .padding4) {
            hText(message)
            hCoreUIAssets.chevronDown.view
        }
    }

    @hColorBuilder
    var backgroundColor: some hColor {
        switch message.sender {
        case .member:
            hSurfaceColor.Translucent.primary
        case .hedvig:
            hBackgroundColor.clear
        }
    }
}
