//
//  AppDelegate+UpdateLanguageMutation.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2022-03-09.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation

extension AppDelegate {
    func updateLanguageMutation(numberOfRetries: Int = 0) {
        let client: ApolloClient = Dependencies.shared.resolve()
        client.perform(
            mutation: GraphQL.UpdateLanguageMutation(
                language: locale.code,
                pickedLocale: locale.asGraphQLLocale()
            )
        )
        .onValue { _ in
            log.info("Updated language successfully")
        }
        .onError { error in
            log.info("Failed updating language, retries in \(numberOfTries * 100) ms")
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(numberOfTries) * 0.1)) {
                updateLanguageMutation(numberOfRetries: numberOfRetries + 1)
            }
        }
    }
}
