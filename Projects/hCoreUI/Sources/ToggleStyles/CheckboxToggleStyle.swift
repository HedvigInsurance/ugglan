import Foundation
import SwiftUI

public struct ChecboxToggleStyle: ToggleStyle {
    
    public init(){}
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 15.0, *) {
            HStack {
                configuration.label
                Spacer()
                RoundedRectangle(cornerRadius: 9)
                    .fill(backgroundColor(isOn: configuration.isOn))
                    .overlay {
                        Circle()
                            .fill(hTextColorNew.negative)
                            .padding(1)
                            .offset(x: configuration.isOn ? 5 : -5)

                    }
                    .frame(width: 28, height: 18)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            configuration.isOn.toggle()
                        }
                    }
            }
        } else {
            Text("ssd")
        }
    }

    @hColorBuilder
    func backgroundColor(isOn: Bool) -> some hColor {
        if isOn {
            hSignalColorNew.greenElement
        } else {
            hFillColorNew.opaqueThree
        }
    }
}
