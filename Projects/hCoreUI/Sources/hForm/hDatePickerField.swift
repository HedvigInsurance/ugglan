import SwiftUI
import hCore
import Presentation

public struct hDatePickerField: View {
    private let config: HDatePickerFieldConfig
    private let onUpdate: (_ date: Date) -> Void
    private let onContinue: (_ date: Date) -> Void
    @State private var animate = false
    @State private var date = Date()
    @Binding private var selectedDate:Date?
    
    public init(config: HDatePickerFieldConfig,
                selectedDate: Binding<Date?>,
                onUpdate: @escaping (_ date: Date) -> Void = {_ in},
                onContinue: @escaping (_ date: Date) -> Void = {_ in}) {
        self.config = config
        self.onUpdate = onUpdate
        self.onContinue = onContinue
        self._selectedDate = selectedDate
        self.date = selectedDate.wrappedValue ?? Date()
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            getFieldLabel()
            getValueLabel()
        }
        .padding(.horizontal, 16)
        .background(getColor())
        .animation(.easeInOut(duration: 0.4), value: animate)
        .clipShape(Squircle.default())
        .onTapGesture {
            showDatePicker()
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animate = false
            }
        }.onChange(of: date) { date in
            selectedDate = date
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
    
    private func getFieldLabel() -> some View {
        HStack {
            Text(config.placeholder)
                .modifier(hFontModifierNew(style: .title3))
                .foregroundColor (hLabelColorNew.secondary)
                .padding(EdgeInsets(top: 0, leading:0, bottom: 40, trailing: 0))
                .scaleEffect(0.6, anchor: .leading)
            Spacer()
        }
        
        
    }
    
    private func getValueLabel() -> some View {
        HStack {
            Text(selectedDate?.localDateString ?? L10n.generalSelectButton)
                .modifier(hFontModifierNew(style: .title3))
                .foregroundColor (hLabelColorNew.primary)
                .padding(EdgeInsets(top: 26.67, leading: 0, bottom: 13.33, trailing: 0))
            Spacer()
        }
        
    }
    
    func showDatePicker(){
        let journey: any JourneyPresentation = HostingJourney(
            rootView: getDatePickerView(),
            style: .detented(.scrollViewContentSize),
            options: .embedInNavigationController
        ).withDismissButton
        let vc = UIApplication.shared.getTopViewController()
        _ = vc?.present(journey)
    }
    
    func getDatePickerView() -> some View {
        ScrollView {
            DatePicker("",
                       selection: $date,
                       displayedComponents: [.date])
            .datePickerStyle(.graphical)
        }
    }
    
    public struct HDatePickerFieldConfig {
        let minDate: Date?
        let maxDate: Date?
        let placeholder: String
        
        public init(minDate: Date? = nil, maxDate: Date? = nil, placeholder: String) {
            self.minDate = minDate
            self.maxDate = maxDate
            self.placeholder = placeholder
        }
    }
}



struct hDatePickerField_Previews: PreviewProvider {
    @State private static var date: Date?
    private static let config = hDatePickerField.HDatePickerFieldConfig(
        placeholder: "Placeholder"
    )
    static var previews: some View {
        hDatePickerField(config: config, selectedDate: $date)
    }
}
