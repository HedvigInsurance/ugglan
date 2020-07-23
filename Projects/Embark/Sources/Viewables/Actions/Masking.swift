//
//  Masking.swift
//  Ugglan
//
//  Created by Axel Backlund on 2020-02-28.
//

import Foundation

enum MaskType: String {
    case personalNumber = "PersonalNumber"
    case postalCode = "PostalCode"
    case email = "Email"
    case birthDate = "BirthDate"
    case birthDateReverse = "BirthDateReverse"
    case norwegianPostalCode = "NorwegianPostalCode"
}

struct Masking {
    let type: MaskType
    
    func isValid(text _: String) -> String {
        return ""
    }
    
    func unmaskedValue(text: String) -> String {
        switch type {
        case .personalNumber:
            return text.replacingOccurrences(of: "-", with: "")
        case .postalCode:
            return text.replacingOccurrences(of: " ", with: "")
        case .birthDate:
            return text
        case .birthDateReverse:
            let reverseDateFormatter = DateFormatter()
            reverseDateFormatter.dateFormat = "dd-MM-yyyy"
            
            guard let date = reverseDateFormatter.date(from: text) else {
                return text
            }
            
            let birthDateFormatter = DateFormatter()
            birthDateFormatter.dateFormat = "yyyy-MM-dd"
            
            return birthDateFormatter.string(from: date)
        default:
            return text
        }
    }
    
    func derivedValues(text: String) -> [String: String]? {
        let unmaskedValue = self.unmaskedValue(text: text)
        
        func calculateAge(_ format: String, value: String) -> String? {
            let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = format
           
           guard let dateOfBirth = dateFormatter.date(from: value) else {
               return nil
           }
           
           let components = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())

           guard let age = components.year else {
               return nil
           }
            
            return String(age)
        }
        
        switch type {
        case .personalNumber:
            guard let age = calculateAge("yyMMdd", value: String(unmaskedValue.prefix(6))) else {
                return nil
            }
                        
            return [
                ".Age": age
            ]
        case .birthDateReverse, .birthDate:
            guard let age = calculateAge("yyyy-MM-dd", value: unmaskedValue) else {
                return nil
            }
                                    
            return [
                ".Age": age
            ]
        default:
            return nil
        }
    }

    func maskValue(text: String, previousText: String) -> String {
        func delimitedDigits(delimiterPositions: [Int], maxCount: Int, delimiter: Character) -> String {
            if text.count < previousText.count {
                if text.last == delimiter {
                    return String(text.dropLast(1))
                }
                
                return text
            }
            
            if text.count <= maxCount {
                let sanitizedText = text.filter { $0.isDigit || $0 == delimiter }
                                
                if !(sanitizedText.last?.isDigit ?? false) && !delimiterPositions.contains(sanitizedText.count) {
                    return previousText
                }
                
                if delimiterPositions.contains(sanitizedText.count) {
                    let textWithoutLast = sanitizedText.dropLast(1)
                    let lastChar = String(sanitizedText.last ?? Character(""))
                    
                    if lastChar.last == delimiter {
                        return sanitizedText
                    }
                    
                    return "\(textWithoutLast)-\(lastChar)"
                }

                return sanitizedText
            } else {
                return previousText
            }
        }
        
        switch type {
        case .personalNumber:
            return delimitedDigits(delimiterPositions: [7], maxCount: 11, delimiter: "-")
        case .postalCode:
            return delimitedDigits(delimiterPositions: [4], maxCount: 6, delimiter: " ")
        case .norwegianPostalCode:
            return delimitedDigits(delimiterPositions: [], maxCount: 4, delimiter: " ")
        case .birthDate:
            return delimitedDigits(delimiterPositions: [5, 8], maxCount: 10, delimiter: "-")
        case .birthDateReverse:
            return delimitedDigits(delimiterPositions: [3, 6], maxCount: 10, delimiter: "-")
        default:
            return text
        }
    }
}
