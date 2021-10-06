//
//  HighlightModel.swift
//  HighlightModel
//
//  Created by Sam Pettersson on 2021-10-06.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation

public struct Highlight: Codable, Equatable {
    public var title: String
    public var description: String
    
    init(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info.Highlight
    ) {
        self.title = data.title
        self.description = data.description
    }
}
