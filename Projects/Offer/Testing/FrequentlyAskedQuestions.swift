//
//  FrequentlyAskedQuestions.swift
//  OfferTesting
//
//  Created by Sam Pettersson on 2021-05-07.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hGraphQL

func generateFrequentlyAskedQuestions() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.FrequentlyAskedQuestion] {
    return [
        .init(
            id: UUID().uuidString,
            headline: "What is included in my home insurance?",
            body: "Your home insurance covers you, your things and your home. All risk and travel insurance is always included. Accident and health insurance is not included. Don’t hesitate to ask us if you want more information about your coverage!"
        ),
        .init(
            id: UUID().uuidString,
            headline: "Why should I choose Hedvig?",
            body: "Our home insurance includes the same base coverage as all other Swedish home insurances. In addition, Hedvig’s home insurance includes all risk, which is often only available as an add-on with other insurance companies. We also use  fair  depreciation rates when handling claims for your electronics.. We want insurance to be as simple and fun as possible. We are very easy to get in contact with and you can reach us via the chat in the app, mail or phone so that you don’t have to wait in long phone queues."
        ),
        .init(
            id: UUID().uuidString,
            headline: "Can I get Hedvig even though I already have an insurance policy?",
            body: "Of course. You can choose to activate your Hedvig insurance when your old insurance expires. We can help you with the switch from your old insurance company."
        )
    ]
}
