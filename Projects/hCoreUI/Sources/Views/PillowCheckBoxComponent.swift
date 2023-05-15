import SwiftUI

public struct PillowCheckBoxComponent: View {
    @State var isSelected: String = ""
    let text: String
    //    var onSelect: () -> Void

    public init(
        text: String
            //        onSelect: @escaping () -> Void
    ) {
        self.text = text
        //        self.onSelect = onSelect
    }

    public var body: some View {
        HStack {
            Image(uiImage: hCoreUIAssets.pillowHome.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)

            hText(text, style: .body)
            Spacer()
            Image(uiImage: (isSelected == text) ? hCoreUIAssets.circleFill.image : hCoreUIAssets.circleEmpty.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
        }
        .padding([.top, .bottom], 28)
        .padding([.leading, .trailing], 16)
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .padding([.leading, .trailing], 16)
        .onTapGesture {
            isSelected = text
        }
    }
    public func getSelected() -> String {
        return isSelected
    }
}

struct PillowCheckBoxComponent_Previews: PreviewProvider {
    static var previews: some View {
        PillowCheckBoxComponent(text: "Bostadsrätt")
    }
}
