//
//  DataCollectionIntro.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-08-17.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import hCoreUI
import Presentation
import Flow
import SwiftUI

public struct DataCollectionPersonalIdentity: View {
    public init() {}
    
    @State var inputtedPersonalNumber = ""
    
    var masking: Masking {
        switch Localization.Locale.currentLocale.market {
        case .no:
            return Masking(type: .norwegianPersonalNumber)
        case .se:
            return Masking(type: .personalNumber)
        default:
            return Masking(type: .none)
        }
    }
    
    public var body: some View {
        hForm {
            hSection {
                L10n.InsurelySeSsn.title
                    .hText(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                hTextField(
                    masking: masking,
                    value: $inputtedPersonalNumber
                ).padding(.top, 40)
                VStack {
                    hButton.LargeButtonFilled {
                        print(inputtedPersonalNumber)
                    } content: {
                        L10n.InsurelySsn.continueButtonText.hText()
                    }
                }.padding(.top, 40)
            }.sectionContainerStyle(.transparent)
        }
    }
}

extension DataCollectionPersonalIdentity {
    static func journey(modally: Bool = false) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionPersonalIdentity(),
            style: .detented(.large, modally: modally)
        ) { _ in
            ContinueJourney()
        }.configureTitle(L10n.Insurely.title)
    }
}

@available(iOS 15, *)
struct DataCollectionPersonalIdentityPreview: PreviewProvider {
    static var previews: some View {
        Group {
            JourneyPreviewer(
                DataCollectionPersonalIdentity.journey(modally: true)
            ).preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionPersonalIdentity.journey(modally: true)
            ).preferredColorScheme(.dark)
        }
    }
}
