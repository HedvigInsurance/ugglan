//
//  String+Translation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-06.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation

extension String {
    static var _localizationKey: UInt8 = 0
    
    var localizationKey: Localization.Key? {
        get {
            guard let value = objc_getAssociatedObject(
                self,
                &String._localizationKey
                ) as? Localization.Key? else {
                    return nil
            }
            
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &String._localizationKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    init(_ key: Localization.Key) {
        switch Localization.Language.currentLanguage {
        case .sv_SE:
            self = Localization.Translations.sv_SE.for(key: key)
        case .en_SE:
            // as we don't have things translated into english yet, just return sv_SE
            self = Localization.Translations.sv_SE.for(key: key)
        }
        
        localizationKey = key
    }
}
