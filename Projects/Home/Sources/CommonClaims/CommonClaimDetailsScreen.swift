import SwiftUI
import hGraphQL

struct CommonClaimDetailsScreen: View {

    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
    }
}

struct CommonClaimDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        CommonClaimDetailsScreen(
            claim: .init(
                id: "id",
                icon: nil,
                imageName: nil,
                displayTitle: "title",
                layout: CommonClaim.Layout(titleAndBulletPoint: nil, emergency: nil)
            )
        )
    }
}
