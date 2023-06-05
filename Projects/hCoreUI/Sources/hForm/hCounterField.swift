import SwiftUI

public struct hCounterField: View {
    @Environment(\.hTextFieldError) var errorMessage
    
    private var placeholder: String
    @State private var animate = false
    @Binding var value: Int
    let minValue: Int?
    let maxValue: Int?
    @State var textToShow: String = ""
    private let textForValue: (_ value:Int) -> String?
    
    public init(
        value: Binding<Int>,
        placeholder: String? = nil,
        minValue: Int?,
        maxValue: Int?,
        textForValue: @escaping (Int) -> String?
    ) {
        
        self.placeholder = placeholder ?? ""
        self.textForValue = textForValue
        self.minValue = minValue
        self.maxValue = maxValue
        self._value = value
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    getPlaceHolderLabel
                    if !textToShow.isEmpty {
                        getTextLabel
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, textToShow.isEmpty ? 16 : 10)
            }
            
            SwiftUI.Button {
                decrease()
            } label: {
                Image(uiImage: hCoreUIAssets.minusIcon.image)
                    .foregroundColor(
                        hGrayscaleColorNew.greyScale1000.opacity(value == 0 ? 0.4 : 1)
                            
                    )
                    .frame(width: 35,height: 35)
            }
            
            SwiftUI.Button {
                increase()
            } label: {
                Image(uiImage: hCoreUIAssets.plusIcon.image)
                    .foregroundColor(hGrayscaleColorNew.greyScale1000)
                .frame(width: 35,height: 35)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            self.startAnimation()
        }
        .background(getColor())
        .animation(.easeInOut(duration: 0.4), value: animate)
        .clipShape(Squircle.default())
        .onAppear {
            self.textToShow = textForValue(value) ?? ""
        }
    }
    
    private func increase() {
        withAnimation {
            value += 1
            startAnimation()
            self.textToShow = textForValue(value) ?? ""
        }
    }
    
    private func decrease() {
        withAnimation {
            value -= 1
            startAnimation()
            self.textToShow = textForValue(value) ?? ""
        }
    }
    
    @hColorBuilder
    private func getColor() -> some hColor {
        if animate {
            hBackgroundColorNew.inputBackgroundActive
        } else {
            hBackgroundColorNew.inputBackground
        }
    }
    
    private var getPlaceHolderLabel: some View {
        Text(placeholder)
            .modifier(hFontModifierNew(style: !textToShow.isEmpty ? .footnote : .title3))
            .foregroundColor(hLabelColorNew.secondary)
    }
    
    private var getTextLabel: some View {
        hTextNew(textToShow, style: .title3)
            .foregroundColor(hLabelColorNew.primary)
    }
    
    private func startAnimation() {
        withAnimation {
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    self.animate = false
                }
            }
        }
    }
}

struct hCounterField_Previews: PreviewProvider {
    @State static var value: Int = 0
    static var previews: some View {
        hCounterField(value: $value,placeholder: "Placeholder", minValue: 0, maxValue: 5) { value in
            if value == 0 {
                return nil
            } else {
                return "VALUE \(value)"
            }
        }
    }
}
