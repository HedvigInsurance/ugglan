//
//  UITextContentType+Apollo.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Apollo
import Foundation
import UIKit
import Space

extension UITextContentType {
    static func from(_ textContentType: TextContentType?) -> UITextContentType? {
        guard let textContentType = textContentType else {
            return nil
        }

        switch textContentType {
        case .none:
            return .none
        case .url:
            return .URL
        case .addressCity:
            return .addressCity
        case .addressCityState:
            return .addressCityAndState
        case .addressState:
            return .addressState
        case .countryName:
            return .countryName
        case .creditCardNumber:
            return .creditCardNumber
        case .emailAddress:
            return .emailAddress
        case .familyName:
            return .familyName
        case .fullStreetAddress:
            return .fullStreetAddress
        case .givenName:
            return .givenName
        case .jobTitle:
            return .jobTitle
        case .location:
            return .location
        case .middleName:
            return .middleName
        case .name:
            return .name
        case .namePrefix:
            return .namePrefix
        case .nameSuffix:
            return .nameSuffix
        case .nickName:
            return .nickname
        case .organizationName:
            return .organizationName
        case .postalCode:
            return .postalCode
        case .streetAddressLine1:
            return .streetAddressLine1
        case .streetAddressLine2:
            return .streetAddressLine2
        case .sublocality:
            return .sublocality
        case .telephoneNumber:
            return .telephoneNumber
        case .username:
            return .username
        case .password:
            return .password
        case .__unknown:
            return .none
        }
    }
}
