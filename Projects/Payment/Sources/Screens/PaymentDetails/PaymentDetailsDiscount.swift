import SwiftUI
import hCore
import hCoreUI

struct PaymentDetailsDiscount: View {
    let discount: Discount

    var body: some View {

        hRow {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    hText(discount.code, style: .standardSmall)
                        .foregroundColor(hTextColor.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(hFillColor.opaqueOne)

                        )
                    Spacer()
                    hText(discount.amount.formattedAmount)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        hText(discount.title, style: .standardSmall)
                        Spacer()
                        if let validUntil = discount.validUntil {
                            hText("Valid until \(validUntil.displayDate)", style: .standardSmall)
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(discount.listOfAffectedInsurances) { affectedInsurance in
                            hText(affectedInsurance.displayName, style: .standardSmall)
                        }
                    }
                }
            }
            .foregroundColor(hTextColor.secondary)
        }
        .noHorizontalPadding()
        .dividerInsets(.all, 0)
    }
}

struct PaymentDetailsDiscount_Previews: PreviewProvider {
    static var previews: some View {
        PaymentDetailsDiscount(
            discount: .init(
                id: "",
                code: "",
                amount: .sek(100),
                title: "",
                listOfAffectedInsurances: [],
                validUntil: nil,
                isValid: true
            )
        )
    }
}
