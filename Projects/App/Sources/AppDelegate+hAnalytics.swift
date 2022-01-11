//
//  AppDelegate+hAnalytics.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-12-18.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hAnalytics
import Mixpanel
import Firebase
import hCore
import hGraphQL
import Apollo

extension AppDelegate {
    func setupHAnalytics() {
        hAnalyticsProviders.sendEvent = { event in
            log.info("Sending analytics event: \(event) \(event.properties)")

            Firebase.Analytics.logEvent(event.name, parameters: event.properties.compactMapValues({ any in
                any
            }))
            Mixpanel.mainInstance()
                .track(
                    event: event.name,
                    properties: event.properties.compactMapValues({ property in
                        self as? MixpanelType
                    })
                )
        }
        
        hAnalyticsProviders.performGraphQLQuery = { query, variables, onComplete in
            var urlRequest = URLRequest(url: Environment.current.endpointURL)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            guard let JSONData = try? JSONSerialization.data(
                withJSONObject: ["query": query, "variables": variables],
                options: []
            ) else {
                onComplete(nil)
                return
            }
            urlRequest.httpBody = JSONData

            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders =
                ApolloClient.headers(token: ApolloClient.retreiveToken()?.token) as [AnyHashable: Any]

            let urlSessionClient = URLSessionClient(sessionConfiguration: configuration)
            
            let task = urlSessionClient.session.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, let JSONResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? ResultMap else {
                    onComplete(nil)
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    onComplete(JSONResponse["data"] ?? nil)
                } else {
                    onComplete(nil)
                }
            }
            
            
            task.resume()
        }
    }
}
