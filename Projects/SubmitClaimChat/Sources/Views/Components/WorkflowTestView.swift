import SwiftUI

struct WorkflowTestView: View {
    var body: some View {
        VStack {
            // This will trigger accessibility warning: onTapGesture without button traits
            Text("Tap me")
                .onTapGesture {
                    print("Tapped")
                }

            // This will trigger warning: Image without accessibility
            Image(systemName: "star")
        }
    }
}
