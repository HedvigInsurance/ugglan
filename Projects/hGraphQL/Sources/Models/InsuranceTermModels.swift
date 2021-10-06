//
//  HighlightModel.swift
//  HighlightModel
//
//  Created by Sam Pettersson on 2021-10-06.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation

public struct InsuranceTerm: Codable, Equatable {
    public var displayName: String
    public var url: URL
    
    init?(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info.InsuranceTerm
    ) {
        guard let url = URL(string: data.url) else {
            
            return nil
        }
        
        self.displayName = data.displayName
        self.url = url
    }
}
