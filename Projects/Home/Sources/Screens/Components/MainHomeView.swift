import Apollo
import Claims
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct MainHomeView: View {
    var body: some View {
        hSection {
            hText(L10n.HomeTab.welcomeTitleWithoutName, style: .displayXSLong)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            //            ClaimsCard()
            PillowView(animatedConfig)
                .frame(width: 200, height: 200)
            hCoreUIAssets.bigPillowCar.view
                .resizable()
                .frame(width: 200, height: 200)
        }
        .sectionContainerStyle(.transparent)
    }

    /// `.car` with a gentle wave: `speed > 0` makes `PillowView`'s `TimelineView`
    /// drift the wave phase continuously, and `waveX`/`waveY` set the amplitude.
    private var animatedConfig: PillowConfiguration {
        var config = PillowConfiguration.car
        config.waveX = 0.5
        config.waveY = 0
        config.speed = 1.5
        return config
    }
}

#Preview {
    MainHomeView()
}
