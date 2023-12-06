import Foundation

struct RadioFieldsColors {
    @hColorBuilder
    func getFillColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.primary
        } else {
            hBackgroundColor.clear
        }
    }
    
    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.primary
        } else {
            hBorderColor.opaqueTwo
        }
    }
}
