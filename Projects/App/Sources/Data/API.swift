// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct S3FileInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - bucket
  ///   - key
  public init(bucket: String, key: String) {
    graphQLMap = ["bucket": bucket, "key": key]
  }

  public var bucket: String {
    get {
      return graphQLMap["bucket"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }
}

public struct TokenizationRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - paymentMethodDetails
  ///   - channel
  ///   - browserInfo
  ///   - returnUrl
  public init(paymentMethodDetails: String, channel: TokenizationChannel, browserInfo: Swift.Optional<BrowserInfo?> = nil, returnUrl: String) {
    graphQLMap = ["paymentMethodDetails": paymentMethodDetails, "channel": channel, "browserInfo": browserInfo, "returnUrl": returnUrl]
  }

  public var paymentMethodDetails: String {
    get {
      return graphQLMap["paymentMethodDetails"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "paymentMethodDetails")
    }
  }

  public var channel: TokenizationChannel {
    get {
      return graphQLMap["channel"] as! TokenizationChannel
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "channel")
    }
  }

  public var browserInfo: Swift.Optional<BrowserInfo?> {
    get {
      return graphQLMap["browserInfo"] as? Swift.Optional<BrowserInfo?> ?? Swift.Optional<BrowserInfo?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "browserInfo")
    }
  }

  public var returnUrl: String {
    get {
      return graphQLMap["returnUrl"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "returnUrl")
    }
  }
}

public enum TokenizationChannel: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case android
  case ios
  case web
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ANDROID": self = .android
      case "IOS": self = .ios
      case "WEB": self = .web
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .android: return "ANDROID"
      case .ios: return "IOS"
      case .web: return "WEB"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: TokenizationChannel, rhs: TokenizationChannel) -> Bool {
    switch (lhs, rhs) {
      case (.android, .android): return true
      case (.ios, .ios): return true
      case (.web, .web): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [TokenizationChannel] {
    return [
      .android,
      .ios,
      .web,
    ]
  }
}

public struct BrowserInfo: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - userAgent
  ///   - acceptHeader
  ///   - language
  ///   - colorDepth
  ///   - screenHeight
  ///   - screenWidth
  ///   - timeZoneOffset
  ///   - javaEnabled
  public init(userAgent: String, acceptHeader: String, language: String, colorDepth: Int, screenHeight: Int, screenWidth: Int, timeZoneOffset: Int, javaEnabled: Bool) {
    graphQLMap = ["userAgent": userAgent, "acceptHeader": acceptHeader, "language": language, "colorDepth": colorDepth, "screenHeight": screenHeight, "screenWidth": screenWidth, "timeZoneOffset": timeZoneOffset, "javaEnabled": javaEnabled]
  }

  public var userAgent: String {
    get {
      return graphQLMap["userAgent"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userAgent")
    }
  }

  public var acceptHeader: String {
    get {
      return graphQLMap["acceptHeader"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "acceptHeader")
    }
  }

  public var language: String {
    get {
      return graphQLMap["language"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "language")
    }
  }

  public var colorDepth: Int {
    get {
      return graphQLMap["colorDepth"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "colorDepth")
    }
  }

  public var screenHeight: Int {
    get {
      return graphQLMap["screenHeight"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "screenHeight")
    }
  }

  public var screenWidth: Int {
    get {
      return graphQLMap["screenWidth"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "screenWidth")
    }
  }

  public var timeZoneOffset: Int {
    get {
      return graphQLMap["timeZoneOffset"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timeZoneOffset")
    }
  }

  public var javaEnabled: Bool {
    get {
      return graphQLMap["javaEnabled"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "javaEnabled")
    }
  }
}

public enum AuthState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case initiated
  case inProgress
  case failed
  case success
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "INITIATED": self = .initiated
      case "IN_PROGRESS": self = .inProgress
      case "FAILED": self = .failed
      case "SUCCESS": self = .success
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .initiated: return "INITIATED"
      case .inProgress: return "IN_PROGRESS"
      case .failed: return "FAILED"
      case .success: return "SUCCESS"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: AuthState, rhs: AuthState) -> Bool {
    switch (lhs, rhs) {
      case (.initiated, .initiated): return true
      case (.inProgress, .inProgress): return true
      case (.failed, .failed): return true
      case (.success, .success): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [AuthState] {
    return [
      .initiated,
      .inProgress,
      .failed,
      .success,
    ]
  }
}

public enum CancelDirectDebitStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case accepted
  case declinedMissingToken
  case declinedMissingRequest
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ACCEPTED": self = .accepted
      case "DECLINED_MISSING_TOKEN": self = .declinedMissingToken
      case "DECLINED_MISSING_REQUEST": self = .declinedMissingRequest
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .accepted: return "ACCEPTED"
      case .declinedMissingToken: return "DECLINED_MISSING_TOKEN"
      case .declinedMissingRequest: return "DECLINED_MISSING_REQUEST"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CancelDirectDebitStatus, rhs: CancelDirectDebitStatus) -> Bool {
    switch (lhs, rhs) {
      case (.accepted, .accepted): return true
      case (.declinedMissingToken, .declinedMissingToken): return true
      case (.declinedMissingRequest, .declinedMissingRequest): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [CancelDirectDebitStatus] {
    return [
      .accepted,
      .declinedMissingToken,
      .declinedMissingRequest,
    ]
  }
}

public enum Locale: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case svSe
  case enSe
  case nbNo
  case enNo
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "sv_SE": self = .svSe
      case "en_SE": self = .enSe
      case "nb_NO": self = .nbNo
      case "en_NO": self = .enNo
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .svSe: return "sv_SE"
      case .enSe: return "en_SE"
      case .nbNo: return "nb_NO"
      case .enNo: return "en_NO"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: Locale, rhs: Locale) -> Bool {
    switch (lhs, rhs) {
      case (.svSe, .svSe): return true
      case (.enSe, .enSe): return true
      case (.nbNo, .nbNo): return true
      case (.enNo, .enNo): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [Locale] {
    return [
      .svSe,
      .enSe,
      .nbNo,
      .enNo,
    ]
  }
}

public enum HedvigColor: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case pink
  case turquoise
  case purple
  case darkPurple
  case blackPurple
  case darkGray
  case lightGray
  case white
  case black
  case offBlack
  case offWhite
  case yellow
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Pink": self = .pink
      case "Turquoise": self = .turquoise
      case "Purple": self = .purple
      case "DarkPurple": self = .darkPurple
      case "BlackPurple": self = .blackPurple
      case "DarkGray": self = .darkGray
      case "LightGray": self = .lightGray
      case "White": self = .white
      case "Black": self = .black
      case "OffBlack": self = .offBlack
      case "OffWhite": self = .offWhite
      case "Yellow": self = .yellow
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .pink: return "Pink"
      case .turquoise: return "Turquoise"
      case .purple: return "Purple"
      case .darkPurple: return "DarkPurple"
      case .blackPurple: return "BlackPurple"
      case .darkGray: return "DarkGray"
      case .lightGray: return "LightGray"
      case .white: return "White"
      case .black: return "Black"
      case .offBlack: return "OffBlack"
      case .offWhite: return "OffWhite"
      case .yellow: return "Yellow"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: HedvigColor, rhs: HedvigColor) -> Bool {
    switch (lhs, rhs) {
      case (.pink, .pink): return true
      case (.turquoise, .turquoise): return true
      case (.purple, .purple): return true
      case (.darkPurple, .darkPurple): return true
      case (.blackPurple, .blackPurple): return true
      case (.darkGray, .darkGray): return true
      case (.lightGray, .lightGray): return true
      case (.white, .white): return true
      case (.black, .black): return true
      case (.offBlack, .offBlack): return true
      case (.offWhite, .offWhite): return true
      case (.yellow, .yellow): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [HedvigColor] {
    return [
      .pink,
      .turquoise,
      .purple,
      .darkPurple,
      .blackPurple,
      .darkGray,
      .lightGray,
      .white,
      .black,
      .offBlack,
      .offWhite,
      .yellow,
    ]
  }
}

public enum SwedishApartmentLineOfBusiness: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case rent
  case brf
  case studentRent
  case studentBrf
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "RENT": self = .rent
      case "BRF": self = .brf
      case "STUDENT_RENT": self = .studentRent
      case "STUDENT_BRF": self = .studentBrf
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .rent: return "RENT"
      case .brf: return "BRF"
      case .studentRent: return "STUDENT_RENT"
      case .studentBrf: return "STUDENT_BRF"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SwedishApartmentLineOfBusiness, rhs: SwedishApartmentLineOfBusiness) -> Bool {
    switch (lhs, rhs) {
      case (.rent, .rent): return true
      case (.brf, .brf): return true
      case (.studentRent, .studentRent): return true
      case (.studentBrf, .studentBrf): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SwedishApartmentLineOfBusiness] {
    return [
      .rent,
      .brf,
      .studentRent,
      .studentBrf,
    ]
  }
}

public struct CreateKeyGearItemInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - photos
  ///   - category
  ///   - purchasePrice
  ///   - physicalReferenceHash
  ///   - name
  public init(photos: [S3FileInput], category: KeyGearItemCategory, purchasePrice: Swift.Optional<MonetaryAmountV2Input?> = nil, physicalReferenceHash: Swift.Optional<String?> = nil, name: Swift.Optional<String?> = nil) {
    graphQLMap = ["photos": photos, "category": category, "purchasePrice": purchasePrice, "physicalReferenceHash": physicalReferenceHash, "name": name]
  }

  public var photos: [S3FileInput] {
    get {
      return graphQLMap["photos"] as! [S3FileInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "photos")
    }
  }

  public var category: KeyGearItemCategory {
    get {
      return graphQLMap["category"] as! KeyGearItemCategory
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  public var purchasePrice: Swift.Optional<MonetaryAmountV2Input?> {
    get {
      return graphQLMap["purchasePrice"] as? Swift.Optional<MonetaryAmountV2Input?> ?? Swift.Optional<MonetaryAmountV2Input?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "purchasePrice")
    }
  }

  public var physicalReferenceHash: Swift.Optional<String?> {
    get {
      return graphQLMap["physicalReferenceHash"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "physicalReferenceHash")
    }
  }

  public var name: Swift.Optional<String?> {
    get {
      return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }
}

public enum KeyGearItemCategory: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case phone
  case computer
  case tv
  case bike
  case jewelry
  case watch
  case smartWatch
  case tablet
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PHONE": self = .phone
      case "COMPUTER": self = .computer
      case "TV": self = .tv
      case "BIKE": self = .bike
      case "JEWELRY": self = .jewelry
      case "WATCH": self = .watch
      case "SMART_WATCH": self = .smartWatch
      case "TABLET": self = .tablet
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .phone: return "PHONE"
      case .computer: return "COMPUTER"
      case .tv: return "TV"
      case .bike: return "BIKE"
      case .jewelry: return "JEWELRY"
      case .watch: return "WATCH"
      case .smartWatch: return "SMART_WATCH"
      case .tablet: return "TABLET"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: KeyGearItemCategory, rhs: KeyGearItemCategory) -> Bool {
    switch (lhs, rhs) {
      case (.phone, .phone): return true
      case (.computer, .computer): return true
      case (.tv, .tv): return true
      case (.bike, .bike): return true
      case (.jewelry, .jewelry): return true
      case (.watch, .watch): return true
      case (.smartWatch, .smartWatch): return true
      case (.tablet, .tablet): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [KeyGearItemCategory] {
    return [
      .phone,
      .computer,
      .tv,
      .bike,
      .jewelry,
      .watch,
      .smartWatch,
      .tablet,
    ]
  }
}

public struct MonetaryAmountV2Input: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - amount
  ///   - currency
  public init(amount: String, currency: String) {
    graphQLMap = ["amount": amount, "currency": currency]
  }

  public var amount: String {
    get {
      return graphQLMap["amount"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var currency: String {
    get {
      return graphQLMap["currency"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "currency")
    }
  }
}

public struct CampaignInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - source
  ///   - medium
  ///   - term
  ///   - content
  ///   - name
  public init(source: Swift.Optional<String?> = nil, medium: Swift.Optional<String?> = nil, term: Swift.Optional<String?> = nil, content: Swift.Optional<String?> = nil, name: Swift.Optional<String?> = nil) {
    graphQLMap = ["source": source, "medium": medium, "term": term, "content": content, "name": name]
  }

  public var source: Swift.Optional<String?> {
    get {
      return graphQLMap["source"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "source")
    }
  }

  public var medium: Swift.Optional<String?> {
    get {
      return graphQLMap["medium"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "medium")
    }
  }

  public var term: Swift.Optional<String?> {
    get {
      return graphQLMap["term"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "term")
    }
  }

  public var content: Swift.Optional<String?> {
    get {
      return graphQLMap["content"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "content")
    }
  }

  public var name: Swift.Optional<String?> {
    get {
      return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }
}

public enum InsuranceStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case pending
  case active
  case inactive
  case inactiveWithStartDate
  case terminated
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PENDING": self = .pending
      case "ACTIVE": self = .active
      case "INACTIVE": self = .inactive
      case "INACTIVE_WITH_START_DATE": self = .inactiveWithStartDate
      case "TERMINATED": self = .terminated
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .pending: return "PENDING"
      case .active: return "ACTIVE"
      case .inactive: return "INACTIVE"
      case .inactiveWithStartDate: return "INACTIVE_WITH_START_DATE"
      case .terminated: return "TERMINATED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InsuranceStatus, rhs: InsuranceStatus) -> Bool {
    switch (lhs, rhs) {
      case (.pending, .pending): return true
      case (.active, .active): return true
      case (.inactive, .inactive): return true
      case (.inactiveWithStartDate, .inactiveWithStartDate): return true
      case (.terminated, .terminated): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InsuranceStatus] {
    return [
      .pending,
      .active,
      .inactive,
      .inactiveWithStartDate,
      .terminated,
    ]
  }
}

public enum InsuranceType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case rent
  case brf
  case studentRent
  case studentBrf
  case house
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "RENT": self = .rent
      case "BRF": self = .brf
      case "STUDENT_RENT": self = .studentRent
      case "STUDENT_BRF": self = .studentBrf
      case "HOUSE": self = .house
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .rent: return "RENT"
      case .brf: return "BRF"
      case .studentRent: return "STUDENT_RENT"
      case .studentBrf: return "STUDENT_BRF"
      case .house: return "HOUSE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InsuranceType, rhs: InsuranceType) -> Bool {
    switch (lhs, rhs) {
      case (.rent, .rent): return true
      case (.brf, .brf): return true
      case (.studentRent, .studentRent): return true
      case (.studentBrf, .studentBrf): return true
      case (.house, .house): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InsuranceType] {
    return [
      .rent,
      .brf,
      .studentRent,
      .studentBrf,
      .house,
    ]
  }
}

public enum Feature: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case keyGear
  case referrals
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "KeyGear": self = .keyGear
      case "Referrals": self = .referrals
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .keyGear: return "KeyGear"
      case .referrals: return "Referrals"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: Feature, rhs: Feature) -> Bool {
    switch (lhs, rhs) {
      case (.keyGear, .keyGear): return true
      case (.referrals, .referrals): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [Feature] {
    return [
      .keyGear,
      .referrals,
    ]
  }
}

public struct LoggingInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - timestamp
  ///   - source
  ///   - payload
  ///   - severity
  public init(timestamp: String, source: LoggingSource, payload: String, severity: LoggingSeverity) {
    graphQLMap = ["timestamp": timestamp, "source": source, "payload": payload, "severity": severity]
  }

  public var timestamp: String {
    get {
      return graphQLMap["timestamp"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var source: LoggingSource {
    get {
      return graphQLMap["source"] as! LoggingSource
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "source")
    }
  }

  public var payload: String {
    get {
      return graphQLMap["payload"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "payload")
    }
  }

  public var severity: LoggingSeverity {
    get {
      return graphQLMap["severity"] as! LoggingSeverity
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "severity")
    }
  }
}

public enum LoggingSource: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case ios
  case android
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "IOS": self = .ios
      case "ANDROID": self = .android
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .ios: return "IOS"
      case .android: return "ANDROID"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: LoggingSource, rhs: LoggingSource) -> Bool {
    switch (lhs, rhs) {
      case (.ios, .ios): return true
      case (.android, .android): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [LoggingSource] {
    return [
      .ios,
      .android,
    ]
  }
}

public enum LoggingSeverity: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case `default`
  case debug
  case info
  case notice
  case warning
  case error
  case critical
  case alert
  case emergency
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "DEFAULT": self = .default
      case "DEBUG": self = .debug
      case "INFO": self = .info
      case "NOTICE": self = .notice
      case "WARNING": self = .warning
      case "ERROR": self = .error
      case "CRITICAL": self = .critical
      case "ALERT": self = .alert
      case "EMERGENCY": self = .emergency
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .default: return "DEFAULT"
      case .debug: return "DEBUG"
      case .info: return "INFO"
      case .notice: return "NOTICE"
      case .warning: return "WARNING"
      case .error: return "ERROR"
      case .critical: return "CRITICAL"
      case .alert: return "ALERT"
      case .emergency: return "EMERGENCY"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: LoggingSeverity, rhs: LoggingSeverity) -> Bool {
    switch (lhs, rhs) {
      case (.default, .default): return true
      case (.debug, .debug): return true
      case (.info, .info): return true
      case (.notice, .notice): return true
      case (.warning, .warning): return true
      case (.error, .error): return true
      case (.critical, .critical): return true
      case (.alert, .alert): return true
      case (.emergency, .emergency): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [LoggingSeverity] {
    return [
      .default,
      .debug,
      .info,
      .notice,
      .warning,
      .error,
      .critical,
      .alert,
      .emergency,
    ]
  }
}

public enum PayinMethodStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case active
  case pending
  case needsSetup
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ACTIVE": self = .active
      case "PENDING": self = .pending
      case "NEEDS_SETUP": self = .needsSetup
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .active: return "ACTIVE"
      case .pending: return "PENDING"
      case .needsSetup: return "NEEDS_SETUP"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PayinMethodStatus, rhs: PayinMethodStatus) -> Bool {
    switch (lhs, rhs) {
      case (.active, .active): return true
      case (.pending, .pending): return true
      case (.needsSetup, .needsSetup): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PayinMethodStatus] {
    return [
      .active,
      .pending,
      .needsSetup,
    ]
  }
}

public enum BankIdStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case pending
  case failed
  case complete
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "pending": self = .pending
      case "failed": self = .failed
      case "complete": self = .complete
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .pending: return "pending"
      case .failed: return "failed"
      case .complete: return "complete"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: BankIdStatus, rhs: BankIdStatus) -> Bool {
    switch (lhs, rhs) {
      case (.pending, .pending): return true
      case (.failed, .failed): return true
      case (.complete, .complete): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [BankIdStatus] {
    return [
      .pending,
      .failed,
      .complete,
    ]
  }
}

public enum SignState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case initiated
  case inProgress
  case failed
  case completed
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "INITIATED": self = .initiated
      case "IN_PROGRESS": self = .inProgress
      case "FAILED": self = .failed
      case "COMPLETED": self = .completed
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .initiated: return "INITIATED"
      case .inProgress: return "IN_PROGRESS"
      case .failed: return "FAILED"
      case .completed: return "COMPLETED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SignState, rhs: SignState) -> Bool {
    switch (lhs, rhs) {
      case (.initiated, .initiated): return true
      case (.inProgress, .inProgress): return true
      case (.failed, .failed): return true
      case (.completed, .completed): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SignState] {
    return [
      .initiated,
      .inProgress,
      .failed,
      .completed,
    ]
  }
}

public enum MessageBodyChoicesLinkView: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case offer
  case dashboard
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "OFFER": self = .offer
      case "DASHBOARD": self = .dashboard
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .offer: return "OFFER"
      case .dashboard: return "DASHBOARD"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: MessageBodyChoicesLinkView, rhs: MessageBodyChoicesLinkView) -> Bool {
    switch (lhs, rhs) {
      case (.offer, .offer): return true
      case (.dashboard, .dashboard): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [MessageBodyChoicesLinkView] {
    return [
      .offer,
      .dashboard,
    ]
  }
}

public enum KeyboardType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case `default`
  case numberpad
  case decimalpad
  case numeric
  case email
  case phone
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "DEFAULT": self = .default
      case "NUMBERPAD": self = .numberpad
      case "DECIMALPAD": self = .decimalpad
      case "NUMERIC": self = .numeric
      case "EMAIL": self = .email
      case "PHONE": self = .phone
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .default: return "DEFAULT"
      case .numberpad: return "NUMBERPAD"
      case .decimalpad: return "DECIMALPAD"
      case .numeric: return "NUMERIC"
      case .email: return "EMAIL"
      case .phone: return "PHONE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: KeyboardType, rhs: KeyboardType) -> Bool {
    switch (lhs, rhs) {
      case (.default, .default): return true
      case (.numberpad, .numberpad): return true
      case (.decimalpad, .decimalpad): return true
      case (.numeric, .numeric): return true
      case (.email, .email): return true
      case (.phone, .phone): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [KeyboardType] {
    return [
      .default,
      .numberpad,
      .decimalpad,
      .numeric,
      .email,
      .phone,
    ]
  }
}

public enum TextContentType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case `none`
  case url
  case addressCity
  case addressCityState
  case addressState
  case countryName
  case creditCardNumber
  case emailAddress
  case familyName
  case fullStreetAddress
  case givenName
  case jobTitle
  case location
  case middleName
  case name
  case namePrefix
  case nameSuffix
  case nickName
  case organizationName
  case postalCode
  case streetAddressLine1
  case streetAddressLine2
  case sublocality
  case telephoneNumber
  case username
  case password
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "NONE": self = .none
      case "URL": self = .url
      case "ADDRESS_CITY": self = .addressCity
      case "ADDRESS_CITY_STATE": self = .addressCityState
      case "ADDRESS_STATE": self = .addressState
      case "COUNTRY_NAME": self = .countryName
      case "CREDIT_CARD_NUMBER": self = .creditCardNumber
      case "EMAIL_ADDRESS": self = .emailAddress
      case "FAMILY_NAME": self = .familyName
      case "FULL_STREET_ADDRESS": self = .fullStreetAddress
      case "GIVEN_NAME": self = .givenName
      case "JOB_TITLE": self = .jobTitle
      case "LOCATION": self = .location
      case "MIDDLE_NAME": self = .middleName
      case "NAME": self = .name
      case "NAME_PREFIX": self = .namePrefix
      case "NAME_SUFFIX": self = .nameSuffix
      case "NICK_NAME": self = .nickName
      case "ORGANIZATION_NAME": self = .organizationName
      case "POSTAL_CODE": self = .postalCode
      case "STREET_ADDRESS_LINE1": self = .streetAddressLine1
      case "STREET_ADDRESS_LINE2": self = .streetAddressLine2
      case "SUBLOCALITY": self = .sublocality
      case "TELEPHONE_NUMBER": self = .telephoneNumber
      case "USERNAME": self = .username
      case "PASSWORD": self = .password
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .none: return "NONE"
      case .url: return "URL"
      case .addressCity: return "ADDRESS_CITY"
      case .addressCityState: return "ADDRESS_CITY_STATE"
      case .addressState: return "ADDRESS_STATE"
      case .countryName: return "COUNTRY_NAME"
      case .creditCardNumber: return "CREDIT_CARD_NUMBER"
      case .emailAddress: return "EMAIL_ADDRESS"
      case .familyName: return "FAMILY_NAME"
      case .fullStreetAddress: return "FULL_STREET_ADDRESS"
      case .givenName: return "GIVEN_NAME"
      case .jobTitle: return "JOB_TITLE"
      case .location: return "LOCATION"
      case .middleName: return "MIDDLE_NAME"
      case .name: return "NAME"
      case .namePrefix: return "NAME_PREFIX"
      case .nameSuffix: return "NAME_SUFFIX"
      case .nickName: return "NICK_NAME"
      case .organizationName: return "ORGANIZATION_NAME"
      case .postalCode: return "POSTAL_CODE"
      case .streetAddressLine1: return "STREET_ADDRESS_LINE1"
      case .streetAddressLine2: return "STREET_ADDRESS_LINE2"
      case .sublocality: return "SUBLOCALITY"
      case .telephoneNumber: return "TELEPHONE_NUMBER"
      case .username: return "USERNAME"
      case .password: return "PASSWORD"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: TextContentType, rhs: TextContentType) -> Bool {
    switch (lhs, rhs) {
      case (.none, .none): return true
      case (.url, .url): return true
      case (.addressCity, .addressCity): return true
      case (.addressCityState, .addressCityState): return true
      case (.addressState, .addressState): return true
      case (.countryName, .countryName): return true
      case (.creditCardNumber, .creditCardNumber): return true
      case (.emailAddress, .emailAddress): return true
      case (.familyName, .familyName): return true
      case (.fullStreetAddress, .fullStreetAddress): return true
      case (.givenName, .givenName): return true
      case (.jobTitle, .jobTitle): return true
      case (.location, .location): return true
      case (.middleName, .middleName): return true
      case (.name, .name): return true
      case (.namePrefix, .namePrefix): return true
      case (.nameSuffix, .nameSuffix): return true
      case (.nickName, .nickName): return true
      case (.organizationName, .organizationName): return true
      case (.postalCode, .postalCode): return true
      case (.streetAddressLine1, .streetAddressLine1): return true
      case (.streetAddressLine2, .streetAddressLine2): return true
      case (.sublocality, .sublocality): return true
      case (.telephoneNumber, .telephoneNumber): return true
      case (.username, .username): return true
      case (.password, .password): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [TextContentType] {
    return [
      .none,
      .url,
      .addressCity,
      .addressCityState,
      .addressState,
      .countryName,
      .creditCardNumber,
      .emailAddress,
      .familyName,
      .fullStreetAddress,
      .givenName,
      .jobTitle,
      .location,
      .middleName,
      .name,
      .namePrefix,
      .nameSuffix,
      .nickName,
      .organizationName,
      .postalCode,
      .streetAddressLine1,
      .streetAddressLine2,
      .sublocality,
      .telephoneNumber,
      .username,
      .password,
    ]
  }
}

public final class ActivePaymentMethodsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ActivePaymentMethods {
      activePaymentMethods {
        __typename
        storedPaymentMethodsDetails {
          __typename
          lastFourDigits
          holderName
          brand
        }
      }
    }
    """

  public let operationName: String = "ActivePaymentMethods"

  public let operationIdentifier: String? = "0e6c3cd5ec868c8d720f136c49e23dd68f54b420cd23674e33ef3f1733493d34"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("activePaymentMethods", type: .object(ActivePaymentMethod.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(activePaymentMethods: ActivePaymentMethod? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "activePaymentMethods": activePaymentMethods.flatMap { (value: ActivePaymentMethod) -> ResultMap in value.resultMap }])
    }

    /// Returns the active payment method which the member chose to tokenize
    public var activePaymentMethods: ActivePaymentMethod? {
      get {
        return (resultMap["activePaymentMethods"] as? ResultMap).flatMap { ActivePaymentMethod(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "activePaymentMethods")
      }
    }

    public struct ActivePaymentMethod: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ActivePaymentMethodsResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("storedPaymentMethodsDetails", type: .nonNull(.object(StoredPaymentMethodsDetail.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(storedPaymentMethodsDetails: StoredPaymentMethodsDetail) {
        self.init(unsafeResultMap: ["__typename": "ActivePaymentMethodsResponse", "storedPaymentMethodsDetails": storedPaymentMethodsDetails.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var storedPaymentMethodsDetails: StoredPaymentMethodsDetail {
        get {
          return StoredPaymentMethodsDetail(unsafeResultMap: resultMap["storedPaymentMethodsDetails"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "storedPaymentMethodsDetails")
        }
      }

      public struct StoredPaymentMethodsDetail: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["StoredPaymentMethodsDetails"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lastFourDigits", type: .nonNull(.scalar(String.self))),
          GraphQLField("holderName", type: .scalar(String.self)),
          GraphQLField("brand", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(lastFourDigits: String, holderName: String? = nil, brand: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "StoredPaymentMethodsDetails", "lastFourDigits": lastFourDigits, "holderName": holderName, "brand": brand])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var lastFourDigits: String {
          get {
            return resultMap["lastFourDigits"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "lastFourDigits")
          }
        }

        public var holderName: String? {
          get {
            return resultMap["holderName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "holderName")
          }
        }

        public var brand: String? {
          get {
            return resultMap["brand"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "brand")
          }
        }
      }
    }
  }
}

public final class AddReceiptMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddReceipt($id: ID!, $file: S3FileInput!) {
      addReceiptToKeyGearItem(input: {itemId: $id, file: $file}) {
        __typename
        receipts {
          __typename
          file {
            __typename
            preSignedUrl
          }
        }
      }
    }
    """

  public let operationName: String = "AddReceipt"

  public let operationIdentifier: String? = "94c12f1a83d33ac8bb0e0f3dc50cacaa941b6157a8f576109a87a933d3f30e73"

  public var id: GraphQLID
  public var file: S3FileInput

  public init(id: GraphQLID, file: S3FileInput) {
    self.id = id
    self.file = file
  }

  public var variables: GraphQLMap? {
    return ["id": id, "file": file]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addReceiptToKeyGearItem", arguments: ["input": ["itemId": GraphQLVariable("id"), "file": GraphQLVariable("file")]], type: .nonNull(.object(AddReceiptToKeyGearItem.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addReceiptToKeyGearItem: AddReceiptToKeyGearItem) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addReceiptToKeyGearItem": addReceiptToKeyGearItem.resultMap])
    }

    public var addReceiptToKeyGearItem: AddReceiptToKeyGearItem {
      get {
        return AddReceiptToKeyGearItem(unsafeResultMap: resultMap["addReceiptToKeyGearItem"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "addReceiptToKeyGearItem")
      }
    }

    public struct AddReceiptToKeyGearItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("receipts", type: .nonNull(.list(.nonNull(.object(Receipt.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(receipts: [Receipt]) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "receipts": receipts.map { (value: Receipt) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var receipts: [Receipt] {
        get {
          return (resultMap["receipts"] as! [ResultMap]).map { (value: ResultMap) -> Receipt in Receipt(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Receipt) -> ResultMap in value.resultMap }, forKey: "receipts")
        }
      }

      public struct Receipt: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemReceipt"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("file", type: .nonNull(.object(File.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(file: File) {
          self.init(unsafeResultMap: ["__typename": "KeyGearItemReceipt", "file": file.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var file: File {
          get {
            return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "file")
          }
        }

        public struct File: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["S3File"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("preSignedUrl", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(preSignedUrl: String) {
            self.init(unsafeResultMap: ["__typename": "S3File", "preSignedUrl": preSignedUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var preSignedUrl: String {
            get {
              return resultMap["preSignedUrl"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preSignedUrl")
            }
          }
        }
      }
    }
  }
}

public final class AdyenAdditionalPaymentDetailsMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AdyenAdditionalPaymentDetails($req: PaymentsDetailsRequest!) {
      submitAdditionalPaymentDetails(req: {paymentsDetailsRequest: $req}) {
        __typename
        ... on AdditionalPaymentsDetailsResponseFinished {
          resultCode
        }
        ... on AdditionalPaymentsDetailsResponseAction {
          action
        }
      }
    }
    """

  public let operationName: String = "AdyenAdditionalPaymentDetails"

  public let operationIdentifier: String? = "d3838aa974f0ec516efe3780406f0f15640a2e0a024a461485506366ec98b705"

  public var req: String

  public init(req: String) {
    self.req = req
  }

  public var variables: GraphQLMap? {
    return ["req": req]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("submitAdditionalPaymentDetails", arguments: ["req": ["paymentsDetailsRequest": GraphQLVariable("req")]], type: .nonNull(.object(SubmitAdditionalPaymentDetail.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(submitAdditionalPaymentDetails: SubmitAdditionalPaymentDetail) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "submitAdditionalPaymentDetails": submitAdditionalPaymentDetails.resultMap])
    }

    /// Submite additional payment details
    public var submitAdditionalPaymentDetails: SubmitAdditionalPaymentDetail {
      get {
        return SubmitAdditionalPaymentDetail(unsafeResultMap: resultMap["submitAdditionalPaymentDetails"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "submitAdditionalPaymentDetails")
      }
    }

    public struct SubmitAdditionalPaymentDetail: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AdditionalPaymentsDetailsResponseFinished", "AdditionalPaymentsDetailsResponseAction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["AdditionalPaymentsDetailsResponseFinished": AsAdditionalPaymentsDetailsResponseFinished.selections, "AdditionalPaymentsDetailsResponseAction": AsAdditionalPaymentsDetailsResponseAction.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeAdditionalPaymentsDetailsResponseFinished(resultCode: String) -> SubmitAdditionalPaymentDetail {
        return SubmitAdditionalPaymentDetail(unsafeResultMap: ["__typename": "AdditionalPaymentsDetailsResponseFinished", "resultCode": resultCode])
      }

      public static func makeAdditionalPaymentsDetailsResponseAction(action: String) -> SubmitAdditionalPaymentDetail {
        return SubmitAdditionalPaymentDetail(unsafeResultMap: ["__typename": "AdditionalPaymentsDetailsResponseAction", "action": action])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asAdditionalPaymentsDetailsResponseFinished: AsAdditionalPaymentsDetailsResponseFinished? {
        get {
          if !AsAdditionalPaymentsDetailsResponseFinished.possibleTypes.contains(__typename) { return nil }
          return AsAdditionalPaymentsDetailsResponseFinished(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsAdditionalPaymentsDetailsResponseFinished: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["AdditionalPaymentsDetailsResponseFinished"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("resultCode", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(resultCode: String) {
          self.init(unsafeResultMap: ["__typename": "AdditionalPaymentsDetailsResponseFinished", "resultCode": resultCode])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var resultCode: String {
          get {
            return resultMap["resultCode"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "resultCode")
          }
        }
      }

      public var asAdditionalPaymentsDetailsResponseAction: AsAdditionalPaymentsDetailsResponseAction? {
        get {
          if !AsAdditionalPaymentsDetailsResponseAction.possibleTypes.contains(__typename) { return nil }
          return AsAdditionalPaymentsDetailsResponseAction(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsAdditionalPaymentsDetailsResponseAction: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["AdditionalPaymentsDetailsResponseAction"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("action", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(action: String) {
          self.init(unsafeResultMap: ["__typename": "AdditionalPaymentsDetailsResponseAction", "action": action])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var action: String {
          get {
            return resultMap["action"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "action")
          }
        }
      }
    }
  }
}

public final class AdyenAvailableMethodsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query AdyenAvailableMethods {
      availablePaymentMethods {
        __typename
        paymentMethodsResponse
      }
      adyenPublicKey
      insuranceCost {
        __typename
        ...CostFragment
      }
    }
    """

  public let operationName: String = "AdyenAvailableMethods"

  public let operationIdentifier: String? = "cc9df09f4960021eba91de9b6ffbdc9a349ddd493f939e64748ca27649c48dc8"

  public var queryDocument: String { return operationDefinition.appending(CostFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("availablePaymentMethods", type: .nonNull(.object(AvailablePaymentMethod.selections))),
      GraphQLField("adyenPublicKey", type: .nonNull(.scalar(String.self))),
      GraphQLField("insuranceCost", type: .object(InsuranceCost.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(availablePaymentMethods: AvailablePaymentMethod, adyenPublicKey: String, insuranceCost: InsuranceCost? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "availablePaymentMethods": availablePaymentMethods.resultMap, "adyenPublicKey": adyenPublicKey, "insuranceCost": insuranceCost.flatMap { (value: InsuranceCost) -> ResultMap in value.resultMap }])
    }

    /// Returns all the available payments methods before the client requests a tokenization
    public var availablePaymentMethods: AvailablePaymentMethod {
      get {
        return AvailablePaymentMethod(unsafeResultMap: resultMap["availablePaymentMethods"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "availablePaymentMethods")
      }
    }

    public var adyenPublicKey: String {
      get {
        return resultMap["adyenPublicKey"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "adyenPublicKey")
      }
    }

    /// Returns the aggregated insurance cost of a member's PENDING, ACTIVE or ACTIVE_IN_FUTURE current agreements
    public var insuranceCost: InsuranceCost? {
      get {
        return (resultMap["insuranceCost"] as? ResultMap).flatMap { InsuranceCost(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "insuranceCost")
      }
    }

    public struct AvailablePaymentMethod: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AvailablePaymentMethodsResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("paymentMethodsResponse", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(paymentMethodsResponse: String) {
        self.init(unsafeResultMap: ["__typename": "AvailablePaymentMethodsResponse", "paymentMethodsResponse": paymentMethodsResponse])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var paymentMethodsResponse: String {
        get {
          return resultMap["paymentMethodsResponse"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "paymentMethodsResponse")
        }
      }
    }

    public struct InsuranceCost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["InsuranceCost"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("freeUntil", type: .scalar(String.self)),
        GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
        GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
        GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
        self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var freeUntil: String? {
        get {
          return resultMap["freeUntil"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "freeUntil")
        }
      }

      public var monthlyDiscount: MonthlyDiscount {
        get {
          return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
        }
      }

      public var monthlyGross: MonthlyGross {
        get {
          return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
        }
      }

      public var monthlyNet: MonthlyNet {
        get {
          return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var costFragment: CostFragment {
          get {
            return CostFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct MonthlyDiscount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyGross: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyNet: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }
    }
  }
}

public final class AdyenTokenizePaymentDetailsMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AdyenTokenizePaymentDetails($request: TokenizationRequest!) {
      tokenizePaymentDetails(req: $request) {
        __typename
        ... on TokenizationResponseFinished {
          resultCode
        }
        ... on TokenizationResponseAction {
          action
        }
      }
    }
    """

  public let operationName: String = "AdyenTokenizePaymentDetails"

  public let operationIdentifier: String? = "2a64c2f8a9d9fd353572f0b82087df9fa62cea2c3294bf5949d9ea86a9901f8c"

  public var request: TokenizationRequest

  public init(request: TokenizationRequest) {
    self.request = request
  }

  public var variables: GraphQLMap? {
    return ["request": request]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("tokenizePaymentDetails", arguments: ["req": GraphQLVariable("request")], type: .object(TokenizePaymentDetail.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(tokenizePaymentDetails: TokenizePaymentDetail? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "tokenizePaymentDetails": tokenizePaymentDetails.flatMap { (value: TokenizePaymentDetail) -> ResultMap in value.resultMap }])
    }

    /// Tokenize payment details per member in order to be used in future and returns the status
    public var tokenizePaymentDetails: TokenizePaymentDetail? {
      get {
        return (resultMap["tokenizePaymentDetails"] as? ResultMap).flatMap { TokenizePaymentDetail(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "tokenizePaymentDetails")
      }
    }

    public struct TokenizePaymentDetail: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["TokenizationResponseFinished", "TokenizationResponseAction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["TokenizationResponseFinished": AsTokenizationResponseFinished.selections, "TokenizationResponseAction": AsTokenizationResponseAction.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeTokenizationResponseFinished(resultCode: String) -> TokenizePaymentDetail {
        return TokenizePaymentDetail(unsafeResultMap: ["__typename": "TokenizationResponseFinished", "resultCode": resultCode])
      }

      public static func makeTokenizationResponseAction(action: String) -> TokenizePaymentDetail {
        return TokenizePaymentDetail(unsafeResultMap: ["__typename": "TokenizationResponseAction", "action": action])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asTokenizationResponseFinished: AsTokenizationResponseFinished? {
        get {
          if !AsTokenizationResponseFinished.possibleTypes.contains(__typename) { return nil }
          return AsTokenizationResponseFinished(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsTokenizationResponseFinished: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["TokenizationResponseFinished"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("resultCode", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(resultCode: String) {
          self.init(unsafeResultMap: ["__typename": "TokenizationResponseFinished", "resultCode": resultCode])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var resultCode: String {
          get {
            return resultMap["resultCode"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "resultCode")
          }
        }
      }

      public var asTokenizationResponseAction: AsTokenizationResponseAction? {
        get {
          if !AsTokenizationResponseAction.possibleTypes.contains(__typename) { return nil }
          return AsTokenizationResponseAction(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsTokenizationResponseAction: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["TokenizationResponseAction"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("action", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(action: String) {
          self.init(unsafeResultMap: ["__typename": "TokenizationResponseAction", "action": action])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var action: String {
          get {
            return resultMap["action"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "action")
          }
        }
      }
    }
  }
}

public final class BankIdAuthMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation BankIDAuth {
      bankIdAuth {
        __typename
        autoStartToken
      }
    }
    """

  public let operationName: String = "BankIDAuth"

  public let operationIdentifier: String? = "628d9ff9d94781b2193629262e684ef9b1fad5c49b693eadf31f3464b5eb20a1"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("bankIdAuth", type: .nonNull(.object(BankIdAuth.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(bankIdAuth: BankIdAuth) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "bankIdAuth": bankIdAuth.resultMap])
    }

    @available(*, deprecated, message: "Use `swedishBankIdAuth`.")
    public var bankIdAuth: BankIdAuth {
      get {
        return BankIdAuth(unsafeResultMap: resultMap["bankIdAuth"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "bankIdAuth")
      }
    }

    public struct BankIdAuth: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["BankIdAuthResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("autoStartToken", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(autoStartToken: String) {
        self.init(unsafeResultMap: ["__typename": "BankIdAuthResponse", "autoStartToken": autoStartToken])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var autoStartToken: String {
        get {
          return resultMap["autoStartToken"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "autoStartToken")
        }
      }
    }
  }
}

public final class BankIdAuthSubscriptionSubscription: GraphQLSubscription {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    subscription BankIDAuthSubscription {
      authStatus {
        __typename
        status
      }
    }
    """

  public let operationName: String = "BankIDAuthSubscription"

  public let operationIdentifier: String? = "0315727d26b5a53766b1bb079cdda143732d284ea480495b69485f95cd691485"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("authStatus", type: .object(AuthStatus.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(authStatus: AuthStatus? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "authStatus": authStatus.flatMap { (value: AuthStatus) -> ResultMap in value.resultMap }])
    }

    public var authStatus: AuthStatus? {
      get {
        return (resultMap["authStatus"] as? ResultMap).flatMap { AuthStatus(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "authStatus")
      }
    }

    public struct AuthStatus: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AuthEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("status", type: .scalar(AuthState.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(status: AuthState? = nil) {
        self.init(unsafeResultMap: ["__typename": "AuthEvent", "status": status])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var status: AuthState? {
        get {
          return resultMap["status"] as? AuthState
        }
        set {
          resultMap.updateValue(newValue, forKey: "status")
        }
      }
    }
  }
}

public final class BankIdNorwayAuthMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation BankIDNorwayAuth {
      norwegianBankIdAuth {
        __typename
        redirectUrl
      }
    }
    """

  public let operationName: String = "BankIDNorwayAuth"

  public let operationIdentifier: String? = "791eff89881eda9be4e03c102ca24f0ef31b4854f4d76359cbb6bfd7ab491931"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("norwegianBankIdAuth", type: .nonNull(.object(NorwegianBankIdAuth.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(norwegianBankIdAuth: NorwegianBankIdAuth) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "norwegianBankIdAuth": norwegianBankIdAuth.resultMap])
    }

    public var norwegianBankIdAuth: NorwegianBankIdAuth {
      get {
        return NorwegianBankIdAuth(unsafeResultMap: resultMap["norwegianBankIdAuth"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "norwegianBankIdAuth")
      }
    }

    public struct NorwegianBankIdAuth: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["NorwegianBankIdAuthResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("redirectUrl", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(redirectUrl: String) {
        self.init(unsafeResultMap: ["__typename": "NorwegianBankIdAuthResponse", "redirectUrl": redirectUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var redirectUrl: String {
        get {
          return resultMap["redirectUrl"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "redirectUrl")
        }
      }
    }
  }
}

public final class CancelDirectDebitRequestMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CancelDirectDebitRequest {
      cancelDirectDebitRequest
    }
    """

  public let operationName: String = "CancelDirectDebitRequest"

  public let operationIdentifier: String? = "0fa92aa575f64383b727b31801154c1adc1f9ae401587ab33a1609477872e479"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("cancelDirectDebitRequest", type: .nonNull(.scalar(CancelDirectDebitStatus.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(cancelDirectDebitRequest: CancelDirectDebitStatus) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "cancelDirectDebitRequest": cancelDirectDebitRequest])
    }

    public var cancelDirectDebitRequest: CancelDirectDebitStatus {
      get {
        return resultMap["cancelDirectDebitRequest"]! as! CancelDirectDebitStatus
      }
      set {
        resultMap.updateValue(newValue, forKey: "cancelDirectDebitRequest")
      }
    }
  }
}

public final class ChangeStartDateMutationMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation ChangeStartDateMutation($id: ID!, $startDate: LocalDate!) {
      editQuote(input: {id: $id, startDate: $startDate}) {
        __typename
        ... on CompleteQuote {
          id
          startDate
        }
      }
    }
    """

  public let operationName: String = "ChangeStartDateMutation"

  public let operationIdentifier: String? = "56e8225357b9930a4996670a4e14c62237b30aea2b3e58bd785841e73279df1e"

  public var id: GraphQLID
  public var startDate: String

  public init(id: GraphQLID, startDate: String) {
    self.id = id
    self.startDate = startDate
  }

  public var variables: GraphQLMap? {
    return ["id": id, "startDate": startDate]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("editQuote", arguments: ["input": ["id": GraphQLVariable("id"), "startDate": GraphQLVariable("startDate")]], type: .nonNull(.object(EditQuote.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(editQuote: EditQuote) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "editQuote": editQuote.resultMap])
    }

    public var editQuote: EditQuote {
      get {
        return EditQuote(unsafeResultMap: resultMap["editQuote"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "editQuote")
      }
    }

    public struct EditQuote: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CompleteQuote", "UnderwritingLimitsHit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["CompleteQuote": AsCompleteQuote.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeUnderwritingLimitsHit() -> EditQuote {
        return EditQuote(unsafeResultMap: ["__typename": "UnderwritingLimitsHit"])
      }

      public static func makeCompleteQuote(id: GraphQLID, startDate: String? = nil) -> EditQuote {
        return EditQuote(unsafeResultMap: ["__typename": "CompleteQuote", "id": id, "startDate": startDate])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asCompleteQuote: AsCompleteQuote? {
        get {
          if !AsCompleteQuote.possibleTypes.contains(__typename) { return nil }
          return AsCompleteQuote(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsCompleteQuote: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CompleteQuote"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("startDate", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, startDate: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "CompleteQuote", "id": id, "startDate": startDate])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var startDate: String? {
          get {
            return resultMap["startDate"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startDate")
          }
        }
      }
    }
  }
}

public final class CharityOptionsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query CharityOptions {
      cashbackOptions {
        __typename
        id
        name
        title
        imageUrl
        description
        paragraph
      }
    }
    """

  public let operationName: String = "CharityOptions"

  public let operationIdentifier: String? = "966cad0242b329f620ba164a2660bab4073ae6809ffdde3e27bcefdf20e66020"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("cashbackOptions", type: .nonNull(.list(.object(CashbackOption.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(cashbackOptions: [CashbackOption?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "cashbackOptions": cashbackOptions.map { (value: CashbackOption?) -> ResultMap? in value.flatMap { (value: CashbackOption) -> ResultMap in value.resultMap } }])
    }

    public var cashbackOptions: [CashbackOption?] {
      get {
        return (resultMap["cashbackOptions"] as! [ResultMap?]).map { (value: ResultMap?) -> CashbackOption? in value.flatMap { (value: ResultMap) -> CashbackOption in CashbackOption(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: CashbackOption?) -> ResultMap? in value.flatMap { (value: CashbackOption) -> ResultMap in value.resultMap } }, forKey: "cashbackOptions")
      }
    }

    public struct CashbackOption: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Cashback"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(GraphQLID.self)),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("title", type: .scalar(String.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("paragraph", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, name: String? = nil, title: String? = nil, imageUrl: String? = nil, description: String? = nil, paragraph: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Cashback", "id": id, "name": name, "title": title, "imageUrl": imageUrl, "description": description, "paragraph": paragraph])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var title: String? {
        get {
          return resultMap["title"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public var imageUrl: String? {
        get {
          return resultMap["imageUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var description: String? {
        get {
          return resultMap["description"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "description")
        }
      }

      public var paragraph: String? {
        get {
          return resultMap["paragraph"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "paragraph")
        }
      }
    }
  }
}

public final class ChatMessagesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ChatMessages {
      messages {
        __typename
        ...MessageData
      }
    }
    """

  public let operationName: String = "ChatMessages"

  public let operationIdentifier: String? = "c5f3cff3ba53e0a4ba5b085398da6265457d46534ca1ba5142ff615faf18cd0a"

  public var queryDocument: String { return operationDefinition.appending(MessageData.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("messages", type: .nonNull(.list(.object(Message.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(messages: [Message?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "messages": messages.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } }])
    }

    public var messages: [Message?] {
      get {
        return (resultMap["messages"] as! [ResultMap?]).map { (value: ResultMap?) -> Message? in value.flatMap { (value: ResultMap) -> Message in Message(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } }, forKey: "messages")
      }
    }

    public struct Message: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Message"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .nonNull(.object(Body.selections))),
        GraphQLField("header", type: .nonNull(.object(Header.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(globalId: GraphQLID, id: GraphQLID, body: Body, header: Header) {
        self.init(unsafeResultMap: ["__typename": "Message", "globalId": globalId, "id": id, "body": body.resultMap, "header": header.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var globalId: GraphQLID {
        get {
          return resultMap["globalId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "globalId")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var body: Body {
        get {
          return Body(unsafeResultMap: resultMap["body"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "body")
        }
      }

      public var header: Header {
        get {
          return Header(unsafeResultMap: resultMap["header"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "header")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var messageData: MessageData {
          get {
            return MessageData(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Body: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["MessageBodySingleSelect": AsMessageBodySingleSelect.selections, "MessageBodyMultipleSelect": AsMessageBodyMultipleSelect.selections, "MessageBodyText": AsMessageBodyText.selections, "MessageBodyNumber": AsMessageBodyNumber.selections, "MessageBodyAudio": AsMessageBodyAudio.selections, "MessageBodyBankIdCollect": AsMessageBodyBankIdCollect.selections, "MessageBodyFile": AsMessageBodyFile.selections, "MessageBodyParagraph": AsMessageBodyParagraph.selections, "MessageBodyUndefined": AsMessageBodyUndefined.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodySingleSelect(type: String, id: GraphQLID, text: String, choices: [AsMessageBodySingleSelect.Choice?]? = nil) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "type": type, "id": id, "text": text, "choices": choices.flatMap { (value: [AsMessageBodySingleSelect.Choice?]) -> [ResultMap?] in value.map { (value: AsMessageBodySingleSelect.Choice?) -> ResultMap? in value.flatMap { (value: AsMessageBodySingleSelect.Choice) -> ResultMap in value.resultMap } } }])
        }

        public static func makeMessageBodyMultipleSelect(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyText(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyText", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
        }

        public static func makeMessageBodyNumber(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyNumber", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
        }

        public static func makeMessageBodyAudio(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyAudio", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyBankIdCollect(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyFile(type: String, id: GraphQLID, text: String, mimeType: String? = nil, file: AsMessageBodyFile.File) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyFile", "type": type, "id": id, "text": text, "mimeType": mimeType, "file": file.resultMap])
        }

        public static func makeMessageBodyParagraph(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyUndefined(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined", "type": type, "id": id, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asMessageBodySingleSelect: AsMessageBodySingleSelect? {
          get {
            if !AsMessageBodySingleSelect.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodySingleSelect(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodySingleSelect: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodySingleSelect"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("choices", type: .list(.object(Choice.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, choices: [Choice?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "type": type, "id": id, "text": text, "choices": choices.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var choices: [Choice?]? {
            get {
              return (resultMap["choices"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Choice?] in value.map { (value: ResultMap?) -> Choice? in value.flatMap { (value: ResultMap) -> Choice in Choice(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }, forKey: "choices")
            }
          }

          public struct Choice: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MessageBodyChoicesUndefined", "MessageBodyChoicesSelection", "MessageBodyChoicesLink"]

            public static let selections: [GraphQLSelection] = [
              GraphQLTypeCase(
                variants: ["MessageBodyChoicesSelection": AsMessageBodyChoicesSelection.selections, "MessageBodyChoicesLink": AsMessageBodyChoicesLink.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeMessageBodyChoicesUndefined() -> Choice {
              return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesUndefined"])
            }

            public static func makeMessageBodyChoicesSelection(text: String, value: String) -> Choice {
              return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "text": text, "value": value])
            }

            public static func makeMessageBodyChoicesLink(view: MessageBodyChoicesLinkView? = nil, text: String, value: String) -> Choice {
              return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "view": view, "text": text, "value": value])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var asMessageBodyChoicesSelection: AsMessageBodyChoicesSelection? {
              get {
                if !AsMessageBodyChoicesSelection.possibleTypes.contains(__typename) { return nil }
                return AsMessageBodyChoicesSelection(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMessageBodyChoicesSelection: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MessageBodyChoicesSelection"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("text", type: .nonNull(.scalar(String.self))),
                GraphQLField("value", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(text: String, value: String) {
                self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "text": text, "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var text: String {
                get {
                  return resultMap["text"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var value: String {
                get {
                  return resultMap["value"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }

            public var asMessageBodyChoicesLink: AsMessageBodyChoicesLink? {
              get {
                if !AsMessageBodyChoicesLink.possibleTypes.contains(__typename) { return nil }
                return AsMessageBodyChoicesLink(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMessageBodyChoicesLink: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MessageBodyChoicesLink"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("view", type: .scalar(MessageBodyChoicesLinkView.self)),
                GraphQLField("text", type: .nonNull(.scalar(String.self))),
                GraphQLField("value", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(view: MessageBodyChoicesLinkView? = nil, text: String, value: String) {
                self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "view": view, "text": text, "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var view: MessageBodyChoicesLinkView? {
                get {
                  return resultMap["view"] as? MessageBodyChoicesLinkView
                }
                set {
                  resultMap.updateValue(newValue, forKey: "view")
                }
              }

              public var text: String {
                get {
                  return resultMap["text"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var value: String {
                get {
                  return resultMap["value"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }
        }

        public var asMessageBodyMultipleSelect: AsMessageBodyMultipleSelect? {
          get {
            if !AsMessageBodyMultipleSelect.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyMultipleSelect(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyMultipleSelect: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyMultipleSelect"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyText: AsMessageBodyText? {
          get {
            if !AsMessageBodyText.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyText(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyText: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyText"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("placeholder", type: .scalar(String.self)),
            GraphQLField("keyboard", type: .scalar(KeyboardType.self)),
            GraphQLField("textContentType", type: .scalar(TextContentType.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyText", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var placeholder: String? {
            get {
              return resultMap["placeholder"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "placeholder")
            }
          }

          public var keyboard: KeyboardType? {
            get {
              return resultMap["keyboard"] as? KeyboardType
            }
            set {
              resultMap.updateValue(newValue, forKey: "keyboard")
            }
          }

          public var textContentType: TextContentType? {
            get {
              return resultMap["textContentType"] as? TextContentType
            }
            set {
              resultMap.updateValue(newValue, forKey: "textContentType")
            }
          }
        }

        public var asMessageBodyNumber: AsMessageBodyNumber? {
          get {
            if !AsMessageBodyNumber.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyNumber(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyNumber: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyNumber"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("placeholder", type: .scalar(String.self)),
            GraphQLField("keyboard", type: .scalar(KeyboardType.self)),
            GraphQLField("textContentType", type: .scalar(TextContentType.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyNumber", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var placeholder: String? {
            get {
              return resultMap["placeholder"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "placeholder")
            }
          }

          public var keyboard: KeyboardType? {
            get {
              return resultMap["keyboard"] as? KeyboardType
            }
            set {
              resultMap.updateValue(newValue, forKey: "keyboard")
            }
          }

          public var textContentType: TextContentType? {
            get {
              return resultMap["textContentType"] as? TextContentType
            }
            set {
              resultMap.updateValue(newValue, forKey: "textContentType")
            }
          }
        }

        public var asMessageBodyAudio: AsMessageBodyAudio? {
          get {
            if !AsMessageBodyAudio.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyAudio(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyAudio: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyAudio"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyAudio", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyBankIdCollect: AsMessageBodyBankIdCollect? {
          get {
            if !AsMessageBodyBankIdCollect.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyBankIdCollect(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyBankIdCollect: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyBankIdCollect"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyFile: AsMessageBodyFile? {
          get {
            if !AsMessageBodyFile.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyFile(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyFile: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyFile"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("mimeType", type: .scalar(String.self)),
            GraphQLField("file", type: .nonNull(.object(File.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, mimeType: String? = nil, file: File) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyFile", "type": type, "id": id, "text": text, "mimeType": mimeType, "file": file.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var mimeType: String? {
            get {
              return resultMap["mimeType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "mimeType")
            }
          }

          public var file: File {
            get {
              return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "file")
            }
          }

          public struct File: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["File"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("signedUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(signedUrl: String) {
              self.init(unsafeResultMap: ["__typename": "File", "signedUrl": signedUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// signedUrl is valid for 30 minutes after upload, don't hang on to this.
            public var signedUrl: String {
              get {
                return resultMap["signedUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "signedUrl")
              }
            }
          }
        }

        public var asMessageBodyParagraph: AsMessageBodyParagraph? {
          get {
            if !AsMessageBodyParagraph.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyParagraph(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyParagraph: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyParagraph"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyParagraph", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyUndefined: AsMessageBodyUndefined? {
          get {
            if !AsMessageBodyUndefined.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyUndefined(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyUndefined: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyUndefined"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyUndefined", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }
      }

      public struct Header: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageHeader"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("messageId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("fromMyself", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("timeStamp", type: .nonNull(.scalar(String.self))),
          GraphQLField("richTextChatCompatible", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("editAllowed", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("shouldRequestPushNotifications", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("pollingInterval", type: .nonNull(.scalar(Int.self))),
          GraphQLField("loadingIndicator", type: .scalar(String.self)),
          GraphQLField("statusMessage", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(messageId: GraphQLID, fromMyself: Bool, timeStamp: String, richTextChatCompatible: Bool, editAllowed: Bool, shouldRequestPushNotifications: Bool, pollingInterval: Int, loadingIndicator: String? = nil, statusMessage: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "MessageHeader", "messageId": messageId, "fromMyself": fromMyself, "timeStamp": timeStamp, "richTextChatCompatible": richTextChatCompatible, "editAllowed": editAllowed, "shouldRequestPushNotifications": shouldRequestPushNotifications, "pollingInterval": pollingInterval, "loadingIndicator": loadingIndicator, "statusMessage": statusMessage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var messageId: GraphQLID {
          get {
            return resultMap["messageId"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "messageId")
          }
        }

        public var fromMyself: Bool {
          get {
            return resultMap["fromMyself"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "fromMyself")
          }
        }

        public var timeStamp: String {
          get {
            return resultMap["timeStamp"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "timeStamp")
          }
        }

        public var richTextChatCompatible: Bool {
          get {
            return resultMap["richTextChatCompatible"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "richTextChatCompatible")
          }
        }

        public var editAllowed: Bool {
          get {
            return resultMap["editAllowed"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "editAllowed")
          }
        }

        public var shouldRequestPushNotifications: Bool {
          get {
            return resultMap["shouldRequestPushNotifications"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "shouldRequestPushNotifications")
          }
        }

        public var pollingInterval: Int {
          get {
            return resultMap["pollingInterval"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "pollingInterval")
          }
        }

        public var loadingIndicator: String? {
          get {
            return resultMap["loadingIndicator"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "loadingIndicator")
          }
        }

        public var statusMessage: String? {
          get {
            return resultMap["statusMessage"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "statusMessage")
          }
        }
      }
    }
  }
}

public final class ChatMessagesSubscriptionSubscription: GraphQLSubscription {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    subscription ChatMessagesSubscription {
      message {
        __typename
        ...MessageData
      }
    }
    """

  public let operationName: String = "ChatMessagesSubscription"

  public let operationIdentifier: String? = "1b918242e11a676481d04f670338ef12f698ccf5406c4d2e7262dfcb741c1581"

  public var queryDocument: String { return operationDefinition.appending(MessageData.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("message", type: .nonNull(.object(Message.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(message: Message) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "message": message.resultMap])
    }

    public var message: Message {
      get {
        return Message(unsafeResultMap: resultMap["message"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "message")
      }
    }

    public struct Message: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Message"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .nonNull(.object(Body.selections))),
        GraphQLField("header", type: .nonNull(.object(Header.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(globalId: GraphQLID, id: GraphQLID, body: Body, header: Header) {
        self.init(unsafeResultMap: ["__typename": "Message", "globalId": globalId, "id": id, "body": body.resultMap, "header": header.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var globalId: GraphQLID {
        get {
          return resultMap["globalId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "globalId")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var body: Body {
        get {
          return Body(unsafeResultMap: resultMap["body"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "body")
        }
      }

      public var header: Header {
        get {
          return Header(unsafeResultMap: resultMap["header"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "header")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var messageData: MessageData {
          get {
            return MessageData(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Body: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["MessageBodySingleSelect": AsMessageBodySingleSelect.selections, "MessageBodyMultipleSelect": AsMessageBodyMultipleSelect.selections, "MessageBodyText": AsMessageBodyText.selections, "MessageBodyNumber": AsMessageBodyNumber.selections, "MessageBodyAudio": AsMessageBodyAudio.selections, "MessageBodyBankIdCollect": AsMessageBodyBankIdCollect.selections, "MessageBodyFile": AsMessageBodyFile.selections, "MessageBodyParagraph": AsMessageBodyParagraph.selections, "MessageBodyUndefined": AsMessageBodyUndefined.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodySingleSelect(type: String, id: GraphQLID, text: String, choices: [AsMessageBodySingleSelect.Choice?]? = nil) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "type": type, "id": id, "text": text, "choices": choices.flatMap { (value: [AsMessageBodySingleSelect.Choice?]) -> [ResultMap?] in value.map { (value: AsMessageBodySingleSelect.Choice?) -> ResultMap? in value.flatMap { (value: AsMessageBodySingleSelect.Choice) -> ResultMap in value.resultMap } } }])
        }

        public static func makeMessageBodyMultipleSelect(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyText(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyText", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
        }

        public static func makeMessageBodyNumber(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyNumber", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
        }

        public static func makeMessageBodyAudio(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyAudio", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyBankIdCollect(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyFile(type: String, id: GraphQLID, text: String, mimeType: String? = nil, file: AsMessageBodyFile.File) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyFile", "type": type, "id": id, "text": text, "mimeType": mimeType, "file": file.resultMap])
        }

        public static func makeMessageBodyParagraph(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph", "type": type, "id": id, "text": text])
        }

        public static func makeMessageBodyUndefined(type: String, id: GraphQLID, text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined", "type": type, "id": id, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asMessageBodySingleSelect: AsMessageBodySingleSelect? {
          get {
            if !AsMessageBodySingleSelect.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodySingleSelect(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodySingleSelect: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodySingleSelect"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("choices", type: .list(.object(Choice.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, choices: [Choice?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "type": type, "id": id, "text": text, "choices": choices.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var choices: [Choice?]? {
            get {
              return (resultMap["choices"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Choice?] in value.map { (value: ResultMap?) -> Choice? in value.flatMap { (value: ResultMap) -> Choice in Choice(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }, forKey: "choices")
            }
          }

          public struct Choice: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MessageBodyChoicesUndefined", "MessageBodyChoicesSelection", "MessageBodyChoicesLink"]

            public static let selections: [GraphQLSelection] = [
              GraphQLTypeCase(
                variants: ["MessageBodyChoicesSelection": AsMessageBodyChoicesSelection.selections, "MessageBodyChoicesLink": AsMessageBodyChoicesLink.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeMessageBodyChoicesUndefined() -> Choice {
              return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesUndefined"])
            }

            public static func makeMessageBodyChoicesSelection(text: String, value: String) -> Choice {
              return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "text": text, "value": value])
            }

            public static func makeMessageBodyChoicesLink(view: MessageBodyChoicesLinkView? = nil, text: String, value: String) -> Choice {
              return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "view": view, "text": text, "value": value])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var asMessageBodyChoicesSelection: AsMessageBodyChoicesSelection? {
              get {
                if !AsMessageBodyChoicesSelection.possibleTypes.contains(__typename) { return nil }
                return AsMessageBodyChoicesSelection(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMessageBodyChoicesSelection: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MessageBodyChoicesSelection"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("text", type: .nonNull(.scalar(String.self))),
                GraphQLField("value", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(text: String, value: String) {
                self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "text": text, "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var text: String {
                get {
                  return resultMap["text"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var value: String {
                get {
                  return resultMap["value"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }

            public var asMessageBodyChoicesLink: AsMessageBodyChoicesLink? {
              get {
                if !AsMessageBodyChoicesLink.possibleTypes.contains(__typename) { return nil }
                return AsMessageBodyChoicesLink(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMessageBodyChoicesLink: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MessageBodyChoicesLink"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("view", type: .scalar(MessageBodyChoicesLinkView.self)),
                GraphQLField("text", type: .nonNull(.scalar(String.self))),
                GraphQLField("value", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(view: MessageBodyChoicesLinkView? = nil, text: String, value: String) {
                self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "view": view, "text": text, "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var view: MessageBodyChoicesLinkView? {
                get {
                  return resultMap["view"] as? MessageBodyChoicesLinkView
                }
                set {
                  resultMap.updateValue(newValue, forKey: "view")
                }
              }

              public var text: String {
                get {
                  return resultMap["text"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var value: String {
                get {
                  return resultMap["value"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }
        }

        public var asMessageBodyMultipleSelect: AsMessageBodyMultipleSelect? {
          get {
            if !AsMessageBodyMultipleSelect.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyMultipleSelect(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyMultipleSelect: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyMultipleSelect"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyText: AsMessageBodyText? {
          get {
            if !AsMessageBodyText.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyText(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyText: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyText"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("placeholder", type: .scalar(String.self)),
            GraphQLField("keyboard", type: .scalar(KeyboardType.self)),
            GraphQLField("textContentType", type: .scalar(TextContentType.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyText", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var placeholder: String? {
            get {
              return resultMap["placeholder"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "placeholder")
            }
          }

          public var keyboard: KeyboardType? {
            get {
              return resultMap["keyboard"] as? KeyboardType
            }
            set {
              resultMap.updateValue(newValue, forKey: "keyboard")
            }
          }

          public var textContentType: TextContentType? {
            get {
              return resultMap["textContentType"] as? TextContentType
            }
            set {
              resultMap.updateValue(newValue, forKey: "textContentType")
            }
          }
        }

        public var asMessageBodyNumber: AsMessageBodyNumber? {
          get {
            if !AsMessageBodyNumber.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyNumber(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyNumber: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyNumber"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("placeholder", type: .scalar(String.self)),
            GraphQLField("keyboard", type: .scalar(KeyboardType.self)),
            GraphQLField("textContentType", type: .scalar(TextContentType.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyNumber", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var placeholder: String? {
            get {
              return resultMap["placeholder"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "placeholder")
            }
          }

          public var keyboard: KeyboardType? {
            get {
              return resultMap["keyboard"] as? KeyboardType
            }
            set {
              resultMap.updateValue(newValue, forKey: "keyboard")
            }
          }

          public var textContentType: TextContentType? {
            get {
              return resultMap["textContentType"] as? TextContentType
            }
            set {
              resultMap.updateValue(newValue, forKey: "textContentType")
            }
          }
        }

        public var asMessageBodyAudio: AsMessageBodyAudio? {
          get {
            if !AsMessageBodyAudio.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyAudio(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyAudio: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyAudio"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyAudio", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyBankIdCollect: AsMessageBodyBankIdCollect? {
          get {
            if !AsMessageBodyBankIdCollect.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyBankIdCollect(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyBankIdCollect: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyBankIdCollect"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyFile: AsMessageBodyFile? {
          get {
            if !AsMessageBodyFile.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyFile(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyFile: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyFile"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("mimeType", type: .scalar(String.self)),
            GraphQLField("file", type: .nonNull(.object(File.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String, mimeType: String? = nil, file: File) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyFile", "type": type, "id": id, "text": text, "mimeType": mimeType, "file": file.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var mimeType: String? {
            get {
              return resultMap["mimeType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "mimeType")
            }
          }

          public var file: File {
            get {
              return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "file")
            }
          }

          public struct File: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["File"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("signedUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(signedUrl: String) {
              self.init(unsafeResultMap: ["__typename": "File", "signedUrl": signedUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// signedUrl is valid for 30 minutes after upload, don't hang on to this.
            public var signedUrl: String {
              get {
                return resultMap["signedUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "signedUrl")
              }
            }
          }
        }

        public var asMessageBodyParagraph: AsMessageBodyParagraph? {
          get {
            if !AsMessageBodyParagraph.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyParagraph(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyParagraph: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyParagraph"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyParagraph", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public var asMessageBodyUndefined: AsMessageBodyUndefined? {
          get {
            if !AsMessageBodyUndefined.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyUndefined(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyUndefined: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyUndefined"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(type: String, id: GraphQLID, text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyUndefined", "type": type, "id": id, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: String {
            get {
              return resultMap["type"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }
      }

      public struct Header: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageHeader"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("messageId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("fromMyself", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("timeStamp", type: .nonNull(.scalar(String.self))),
          GraphQLField("richTextChatCompatible", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("editAllowed", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("shouldRequestPushNotifications", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("pollingInterval", type: .nonNull(.scalar(Int.self))),
          GraphQLField("loadingIndicator", type: .scalar(String.self)),
          GraphQLField("statusMessage", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(messageId: GraphQLID, fromMyself: Bool, timeStamp: String, richTextChatCompatible: Bool, editAllowed: Bool, shouldRequestPushNotifications: Bool, pollingInterval: Int, loadingIndicator: String? = nil, statusMessage: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "MessageHeader", "messageId": messageId, "fromMyself": fromMyself, "timeStamp": timeStamp, "richTextChatCompatible": richTextChatCompatible, "editAllowed": editAllowed, "shouldRequestPushNotifications": shouldRequestPushNotifications, "pollingInterval": pollingInterval, "loadingIndicator": loadingIndicator, "statusMessage": statusMessage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var messageId: GraphQLID {
          get {
            return resultMap["messageId"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "messageId")
          }
        }

        public var fromMyself: Bool {
          get {
            return resultMap["fromMyself"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "fromMyself")
          }
        }

        public var timeStamp: String {
          get {
            return resultMap["timeStamp"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "timeStamp")
          }
        }

        public var richTextChatCompatible: Bool {
          get {
            return resultMap["richTextChatCompatible"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "richTextChatCompatible")
          }
        }

        public var editAllowed: Bool {
          get {
            return resultMap["editAllowed"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "editAllowed")
          }
        }

        public var shouldRequestPushNotifications: Bool {
          get {
            return resultMap["shouldRequestPushNotifications"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "shouldRequestPushNotifications")
          }
        }

        public var pollingInterval: Int {
          get {
            return resultMap["pollingInterval"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "pollingInterval")
          }
        }

        public var loadingIndicator: String? {
          get {
            return resultMap["loadingIndicator"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "loadingIndicator")
          }
        }

        public var statusMessage: String? {
          get {
            return resultMap["statusMessage"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "statusMessage")
          }
        }
      }
    }
  }
}

public final class ChatPreviewQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ChatPreview {
      messages {
        __typename
        id
        globalId
        body {
          __typename
          ... on MessageBodyText {
            text
          }
        }
        header {
          __typename
          fromMyself
          timeStamp
          markedAsRead
        }
      }
    }
    """

  public let operationName: String = "ChatPreview"

  public let operationIdentifier: String? = "fb6fac990520f5756941ac2aeb969833e509524b8946f985dbff04d499cde243"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("messages", type: .nonNull(.list(.object(Message.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(messages: [Message?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "messages": messages.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } }])
    }

    public var messages: [Message?] {
      get {
        return (resultMap["messages"] as! [ResultMap?]).map { (value: ResultMap?) -> Message? in value.flatMap { (value: ResultMap) -> Message in Message(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } }, forKey: "messages")
      }
    }

    public struct Message: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Message"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .nonNull(.object(Body.selections))),
        GraphQLField("header", type: .nonNull(.object(Header.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, globalId: GraphQLID, body: Body, header: Header) {
        self.init(unsafeResultMap: ["__typename": "Message", "id": id, "globalId": globalId, "body": body.resultMap, "header": header.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var globalId: GraphQLID {
        get {
          return resultMap["globalId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "globalId")
        }
      }

      public var body: Body {
        get {
          return Body(unsafeResultMap: resultMap["body"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "body")
        }
      }

      public var header: Header {
        get {
          return Header(unsafeResultMap: resultMap["header"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "header")
        }
      }

      public struct Body: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["MessageBodyText": AsMessageBodyText.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodySingleSelect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodySingleSelect"])
        }

        public static func makeMessageBodyMultipleSelect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect"])
        }

        public static func makeMessageBodyNumber() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyNumber"])
        }

        public static func makeMessageBodyAudio() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyAudio"])
        }

        public static func makeMessageBodyBankIdCollect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect"])
        }

        public static func makeMessageBodyFile() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyFile"])
        }

        public static func makeMessageBodyParagraph() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph"])
        }

        public static func makeMessageBodyUndefined() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined"])
        }

        public static func makeMessageBodyText(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asMessageBodyText: AsMessageBodyText? {
          get {
            if !AsMessageBodyText.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyText(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyText: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyText"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }
      }

      public struct Header: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageHeader"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("fromMyself", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("timeStamp", type: .nonNull(.scalar(String.self))),
          GraphQLField("markedAsRead", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(fromMyself: Bool, timeStamp: String, markedAsRead: Bool) {
          self.init(unsafeResultMap: ["__typename": "MessageHeader", "fromMyself": fromMyself, "timeStamp": timeStamp, "markedAsRead": markedAsRead])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fromMyself: Bool {
          get {
            return resultMap["fromMyself"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "fromMyself")
          }
        }

        public var timeStamp: String {
          get {
            return resultMap["timeStamp"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "timeStamp")
          }
        }

        public var markedAsRead: Bool {
          get {
            return resultMap["markedAsRead"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "markedAsRead")
          }
        }
      }
    }
  }
}

public final class ChatPreviewSubscriptionSubscription: GraphQLSubscription {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    subscription ChatPreviewSubscription {
      message {
        __typename
        id
        globalId
        body {
          __typename
          ... on MessageBodyText {
            text
          }
        }
        header {
          __typename
          timeStamp
          fromMyself
        }
      }
    }
    """

  public let operationName: String = "ChatPreviewSubscription"

  public let operationIdentifier: String? = "dec8389a19e1db6464702b524c1568cd0d106f675f42d4a32d2ee788ac4a8aee"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("message", type: .nonNull(.object(Message.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(message: Message) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "message": message.resultMap])
    }

    public var message: Message {
      get {
        return Message(unsafeResultMap: resultMap["message"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "message")
      }
    }

    public struct Message: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Message"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .nonNull(.object(Body.selections))),
        GraphQLField("header", type: .nonNull(.object(Header.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, globalId: GraphQLID, body: Body, header: Header) {
        self.init(unsafeResultMap: ["__typename": "Message", "id": id, "globalId": globalId, "body": body.resultMap, "header": header.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var globalId: GraphQLID {
        get {
          return resultMap["globalId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "globalId")
        }
      }

      public var body: Body {
        get {
          return Body(unsafeResultMap: resultMap["body"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "body")
        }
      }

      public var header: Header {
        get {
          return Header(unsafeResultMap: resultMap["header"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "header")
        }
      }

      public struct Body: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["MessageBodyText": AsMessageBodyText.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodySingleSelect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodySingleSelect"])
        }

        public static func makeMessageBodyMultipleSelect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect"])
        }

        public static func makeMessageBodyNumber() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyNumber"])
        }

        public static func makeMessageBodyAudio() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyAudio"])
        }

        public static func makeMessageBodyBankIdCollect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect"])
        }

        public static func makeMessageBodyFile() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyFile"])
        }

        public static func makeMessageBodyParagraph() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph"])
        }

        public static func makeMessageBodyUndefined() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined"])
        }

        public static func makeMessageBodyText(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asMessageBodyText: AsMessageBodyText? {
          get {
            if !AsMessageBodyText.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyText(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyText: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyText"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }
      }

      public struct Header: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageHeader"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("timeStamp", type: .nonNull(.scalar(String.self))),
          GraphQLField("fromMyself", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(timeStamp: String, fromMyself: Bool) {
          self.init(unsafeResultMap: ["__typename": "MessageHeader", "timeStamp": timeStamp, "fromMyself": fromMyself])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var timeStamp: String {
          get {
            return resultMap["timeStamp"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "timeStamp")
          }
        }

        public var fromMyself: Bool {
          get {
            return resultMap["fromMyself"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "fromMyself")
          }
        }
      }
    }
  }
}

public final class CommonClaimsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query CommonClaims($locale: Locale!) {
      commonClaims(locale: $locale) {
        __typename
        title
        icon {
          __typename
          ...IconFragment
        }
        layout {
          __typename
          ... on TitleAndBulletPoints {
            color
            bulletPoints {
              __typename
              description
              title
              icon {
                __typename
                ...IconFragment
              }
            }
            buttonTitle
            claimFirstMessage
            color
            title
          }
          ... on Emergency {
            color
            title
          }
        }
      }
    }
    """

  public let operationName: String = "CommonClaims"

  public let operationIdentifier: String? = "fec463233388707f07a7d6dc45c8ad8289e7fc77e2294f3e468e7318d366b236"

  public var queryDocument: String { return operationDefinition.appending(IconFragment.fragmentDefinition) }

  public var locale: Locale

  public init(locale: Locale) {
    self.locale = locale
  }

  public var variables: GraphQLMap? {
    return ["locale": locale]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("commonClaims", arguments: ["locale": GraphQLVariable("locale")], type: .nonNull(.list(.nonNull(.object(CommonClaim.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(commonClaims: [CommonClaim]) {
      self.init(unsafeResultMap: ["__typename": "Query", "commonClaims": commonClaims.map { (value: CommonClaim) -> ResultMap in value.resultMap }])
    }

    public var commonClaims: [CommonClaim] {
      get {
        return (resultMap["commonClaims"] as! [ResultMap]).map { (value: ResultMap) -> CommonClaim in CommonClaim(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: CommonClaim) -> ResultMap in value.resultMap }, forKey: "commonClaims")
      }
    }

    public struct CommonClaim: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CommonClaim"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("icon", type: .nonNull(.object(Icon.selections))),
        GraphQLField("layout", type: .nonNull(.object(Layout.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(title: String, icon: Icon, layout: Layout) {
        self.init(unsafeResultMap: ["__typename": "CommonClaim", "title": title, "icon": icon.resultMap, "layout": layout.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public var icon: Icon {
        get {
          return Icon(unsafeResultMap: resultMap["icon"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "icon")
        }
      }

      public var layout: Layout {
        get {
          return Layout(unsafeResultMap: resultMap["layout"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "layout")
        }
      }

      public struct Icon: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Icon"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(variants: Variant) {
          self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Icons with variants for light and dark mode
        public var variants: Variant {
          get {
            return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "variants")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var iconFragment: IconFragment {
            get {
              return IconFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Variant: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["IconVariants"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
            GraphQLField("light", type: .nonNull(.object(Light.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(dark: Dark, light: Light) {
            self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A variant to use for dark user interfaces
          public var dark: Dark {
            get {
              return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "dark")
            }
          }

          /// A variant to use for light user interfaces
          public var light: Light {
            get {
              return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "light")
            }
          }

          public struct Dark: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["IconVariant"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(pdfUrl: String) {
              self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// For iOS use
            public var pdfUrl: String {
              get {
                return resultMap["pdfUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "pdfUrl")
              }
            }
          }

          public struct Light: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["IconVariant"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(pdfUrl: String) {
              self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// For iOS use
            public var pdfUrl: String {
              get {
                return resultMap["pdfUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "pdfUrl")
              }
            }
          }
        }
      }

      public struct Layout: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["TitleAndBulletPoints", "Emergency"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["TitleAndBulletPoints": AsTitleAndBulletPoints.selections, "Emergency": AsEmergency.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeTitleAndBulletPoints(color: HedvigColor, bulletPoints: [AsTitleAndBulletPoints.BulletPoint], buttonTitle: String, claimFirstMessage: String, title: String) -> Layout {
          return Layout(unsafeResultMap: ["__typename": "TitleAndBulletPoints", "color": color, "bulletPoints": bulletPoints.map { (value: AsTitleAndBulletPoints.BulletPoint) -> ResultMap in value.resultMap }, "buttonTitle": buttonTitle, "claimFirstMessage": claimFirstMessage, "title": title])
        }

        public static func makeEmergency(color: HedvigColor, title: String) -> Layout {
          return Layout(unsafeResultMap: ["__typename": "Emergency", "color": color, "title": title])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asTitleAndBulletPoints: AsTitleAndBulletPoints? {
          get {
            if !AsTitleAndBulletPoints.possibleTypes.contains(__typename) { return nil }
            return AsTitleAndBulletPoints(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsTitleAndBulletPoints: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["TitleAndBulletPoints"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("color", type: .nonNull(.scalar(HedvigColor.self))),
            GraphQLField("bulletPoints", type: .nonNull(.list(.nonNull(.object(BulletPoint.selections))))),
            GraphQLField("buttonTitle", type: .nonNull(.scalar(String.self))),
            GraphQLField("claimFirstMessage", type: .nonNull(.scalar(String.self))),
            GraphQLField("color", type: .nonNull(.scalar(HedvigColor.self))),
            GraphQLField("title", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(color: HedvigColor, bulletPoints: [BulletPoint], buttonTitle: String, claimFirstMessage: String, title: String) {
            self.init(unsafeResultMap: ["__typename": "TitleAndBulletPoints", "color": color, "bulletPoints": bulletPoints.map { (value: BulletPoint) -> ResultMap in value.resultMap }, "buttonTitle": buttonTitle, "claimFirstMessage": claimFirstMessage, "title": title])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var color: HedvigColor {
            get {
              return resultMap["color"]! as! HedvigColor
            }
            set {
              resultMap.updateValue(newValue, forKey: "color")
            }
          }

          public var bulletPoints: [BulletPoint] {
            get {
              return (resultMap["bulletPoints"] as! [ResultMap]).map { (value: ResultMap) -> BulletPoint in BulletPoint(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: BulletPoint) -> ResultMap in value.resultMap }, forKey: "bulletPoints")
            }
          }

          public var buttonTitle: String {
            get {
              return resultMap["buttonTitle"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "buttonTitle")
            }
          }

          @available(*, deprecated, message: "not used")
          public var claimFirstMessage: String {
            get {
              return resultMap["claimFirstMessage"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "claimFirstMessage")
            }
          }

          public var title: String {
            get {
              return resultMap["title"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          public struct BulletPoint: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["BulletPoints"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("description", type: .nonNull(.scalar(String.self))),
              GraphQLField("title", type: .nonNull(.scalar(String.self))),
              GraphQLField("icon", type: .nonNull(.object(Icon.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(description: String, title: String, icon: Icon) {
              self.init(unsafeResultMap: ["__typename": "BulletPoints", "description": description, "title": title, "icon": icon.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var description: String {
              get {
                return resultMap["description"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }

            public var title: String {
              get {
                return resultMap["title"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "title")
              }
            }

            public var icon: Icon {
              get {
                return Icon(unsafeResultMap: resultMap["icon"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "icon")
              }
            }

            public struct Icon: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Icon"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(variants: Variant) {
                self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Icons with variants for light and dark mode
              public var variants: Variant {
                get {
                  return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "variants")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var iconFragment: IconFragment {
                  get {
                    return IconFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }

              public struct Variant: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["IconVariants"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
                  GraphQLField("light", type: .nonNull(.object(Light.selections))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(dark: Dark, light: Light) {
                  self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// A variant to use for dark user interfaces
                public var dark: Dark {
                  get {
                    return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
                  }
                  set {
                    resultMap.updateValue(newValue.resultMap, forKey: "dark")
                  }
                }

                /// A variant to use for light user interfaces
                public var light: Light {
                  get {
                    return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
                  }
                  set {
                    resultMap.updateValue(newValue.resultMap, forKey: "light")
                  }
                }

                public struct Dark: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["IconVariant"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(pdfUrl: String) {
                    self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// For iOS use
                  public var pdfUrl: String {
                    get {
                      return resultMap["pdfUrl"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "pdfUrl")
                    }
                  }
                }

                public struct Light: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["IconVariant"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(pdfUrl: String) {
                    self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// For iOS use
                  public var pdfUrl: String {
                    get {
                      return resultMap["pdfUrl"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "pdfUrl")
                    }
                  }
                }
              }
            }
          }
        }

        public var asEmergency: AsEmergency? {
          get {
            if !AsEmergency.possibleTypes.contains(__typename) { return nil }
            return AsEmergency(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsEmergency: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Emergency"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("color", type: .nonNull(.scalar(HedvigColor.self))),
            GraphQLField("title", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(color: HedvigColor, title: String) {
            self.init(unsafeResultMap: ["__typename": "Emergency", "color": color, "title": title])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var color: HedvigColor {
            get {
              return resultMap["color"]! as! HedvigColor
            }
            set {
              resultMap.updateValue(newValue, forKey: "color")
            }
          }

          public var title: String {
            get {
              return resultMap["title"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }
        }
      }
    }
  }
}

public final class ContractsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Contracts($locale: Locale!) {
      contracts {
        __typename
        displayName
        switchedFromInsuranceProvider
        upcomingRenewal {
          __typename
          renewalDate
          draftCertificateUrl
        }
        perils(locale: $locale) {
          __typename
          ...PerilFragment
        }
        insurableLimits(locale: $locale) {
          __typename
          ...InsurableLimitFragment
        }
        termsAndConditions(locale: $locale) {
          __typename
          displayName
          url
        }
        status {
          __typename
          ... on PendingStatus {
            pendingSince
          }
          ... on ActiveInFutureStatus {
            futureInception
          }
          ... on ActiveStatus {
            pastInception
          }
          ... on ActiveInFutureAndTerminatedInFutureStatus {
            futureInception
            futureTermination
          }
          ... on TerminatedInFutureStatus {
            futureTermination
          }
          ... on TerminatedTodayStatus {
            today
          }
          ... on TerminatedStatus {
            termination
          }
        }
        currentAgreement {
          __typename
          ... on AgreementCore {
            certificateUrl
          }
          ... on SwedishApartmentAgreement {
            activeFrom
            activeTo
            certificateUrl
            numberCoInsured
            address {
              __typename
              street
              postalCode
              city
            }
            squareMeters
            type
            premium {
              __typename
              ...MonetaryAmountFragment
            }
          }
          ... on SwedishHouseAgreement {
            activeFrom
            activeTo
            certificateUrl
            numberCoInsured
            address {
              __typename
              street
              postalCode
              city
            }
            squareMeters
            yearOfConstruction
            ancillaryArea
            isSubleted
            numberOfBathrooms
            extraBuildings {
              __typename
              ...ExtraBuildingFragment
            }
          }
          ... on NorwegianHomeContentAgreement {
            activeFrom
            activeTo
            certificateUrl
            numberCoInsured
            address {
              __typename
              street
              postalCode
              city
            }
            squareMeters
          }
          ... on NorwegianTravelAgreement {
            activeFrom
            activeTo
            certificateUrl
            numberCoInsured
          }
        }
      }
    }
    """

  public let operationName: String = "Contracts"

  public let operationIdentifier: String? = "45a6286116c80bd61362db7bb4e6ef8511b224dc15eefc12743c2789fa0cf244"

  public var queryDocument: String { return operationDefinition.appending(PerilFragment.fragmentDefinition).appending(IconFragment.fragmentDefinition).appending(InsurableLimitFragment.fragmentDefinition).appending(MonetaryAmountFragment.fragmentDefinition).appending(ExtraBuildingFragment.fragmentDefinition) }

  public var locale: Locale

  public init(locale: Locale) {
    self.locale = locale
  }

  public var variables: GraphQLMap? {
    return ["locale": locale]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("contracts", type: .nonNull(.list(.nonNull(.object(Contract.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(contracts: [Contract]) {
      self.init(unsafeResultMap: ["__typename": "Query", "contracts": contracts.map { (value: Contract) -> ResultMap in value.resultMap }])
    }

    /// Returns all contracts the member currently holds, regardless of activation/termination status
    public var contracts: [Contract] {
      get {
        return (resultMap["contracts"] as! [ResultMap]).map { (value: ResultMap) -> Contract in Contract(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Contract) -> ResultMap in value.resultMap }, forKey: "contracts")
      }
    }

    public struct Contract: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Contract"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
        GraphQLField("switchedFromInsuranceProvider", type: .scalar(String.self)),
        GraphQLField("upcomingRenewal", type: .object(UpcomingRenewal.selections)),
        GraphQLField("perils", arguments: ["locale": GraphQLVariable("locale")], type: .nonNull(.list(.nonNull(.object(Peril.selections))))),
        GraphQLField("insurableLimits", arguments: ["locale": GraphQLVariable("locale")], type: .nonNull(.list(.nonNull(.object(InsurableLimit.selections))))),
        GraphQLField("termsAndConditions", arguments: ["locale": GraphQLVariable("locale")], type: .nonNull(.object(TermsAndCondition.selections))),
        GraphQLField("status", type: .nonNull(.object(Status.selections))),
        GraphQLField("currentAgreement", type: .nonNull(.object(CurrentAgreement.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(displayName: String, switchedFromInsuranceProvider: String? = nil, upcomingRenewal: UpcomingRenewal? = nil, perils: [Peril], insurableLimits: [InsurableLimit], termsAndConditions: TermsAndCondition, status: Status, currentAgreement: CurrentAgreement) {
        self.init(unsafeResultMap: ["__typename": "Contract", "displayName": displayName, "switchedFromInsuranceProvider": switchedFromInsuranceProvider, "upcomingRenewal": upcomingRenewal.flatMap { (value: UpcomingRenewal) -> ResultMap in value.resultMap }, "perils": perils.map { (value: Peril) -> ResultMap in value.resultMap }, "insurableLimits": insurableLimits.map { (value: InsurableLimit) -> ResultMap in value.resultMap }, "termsAndConditions": termsAndConditions.resultMap, "status": status.resultMap, "currentAgreement": currentAgreement.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var displayName: String {
        get {
          return resultMap["displayName"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "displayName")
        }
      }

      public var switchedFromInsuranceProvider: String? {
        get {
          return resultMap["switchedFromInsuranceProvider"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "switchedFromInsuranceProvider")
        }
      }

      /// An upcoming renewal, present if the member has been notified and the renewal is within 31 days
      public var upcomingRenewal: UpcomingRenewal? {
        get {
          return (resultMap["upcomingRenewal"] as? ResultMap).flatMap { UpcomingRenewal(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "upcomingRenewal")
        }
      }

      public var perils: [Peril] {
        get {
          return (resultMap["perils"] as! [ResultMap]).map { (value: ResultMap) -> Peril in Peril(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Peril) -> ResultMap in value.resultMap }, forKey: "perils")
        }
      }

      public var insurableLimits: [InsurableLimit] {
        get {
          return (resultMap["insurableLimits"] as! [ResultMap]).map { (value: ResultMap) -> InsurableLimit in InsurableLimit(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: InsurableLimit) -> ResultMap in value.resultMap }, forKey: "insurableLimits")
        }
      }

      public var termsAndConditions: TermsAndCondition {
        get {
          return TermsAndCondition(unsafeResultMap: resultMap["termsAndConditions"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "termsAndConditions")
        }
      }

      public var status: Status {
        get {
          return Status(unsafeResultMap: resultMap["status"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "status")
        }
      }

      /// "The 'best guess' of the agreement that depicts the member's insurance, either
      /// the pending, future, current or, if terminated, past agreement
      public var currentAgreement: CurrentAgreement {
        get {
          return CurrentAgreement(unsafeResultMap: resultMap["currentAgreement"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "currentAgreement")
        }
      }

      public struct UpcomingRenewal: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["UpcomingRenewal"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("renewalDate", type: .nonNull(.scalar(String.self))),
          GraphQLField("draftCertificateUrl", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(renewalDate: String, draftCertificateUrl: String) {
          self.init(unsafeResultMap: ["__typename": "UpcomingRenewal", "renewalDate": renewalDate, "draftCertificateUrl": draftCertificateUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var renewalDate: String {
          get {
            return resultMap["renewalDate"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "renewalDate")
          }
        }

        public var draftCertificateUrl: String {
          get {
            return resultMap["draftCertificateUrl"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "draftCertificateUrl")
          }
        }
      }

      public struct Peril: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PerilV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
          GraphQLField("icon", type: .nonNull(.object(Icon.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(title: String, description: String, icon: Icon) {
          self.init(unsafeResultMap: ["__typename": "PerilV2", "title": title, "description": description, "icon": icon.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var title: String {
          get {
            return resultMap["title"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "title")
          }
        }

        public var description: String {
          get {
            return resultMap["description"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }

        public var icon: Icon {
          get {
            return Icon(unsafeResultMap: resultMap["icon"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "icon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var perilFragment: PerilFragment {
            get {
              return PerilFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Icon: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Icon"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(variants: Variant) {
            self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Icons with variants for light and dark mode
          public var variants: Variant {
            get {
              return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "variants")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var iconFragment: IconFragment {
              get {
                return IconFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Variant: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["IconVariants"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
              GraphQLField("light", type: .nonNull(.object(Light.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(dark: Dark, light: Light) {
              self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// A variant to use for dark user interfaces
            public var dark: Dark {
              get {
                return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "dark")
              }
            }

            /// A variant to use for light user interfaces
            public var light: Light {
              get {
                return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "light")
              }
            }

            public struct Dark: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["IconVariant"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(pdfUrl: String) {
                self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// For iOS use
              public var pdfUrl: String {
                get {
                  return resultMap["pdfUrl"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "pdfUrl")
                }
              }
            }

            public struct Light: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["IconVariant"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(pdfUrl: String) {
                self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// For iOS use
              public var pdfUrl: String {
                get {
                  return resultMap["pdfUrl"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "pdfUrl")
                }
              }
            }
          }
        }
      }

      public struct InsurableLimit: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["InsurableLimit"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("label", type: .nonNull(.scalar(String.self))),
          GraphQLField("limit", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(label: String, limit: String, description: String) {
          self.init(unsafeResultMap: ["__typename": "InsurableLimit", "label": label, "limit": limit, "description": description])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var label: String {
          get {
            return resultMap["label"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "label")
          }
        }

        public var limit: String {
          get {
            return resultMap["limit"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "limit")
          }
        }

        public var description: String {
          get {
            return resultMap["description"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var insurableLimitFragment: InsurableLimitFragment {
            get {
              return InsurableLimitFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct TermsAndCondition: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["InsuranceTerm"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(displayName: String, url: String) {
          self.init(unsafeResultMap: ["__typename": "InsuranceTerm", "displayName": displayName, "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var displayName: String {
          get {
            return resultMap["displayName"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "displayName")
          }
        }

        public var url: String {
          get {
            return resultMap["url"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }

      public struct Status: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PendingStatus", "ActiveInFutureStatus", "ActiveStatus", "ActiveInFutureAndTerminatedInFutureStatus", "TerminatedInFutureStatus", "TerminatedTodayStatus", "TerminatedStatus"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["PendingStatus": AsPendingStatus.selections, "ActiveInFutureStatus": AsActiveInFutureStatus.selections, "ActiveStatus": AsActiveStatus.selections, "ActiveInFutureAndTerminatedInFutureStatus": AsActiveInFutureAndTerminatedInFutureStatus.selections, "TerminatedInFutureStatus": AsTerminatedInFutureStatus.selections, "TerminatedTodayStatus": AsTerminatedTodayStatus.selections, "TerminatedStatus": AsTerminatedStatus.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makePendingStatus(pendingSince: String? = nil) -> Status {
          return Status(unsafeResultMap: ["__typename": "PendingStatus", "pendingSince": pendingSince])
        }

        public static func makeActiveInFutureStatus(futureInception: String? = nil) -> Status {
          return Status(unsafeResultMap: ["__typename": "ActiveInFutureStatus", "futureInception": futureInception])
        }

        public static func makeActiveStatus(pastInception: String? = nil) -> Status {
          return Status(unsafeResultMap: ["__typename": "ActiveStatus", "pastInception": pastInception])
        }

        public static func makeActiveInFutureAndTerminatedInFutureStatus(futureInception: String? = nil, futureTermination: String? = nil) -> Status {
          return Status(unsafeResultMap: ["__typename": "ActiveInFutureAndTerminatedInFutureStatus", "futureInception": futureInception, "futureTermination": futureTermination])
        }

        public static func makeTerminatedInFutureStatus(futureTermination: String? = nil) -> Status {
          return Status(unsafeResultMap: ["__typename": "TerminatedInFutureStatus", "futureTermination": futureTermination])
        }

        public static func makeTerminatedTodayStatus(today: String? = nil) -> Status {
          return Status(unsafeResultMap: ["__typename": "TerminatedTodayStatus", "today": today])
        }

        public static func makeTerminatedStatus(termination: String? = nil) -> Status {
          return Status(unsafeResultMap: ["__typename": "TerminatedStatus", "termination": termination])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asPendingStatus: AsPendingStatus? {
          get {
            if !AsPendingStatus.possibleTypes.contains(__typename) { return nil }
            return AsPendingStatus(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsPendingStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PendingStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("pendingSince", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(pendingSince: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PendingStatus", "pendingSince": pendingSince])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var pendingSince: String? {
            get {
              return resultMap["pendingSince"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "pendingSince")
            }
          }
        }

        public var asActiveInFutureStatus: AsActiveInFutureStatus? {
          get {
            if !AsActiveInFutureStatus.possibleTypes.contains(__typename) { return nil }
            return AsActiveInFutureStatus(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsActiveInFutureStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["ActiveInFutureStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("futureInception", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(futureInception: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "ActiveInFutureStatus", "futureInception": futureInception])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var futureInception: String? {
            get {
              return resultMap["futureInception"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "futureInception")
            }
          }
        }

        public var asActiveStatus: AsActiveStatus? {
          get {
            if !AsActiveStatus.possibleTypes.contains(__typename) { return nil }
            return AsActiveStatus(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsActiveStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["ActiveStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("pastInception", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(pastInception: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "ActiveStatus", "pastInception": pastInception])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var pastInception: String? {
            get {
              return resultMap["pastInception"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "pastInception")
            }
          }
        }

        public var asActiveInFutureAndTerminatedInFutureStatus: AsActiveInFutureAndTerminatedInFutureStatus? {
          get {
            if !AsActiveInFutureAndTerminatedInFutureStatus.possibleTypes.contains(__typename) { return nil }
            return AsActiveInFutureAndTerminatedInFutureStatus(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsActiveInFutureAndTerminatedInFutureStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["ActiveInFutureAndTerminatedInFutureStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("futureInception", type: .scalar(String.self)),
            GraphQLField("futureTermination", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(futureInception: String? = nil, futureTermination: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "ActiveInFutureAndTerminatedInFutureStatus", "futureInception": futureInception, "futureTermination": futureTermination])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var futureInception: String? {
            get {
              return resultMap["futureInception"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "futureInception")
            }
          }

          public var futureTermination: String? {
            get {
              return resultMap["futureTermination"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "futureTermination")
            }
          }
        }

        public var asTerminatedInFutureStatus: AsTerminatedInFutureStatus? {
          get {
            if !AsTerminatedInFutureStatus.possibleTypes.contains(__typename) { return nil }
            return AsTerminatedInFutureStatus(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsTerminatedInFutureStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["TerminatedInFutureStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("futureTermination", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(futureTermination: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "TerminatedInFutureStatus", "futureTermination": futureTermination])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var futureTermination: String? {
            get {
              return resultMap["futureTermination"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "futureTermination")
            }
          }
        }

        public var asTerminatedTodayStatus: AsTerminatedTodayStatus? {
          get {
            if !AsTerminatedTodayStatus.possibleTypes.contains(__typename) { return nil }
            return AsTerminatedTodayStatus(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsTerminatedTodayStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["TerminatedTodayStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("today", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(today: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "TerminatedTodayStatus", "today": today])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var today: String? {
            get {
              return resultMap["today"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "today")
            }
          }
        }

        public var asTerminatedStatus: AsTerminatedStatus? {
          get {
            if !AsTerminatedStatus.possibleTypes.contains(__typename) { return nil }
            return AsTerminatedStatus(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsTerminatedStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["TerminatedStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("termination", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(termination: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "TerminatedStatus", "termination": termination])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var termination: String? {
            get {
              return resultMap["termination"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "termination")
            }
          }
        }
      }

      public struct CurrentAgreement: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SwedishApartmentAgreement", "SwedishHouseAgreement", "NorwegianHomeContentAgreement", "NorwegianTravelAgreement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["SwedishApartmentAgreement": AsSwedishApartmentAgreement.selections, "SwedishHouseAgreement": AsSwedishHouseAgreement.selections, "NorwegianHomeContentAgreement": AsNorwegianHomeContentAgreement.selections, "NorwegianTravelAgreement": AsNorwegianTravelAgreement.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("certificateUrl", type: .scalar(String.self)),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeSwedishApartmentAgreement(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int, address: AsSwedishApartmentAgreement.Address, squareMeters: Int, type: SwedishApartmentLineOfBusiness, premium: AsSwedishApartmentAgreement.Premium) -> CurrentAgreement {
          return CurrentAgreement(unsafeResultMap: ["__typename": "SwedishApartmentAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured, "address": address.resultMap, "squareMeters": squareMeters, "type": type, "premium": premium.resultMap])
        }

        public static func makeSwedishHouseAgreement(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int, address: AsSwedishHouseAgreement.Address, squareMeters: Int, yearOfConstruction: Int, ancillaryArea: Int, isSubleted: Bool, numberOfBathrooms: Int, extraBuildings: [AsSwedishHouseAgreement.ExtraBuilding?]) -> CurrentAgreement {
          return CurrentAgreement(unsafeResultMap: ["__typename": "SwedishHouseAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured, "address": address.resultMap, "squareMeters": squareMeters, "yearOfConstruction": yearOfConstruction, "ancillaryArea": ancillaryArea, "isSubleted": isSubleted, "numberOfBathrooms": numberOfBathrooms, "extraBuildings": extraBuildings.map { (value: AsSwedishHouseAgreement.ExtraBuilding?) -> ResultMap? in value.flatMap { (value: AsSwedishHouseAgreement.ExtraBuilding) -> ResultMap in value.resultMap } }])
        }

        public static func makeNorwegianHomeContentAgreement(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int, address: AsNorwegianHomeContentAgreement.Address, squareMeters: Int) -> CurrentAgreement {
          return CurrentAgreement(unsafeResultMap: ["__typename": "NorwegianHomeContentAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured, "address": address.resultMap, "squareMeters": squareMeters])
        }

        public static func makeNorwegianTravelAgreement(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int) -> CurrentAgreement {
          return CurrentAgreement(unsafeResultMap: ["__typename": "NorwegianTravelAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var certificateUrl: String? {
          get {
            return resultMap["certificateUrl"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "certificateUrl")
          }
        }

        public var asSwedishApartmentAgreement: AsSwedishApartmentAgreement? {
          get {
            if !AsSwedishApartmentAgreement.possibleTypes.contains(__typename) { return nil }
            return AsSwedishApartmentAgreement(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsSwedishApartmentAgreement: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SwedishApartmentAgreement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("activeFrom", type: .scalar(String.self)),
            GraphQLField("activeTo", type: .scalar(String.self)),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("numberCoInsured", type: .nonNull(.scalar(Int.self))),
            GraphQLField("address", type: .nonNull(.object(Address.selections))),
            GraphQLField("squareMeters", type: .nonNull(.scalar(Int.self))),
            GraphQLField("type", type: .nonNull(.scalar(SwedishApartmentLineOfBusiness.self))),
            GraphQLField("premium", type: .nonNull(.object(Premium.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int, address: Address, squareMeters: Int, type: SwedishApartmentLineOfBusiness, premium: Premium) {
            self.init(unsafeResultMap: ["__typename": "SwedishApartmentAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured, "address": address.resultMap, "squareMeters": squareMeters, "type": type, "premium": premium.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var certificateUrl: String? {
            get {
              return resultMap["certificateUrl"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "certificateUrl")
            }
          }

          public var activeFrom: String? {
            get {
              return resultMap["activeFrom"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeFrom")
            }
          }

          public var activeTo: String? {
            get {
              return resultMap["activeTo"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeTo")
            }
          }

          public var numberCoInsured: Int {
            get {
              return resultMap["numberCoInsured"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "numberCoInsured")
            }
          }

          public var address: Address {
            get {
              return Address(unsafeResultMap: resultMap["address"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "address")
            }
          }

          public var squareMeters: Int {
            get {
              return resultMap["squareMeters"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "squareMeters")
            }
          }

          public var type: SwedishApartmentLineOfBusiness {
            get {
              return resultMap["type"]! as! SwedishApartmentLineOfBusiness
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var premium: Premium {
            get {
              return Premium(unsafeResultMap: resultMap["premium"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "premium")
            }
          }

          public struct Address: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Address"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("street", type: .nonNull(.scalar(String.self))),
              GraphQLField("postalCode", type: .nonNull(.scalar(String.self))),
              GraphQLField("city", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(street: String, postalCode: String, city: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Address", "street": street, "postalCode": postalCode, "city": city])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var street: String {
              get {
                return resultMap["street"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "street")
              }
            }

            public var postalCode: String {
              get {
                return resultMap["postalCode"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "postalCode")
              }
            }

            public var city: String? {
              get {
                return resultMap["city"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "city")
              }
            }
          }

          public struct Premium: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonetaryAmountV2"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .nonNull(.scalar(String.self))),
              GraphQLField("currency", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: String, currency: String) {
              self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: String {
              get {
                return resultMap["amount"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "amount")
              }
            }

            public var currency: String {
              get {
                return resultMap["currency"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "currency")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var monetaryAmountFragment: MonetaryAmountFragment {
                get {
                  return MonetaryAmountFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }

        public var asSwedishHouseAgreement: AsSwedishHouseAgreement? {
          get {
            if !AsSwedishHouseAgreement.possibleTypes.contains(__typename) { return nil }
            return AsSwedishHouseAgreement(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsSwedishHouseAgreement: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SwedishHouseAgreement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("activeFrom", type: .scalar(String.self)),
            GraphQLField("activeTo", type: .scalar(String.self)),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("numberCoInsured", type: .nonNull(.scalar(Int.self))),
            GraphQLField("address", type: .nonNull(.object(Address.selections))),
            GraphQLField("squareMeters", type: .nonNull(.scalar(Int.self))),
            GraphQLField("yearOfConstruction", type: .nonNull(.scalar(Int.self))),
            GraphQLField("ancillaryArea", type: .nonNull(.scalar(Int.self))),
            GraphQLField("isSubleted", type: .nonNull(.scalar(Bool.self))),
            GraphQLField("numberOfBathrooms", type: .nonNull(.scalar(Int.self))),
            GraphQLField("extraBuildings", type: .nonNull(.list(.object(ExtraBuilding.selections)))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int, address: Address, squareMeters: Int, yearOfConstruction: Int, ancillaryArea: Int, isSubleted: Bool, numberOfBathrooms: Int, extraBuildings: [ExtraBuilding?]) {
            self.init(unsafeResultMap: ["__typename": "SwedishHouseAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured, "address": address.resultMap, "squareMeters": squareMeters, "yearOfConstruction": yearOfConstruction, "ancillaryArea": ancillaryArea, "isSubleted": isSubleted, "numberOfBathrooms": numberOfBathrooms, "extraBuildings": extraBuildings.map { (value: ExtraBuilding?) -> ResultMap? in value.flatMap { (value: ExtraBuilding) -> ResultMap in value.resultMap } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var certificateUrl: String? {
            get {
              return resultMap["certificateUrl"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "certificateUrl")
            }
          }

          public var activeFrom: String? {
            get {
              return resultMap["activeFrom"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeFrom")
            }
          }

          public var activeTo: String? {
            get {
              return resultMap["activeTo"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeTo")
            }
          }

          public var numberCoInsured: Int {
            get {
              return resultMap["numberCoInsured"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "numberCoInsured")
            }
          }

          public var address: Address {
            get {
              return Address(unsafeResultMap: resultMap["address"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "address")
            }
          }

          public var squareMeters: Int {
            get {
              return resultMap["squareMeters"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "squareMeters")
            }
          }

          public var yearOfConstruction: Int {
            get {
              return resultMap["yearOfConstruction"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "yearOfConstruction")
            }
          }

          public var ancillaryArea: Int {
            get {
              return resultMap["ancillaryArea"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "ancillaryArea")
            }
          }

          public var isSubleted: Bool {
            get {
              return resultMap["isSubleted"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "isSubleted")
            }
          }

          public var numberOfBathrooms: Int {
            get {
              return resultMap["numberOfBathrooms"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "numberOfBathrooms")
            }
          }

          public var extraBuildings: [ExtraBuilding?] {
            get {
              return (resultMap["extraBuildings"] as! [ResultMap?]).map { (value: ResultMap?) -> ExtraBuilding? in value.flatMap { (value: ResultMap) -> ExtraBuilding in ExtraBuilding(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.map { (value: ExtraBuilding?) -> ResultMap? in value.flatMap { (value: ExtraBuilding) -> ResultMap in value.resultMap } }, forKey: "extraBuildings")
            }
          }

          public struct Address: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Address"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("street", type: .nonNull(.scalar(String.self))),
              GraphQLField("postalCode", type: .nonNull(.scalar(String.self))),
              GraphQLField("city", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(street: String, postalCode: String, city: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Address", "street": street, "postalCode": postalCode, "city": city])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var street: String {
              get {
                return resultMap["street"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "street")
              }
            }

            public var postalCode: String {
              get {
                return resultMap["postalCode"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "postalCode")
              }
            }

            public var city: String? {
              get {
                return resultMap["city"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "city")
              }
            }
          }

          public struct ExtraBuilding: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["ExtraBuildingGarage", "ExtraBuildingCarport", "ExtraBuildingShed", "ExtraBuildingStorehouse", "ExtraBuildingFriggebod", "ExtraBuildingAttefall", "ExtraBuildingOuthouse", "ExtraBuildingGuesthouse", "ExtraBuildingGazebo", "ExtraBuildingGreenhouse", "ExtraBuildingSauna", "ExtraBuildingBarn", "ExtraBuildingBoathouse", "ExtraBuildingOther"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
              GraphQLField("area", type: .nonNull(.scalar(Int.self))),
              GraphQLField("hasWaterConnected", type: .nonNull(.scalar(Bool.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeExtraBuildingGarage(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGarage", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingCarport(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingCarport", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingShed(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingShed", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingStorehouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingStorehouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingFriggebod(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingFriggebod", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingAttefall(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingAttefall", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingOuthouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingOuthouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingGuesthouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGuesthouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingGazebo(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGazebo", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingGreenhouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGreenhouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingSauna(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingSauna", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingBarn(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingBarn", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingBoathouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingBoathouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public static func makeExtraBuildingOther(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
              return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingOther", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var displayName: String {
              get {
                return resultMap["displayName"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "displayName")
              }
            }

            public var area: Int {
              get {
                return resultMap["area"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "area")
              }
            }

            public var hasWaterConnected: Bool {
              get {
                return resultMap["hasWaterConnected"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "hasWaterConnected")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var extraBuildingFragment: ExtraBuildingFragment {
                get {
                  return ExtraBuildingFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }

        public var asNorwegianHomeContentAgreement: AsNorwegianHomeContentAgreement? {
          get {
            if !AsNorwegianHomeContentAgreement.possibleTypes.contains(__typename) { return nil }
            return AsNorwegianHomeContentAgreement(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsNorwegianHomeContentAgreement: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["NorwegianHomeContentAgreement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("activeFrom", type: .scalar(String.self)),
            GraphQLField("activeTo", type: .scalar(String.self)),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("numberCoInsured", type: .nonNull(.scalar(Int.self))),
            GraphQLField("address", type: .nonNull(.object(Address.selections))),
            GraphQLField("squareMeters", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int, address: Address, squareMeters: Int) {
            self.init(unsafeResultMap: ["__typename": "NorwegianHomeContentAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured, "address": address.resultMap, "squareMeters": squareMeters])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var certificateUrl: String? {
            get {
              return resultMap["certificateUrl"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "certificateUrl")
            }
          }

          public var activeFrom: String? {
            get {
              return resultMap["activeFrom"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeFrom")
            }
          }

          public var activeTo: String? {
            get {
              return resultMap["activeTo"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeTo")
            }
          }

          public var numberCoInsured: Int {
            get {
              return resultMap["numberCoInsured"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "numberCoInsured")
            }
          }

          public var address: Address {
            get {
              return Address(unsafeResultMap: resultMap["address"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "address")
            }
          }

          public var squareMeters: Int {
            get {
              return resultMap["squareMeters"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "squareMeters")
            }
          }

          public struct Address: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Address"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("street", type: .nonNull(.scalar(String.self))),
              GraphQLField("postalCode", type: .nonNull(.scalar(String.self))),
              GraphQLField("city", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(street: String, postalCode: String, city: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Address", "street": street, "postalCode": postalCode, "city": city])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var street: String {
              get {
                return resultMap["street"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "street")
              }
            }

            public var postalCode: String {
              get {
                return resultMap["postalCode"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "postalCode")
              }
            }

            public var city: String? {
              get {
                return resultMap["city"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "city")
              }
            }
          }
        }

        public var asNorwegianTravelAgreement: AsNorwegianTravelAgreement? {
          get {
            if !AsNorwegianTravelAgreement.possibleTypes.contains(__typename) { return nil }
            return AsNorwegianTravelAgreement(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsNorwegianTravelAgreement: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["NorwegianTravelAgreement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("activeFrom", type: .scalar(String.self)),
            GraphQLField("activeTo", type: .scalar(String.self)),
            GraphQLField("certificateUrl", type: .scalar(String.self)),
            GraphQLField("numberCoInsured", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(certificateUrl: String? = nil, activeFrom: String? = nil, activeTo: String? = nil, numberCoInsured: Int) {
            self.init(unsafeResultMap: ["__typename": "NorwegianTravelAgreement", "certificateUrl": certificateUrl, "activeFrom": activeFrom, "activeTo": activeTo, "numberCoInsured": numberCoInsured])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var certificateUrl: String? {
            get {
              return resultMap["certificateUrl"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "certificateUrl")
            }
          }

          public var activeFrom: String? {
            get {
              return resultMap["activeFrom"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeFrom")
            }
          }

          public var activeTo: String? {
            get {
              return resultMap["activeTo"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "activeTo")
            }
          }

          public var numberCoInsured: Int {
            get {
              return resultMap["numberCoInsured"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "numberCoInsured")
            }
          }
        }
      }
    }
  }
}

public final class CreateKeyGearItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CreateKeyGearItem($input: CreateKeyGearItemInput!) {
      createKeyGearItem(input: $input) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "CreateKeyGearItem"

  public let operationIdentifier: String? = "4ed134dc67c4409dfbb9f266a2ab899d239a7b759f0260cadf411e449980c6c9"

  public var input: CreateKeyGearItemInput

  public init(input: CreateKeyGearItemInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createKeyGearItem", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(CreateKeyGearItem.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createKeyGearItem: CreateKeyGearItem) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createKeyGearItem": createKeyGearItem.resultMap])
    }

    public var createKeyGearItem: CreateKeyGearItem {
      get {
        return CreateKeyGearItem(unsafeResultMap: resultMap["createKeyGearItem"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "createKeyGearItem")
      }
    }

    public struct CreateKeyGearItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class CreateSessionMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CreateSession($campaign: CampaignInput, $trackingId: UUID) {
      createSession(campaign: $campaign, trackingId: $trackingId)
    }
    """

  public let operationName: String = "CreateSession"

  public let operationIdentifier: String? = "d3cce6d18b3ecaca068d76970e7de385d2b0a6834b1de82ac83adc58241045ce"

  public var campaign: CampaignInput?
  public var trackingId: String?

  public init(campaign: CampaignInput? = nil, trackingId: String? = nil) {
    self.campaign = campaign
    self.trackingId = trackingId
  }

  public var variables: GraphQLMap? {
    return ["campaign": campaign, "trackingId": trackingId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createSession", arguments: ["campaign": GraphQLVariable("campaign"), "trackingId": GraphQLVariable("trackingId")], type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createSession: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createSession": createSession])
    }

    public var createSession: String {
      get {
        return resultMap["createSession"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "createSession")
      }
    }
  }
}

public final class DashboardQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Dashboard {
      insurance {
        __typename
        renewal {
          __typename
          certificateUrl
          date
        }
        status
        type
        activeFrom
        arrangedPerilCategories {
          __typename
          stuff {
            __typename
            ...PerilCategoryFragment
          }
          home {
            __typename
            ...PerilCategoryFragment
          }
          me {
            __typename
            ...PerilCategoryFragment
          }
        }
      }
      member {
        __typename
        firstName
      }
    }
    """

  public let operationName: String = "Dashboard"

  public let operationIdentifier: String? = "862e659477c6054d8c8bd8203118c5768690933e5bbea01d7cda7ae201f07f4e"

  public var queryDocument: String { return operationDefinition.appending(PerilCategoryFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("insurance", type: .nonNull(.object(Insurance.selections))),
      GraphQLField("member", type: .nonNull(.object(Member.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(insurance: Insurance, member: Member) {
      self.init(unsafeResultMap: ["__typename": "Query", "insurance": insurance.resultMap, "member": member.resultMap])
    }

    public var insurance: Insurance {
      get {
        return Insurance(unsafeResultMap: resultMap["insurance"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "insurance")
      }
    }

    public var member: Member {
      get {
        return Member(unsafeResultMap: resultMap["member"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "member")
      }
    }

    public struct Insurance: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Insurance"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("renewal", type: .object(Renewal.selections)),
        GraphQLField("status", type: .nonNull(.scalar(InsuranceStatus.self))),
        GraphQLField("type", type: .scalar(InsuranceType.self)),
        GraphQLField("activeFrom", type: .scalar(String.self)),
        GraphQLField("arrangedPerilCategories", type: .nonNull(.object(ArrangedPerilCategory.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(renewal: Renewal? = nil, status: InsuranceStatus, type: InsuranceType? = nil, activeFrom: String? = nil, arrangedPerilCategories: ArrangedPerilCategory) {
        self.init(unsafeResultMap: ["__typename": "Insurance", "renewal": renewal.flatMap { (value: Renewal) -> ResultMap in value.resultMap }, "status": status, "type": type, "activeFrom": activeFrom, "arrangedPerilCategories": arrangedPerilCategories.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var renewal: Renewal? {
        get {
          return (resultMap["renewal"] as? ResultMap).flatMap { Renewal(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "renewal")
        }
      }

      public var status: InsuranceStatus {
        get {
          return resultMap["status"]! as! InsuranceStatus
        }
        set {
          resultMap.updateValue(newValue, forKey: "status")
        }
      }

      public var type: InsuranceType? {
        get {
          return resultMap["type"] as? InsuranceType
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var activeFrom: String? {
        get {
          return resultMap["activeFrom"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "activeFrom")
        }
      }

      public var arrangedPerilCategories: ArrangedPerilCategory {
        get {
          return ArrangedPerilCategory(unsafeResultMap: resultMap["arrangedPerilCategories"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "arrangedPerilCategories")
        }
      }

      public struct Renewal: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Renewal"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("certificateUrl", type: .nonNull(.scalar(String.self))),
          GraphQLField("date", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(certificateUrl: String, date: String) {
          self.init(unsafeResultMap: ["__typename": "Renewal", "certificateUrl": certificateUrl, "date": date])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var certificateUrl: String {
          get {
            return resultMap["certificateUrl"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "certificateUrl")
          }
        }

        public var date: String {
          get {
            return resultMap["date"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "date")
          }
        }
      }

      public struct ArrangedPerilCategory: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ArrangedPerilCategories"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("stuff", type: .object(Stuff.selections)),
          GraphQLField("home", type: .object(Home.selections)),
          GraphQLField("me", type: .object(Me.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(stuff: Stuff? = nil, home: Home? = nil, me: Me? = nil) {
          self.init(unsafeResultMap: ["__typename": "ArrangedPerilCategories", "stuff": stuff.flatMap { (value: Stuff) -> ResultMap in value.resultMap }, "home": home.flatMap { (value: Home) -> ResultMap in value.resultMap }, "me": me.flatMap { (value: Me) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var stuff: Stuff? {
          get {
            return (resultMap["stuff"] as? ResultMap).flatMap { Stuff(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "stuff")
          }
        }

        public var home: Home? {
          get {
            return (resultMap["home"] as? ResultMap).flatMap { Home(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "home")
          }
        }

        public var me: Me? {
          get {
            return (resultMap["me"] as? ResultMap).flatMap { Me(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "me")
          }
        }

        public struct Stuff: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PerilCategory"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("perils", type: .list(.object(Peril.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(title: String? = nil, description: String? = nil, perils: [Peril?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "PerilCategory", "title": title, "description": description, "perils": perils.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var title: String? {
            get {
              return resultMap["title"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var perils: [Peril?]? {
            get {
              return (resultMap["perils"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Peril?] in value.map { (value: ResultMap?) -> Peril? in value.flatMap { (value: ResultMap) -> Peril in Peril(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }, forKey: "perils")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var perilCategoryFragment: PerilCategoryFragment {
              get {
                return PerilCategoryFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Peril: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Peril"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(GraphQLID.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID? = nil, title: String? = nil, description: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Peril", "id": id, "title": title, "description": description])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID? {
              get {
                return resultMap["id"] as? GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var title: String? {
              get {
                return resultMap["title"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "title")
              }
            }

            public var description: String? {
              get {
                return resultMap["description"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }
          }
        }

        public struct Home: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PerilCategory"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("perils", type: .list(.object(Peril.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(title: String? = nil, description: String? = nil, perils: [Peril?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "PerilCategory", "title": title, "description": description, "perils": perils.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var title: String? {
            get {
              return resultMap["title"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var perils: [Peril?]? {
            get {
              return (resultMap["perils"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Peril?] in value.map { (value: ResultMap?) -> Peril? in value.flatMap { (value: ResultMap) -> Peril in Peril(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }, forKey: "perils")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var perilCategoryFragment: PerilCategoryFragment {
              get {
                return PerilCategoryFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Peril: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Peril"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(GraphQLID.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID? = nil, title: String? = nil, description: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Peril", "id": id, "title": title, "description": description])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID? {
              get {
                return resultMap["id"] as? GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var title: String? {
              get {
                return resultMap["title"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "title")
              }
            }

            public var description: String? {
              get {
                return resultMap["description"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }
          }
        }

        public struct Me: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PerilCategory"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("perils", type: .list(.object(Peril.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(title: String? = nil, description: String? = nil, perils: [Peril?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "PerilCategory", "title": title, "description": description, "perils": perils.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var title: String? {
            get {
              return resultMap["title"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var perils: [Peril?]? {
            get {
              return (resultMap["perils"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Peril?] in value.map { (value: ResultMap?) -> Peril? in value.flatMap { (value: ResultMap) -> Peril in Peril(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }, forKey: "perils")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var perilCategoryFragment: PerilCategoryFragment {
              get {
                return PerilCategoryFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Peril: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Peril"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(GraphQLID.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID? = nil, title: String? = nil, description: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Peril", "id": id, "title": title, "description": description])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID? {
              get {
                return resultMap["id"] as? GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var title: String? {
              get {
                return resultMap["title"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "title")
              }
            }

            public var description: String? {
              get {
                return resultMap["description"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }
          }
        }
      }
    }

    public struct Member: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("firstName", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(firstName: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Member", "firstName": firstName])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var firstName: String? {
        get {
          return resultMap["firstName"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "firstName")
        }
      }
    }
  }
}

public final class DeleteKeyGearItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteKeyGearItem($id: ID!) {
      deleteKeyGearItem(id: $id) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "DeleteKeyGearItem"

  public let operationIdentifier: String? = "e77a739f328a35991889f78fff3caad1a710e33b58b3ea1e752718311250cfdd"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteKeyGearItem", arguments: ["id": GraphQLVariable("id")], type: .nonNull(.object(DeleteKeyGearItem.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteKeyGearItem: DeleteKeyGearItem) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteKeyGearItem": deleteKeyGearItem.resultMap])
    }

    /// """
    /// When we've deleted an item, we mark it as deleted and should probably redact all information
    /// except for the physicalReferenceHash.
    /// """
    public var deleteKeyGearItem: DeleteKeyGearItem {
      get {
        return DeleteKeyGearItem(unsafeResultMap: resultMap["deleteKeyGearItem"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "deleteKeyGearItem")
      }
    }

    public struct DeleteKeyGearItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class EditLastResponseMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation EditLastResponse {
      editLastResponse
    }
    """

  public let operationName: String = "EditLastResponse"

  public let operationIdentifier: String? = "21d095779185790a54c7839bc6b860f8c3dad9261b4d290b7ca2838181f14be9"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("editLastResponse", type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(editLastResponse: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "editLastResponse": editLastResponse])
    }

    public var editLastResponse: Bool {
      get {
        return resultMap["editLastResponse"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "editLastResponse")
      }
    }
  }
}

public final class EligibleToCreateClaimQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query EligibleToCreateClaim {
      isEligibleToCreateClaim
    }
    """

  public let operationName: String = "EligibleToCreateClaim"

  public let operationIdentifier: String? = "fb49ab9a5193f384eb6d6e2d324b04a5284c5746fb4ef83afcef5bb54da088c6"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("isEligibleToCreateClaim", type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(isEligibleToCreateClaim: Bool) {
      self.init(unsafeResultMap: ["__typename": "Query", "isEligibleToCreateClaim": isEligibleToCreateClaim])
    }

    /// Returns whether a member is eligible to create a claim, i.e. if a member has an active contract
    public var isEligibleToCreateClaim: Bool {
      get {
        return resultMap["isEligibleToCreateClaim"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "isEligibleToCreateClaim")
      }
    }
  }
}

public final class FeaturesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Features {
      member {
        __typename
        features
      }
    }
    """

  public let operationName: String = "Features"

  public let operationIdentifier: String? = "9b11e13d9ff4f08be489296830865ba5275d0fc0dbcee0ea37393d49f8b5d539"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("member", type: .nonNull(.object(Member.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(member: Member) {
      self.init(unsafeResultMap: ["__typename": "Query", "member": member.resultMap])
    }

    public var member: Member {
      get {
        return Member(unsafeResultMap: resultMap["member"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "member")
      }
    }

    public struct Member: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("features", type: .nonNull(.list(.nonNull(.scalar(Feature.self))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(features: [Feature]) {
        self.init(unsafeResultMap: ["__typename": "Member", "features": features])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var features: [Feature] {
        get {
          return resultMap["features"]! as! [Feature]
        }
        set {
          resultMap.updateValue(newValue, forKey: "features")
        }
      }
    }
  }
}

public final class GeoQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Geo {
      geo {
        __typename
        countryISOCode
      }
    }
    """

  public let operationName: String = "Geo"

  public let operationIdentifier: String? = "fb1bd3cee9c6cea351932922e0a30a591eb330f70c02c57a6725b79c89d9b2d9"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("geo", type: .nonNull(.object(Geo.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(geo: Geo) {
      self.init(unsafeResultMap: ["__typename": "Query", "geo": geo.resultMap])
    }

    public var geo: Geo {
      get {
        return Geo(unsafeResultMap: resultMap["geo"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "geo")
      }
    }

    public struct Geo: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Geo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("countryISOCode", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(countryIsoCode: String) {
        self.init(unsafeResultMap: ["__typename": "Geo", "countryISOCode": countryIsoCode])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var countryIsoCode: String {
        get {
          return resultMap["countryISOCode"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "countryISOCode")
        }
      }
    }
  }
}

public final class GifQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GIF($query: String!) {
      gifs(query: $query) {
        __typename
        url
      }
    }
    """

  public let operationName: String = "GIF"

  public let operationIdentifier: String? = "5afb304b4d5b6a803c57595f062d5e111e64d802d5cec5979ad111938398afda"

  public var query: String

  public init(query: String) {
    self.query = query
  }

  public var variables: GraphQLMap? {
    return ["query": query]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("gifs", arguments: ["query": GraphQLVariable("query")], type: .nonNull(.list(.object(Gif.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(gifs: [Gif?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "gifs": gifs.map { (value: Gif?) -> ResultMap? in value.flatMap { (value: Gif) -> ResultMap in value.resultMap } }])
    }

    public var gifs: [Gif?] {
      get {
        return (resultMap["gifs"] as! [ResultMap?]).map { (value: ResultMap?) -> Gif? in value.flatMap { (value: ResultMap) -> Gif in Gif(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Gif?) -> ResultMap? in value.flatMap { (value: Gif) -> ResultMap in value.resultMap } }, forKey: "gifs")
      }
    }

    public struct Gif: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Gif"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("url", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(url: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Gif", "url": url])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var url: String? {
        get {
          return resultMap["url"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "url")
        }
      }
    }
  }
}

public final class ImportantMessagesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ImportantMessages($languageCode: String!) {
      importantMessages(where: {language: {code: $languageCode}}) {
        __typename
        title
        message
        button
        link
      }
    }
    """

  public let operationName: String = "ImportantMessages"

  public let operationIdentifier: String? = "66f07b898756df09750b9dbedff17e3dc0fbd7ef10546d196509e8e88b37629f"

  public var languageCode: String

  public init(languageCode: String) {
    self.languageCode = languageCode
  }

  public var variables: GraphQLMap? {
    return ["languageCode": languageCode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("importantMessages", arguments: ["where": ["language": ["code": GraphQLVariable("languageCode")]]], type: .nonNull(.list(.object(ImportantMessage.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(importantMessages: [ImportantMessage?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "importantMessages": importantMessages.map { (value: ImportantMessage?) -> ResultMap? in value.flatMap { (value: ImportantMessage) -> ResultMap in value.resultMap } }])
    }

    public var importantMessages: [ImportantMessage?] {
      get {
        return (resultMap["importantMessages"] as! [ResultMap?]).map { (value: ResultMap?) -> ImportantMessage? in value.flatMap { (value: ResultMap) -> ImportantMessage in ImportantMessage(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: ImportantMessage?) -> ResultMap? in value.flatMap { (value: ImportantMessage) -> ResultMap in value.resultMap } }, forKey: "importantMessages")
      }
    }

    public struct ImportantMessage: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ImportantMessage"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .scalar(String.self)),
        GraphQLField("message", type: .scalar(String.self)),
        GraphQLField("button", type: .scalar(String.self)),
        GraphQLField("link", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(title: String? = nil, message: String? = nil, button: String? = nil, link: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "ImportantMessage", "title": title, "message": message, "button": button, "link": link])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var title: String? {
        get {
          return resultMap["title"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public var message: String? {
        get {
          return resultMap["message"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "message")
        }
      }

      public var button: String? {
        get {
          return resultMap["button"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "button")
        }
      }

      public var link: String? {
        get {
          return resultMap["link"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "link")
        }
      }
    }
  }
}

public final class InsurancePriceQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query InsurancePrice {
      insuranceCost {
        __typename
        ...CostFragment
      }
    }
    """

  public let operationName: String = "InsurancePrice"

  public let operationIdentifier: String? = "ab26beb247da274219e8c38ee917d3017b74ef8762a4890ee2bb0f5ebf901638"

  public var queryDocument: String { return operationDefinition.appending(CostFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("insuranceCost", type: .object(InsuranceCost.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(insuranceCost: InsuranceCost? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "insuranceCost": insuranceCost.flatMap { (value: InsuranceCost) -> ResultMap in value.resultMap }])
    }

    /// Returns the aggregated insurance cost of a member's PENDING, ACTIVE or ACTIVE_IN_FUTURE current agreements
    public var insuranceCost: InsuranceCost? {
      get {
        return (resultMap["insuranceCost"] as? ResultMap).flatMap { InsuranceCost(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "insuranceCost")
      }
    }

    public struct InsuranceCost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["InsuranceCost"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("freeUntil", type: .scalar(String.self)),
        GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
        GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
        GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
        self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var freeUntil: String? {
        get {
          return resultMap["freeUntil"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "freeUntil")
        }
      }

      public var monthlyDiscount: MonthlyDiscount {
        get {
          return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
        }
      }

      public var monthlyGross: MonthlyGross {
        get {
          return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
        }
      }

      public var monthlyNet: MonthlyNet {
        get {
          return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var costFragment: CostFragment {
          get {
            return CostFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct MonthlyDiscount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyGross: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyNet: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }
    }
  }
}

public final class KeyGearClassifierQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query KeyGearClassifier {
      coreMLModels(where: {type: KeyGearClassifier}) {
        __typename
        file {
          __typename
          url
        }
      }
    }
    """

  public let operationName: String = "KeyGearClassifier"

  public let operationIdentifier: String? = "5590aa08c57a79a8bc177bb5c825cead675f3f4cab53c3858cd3728afc1d7882"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("coreMLModels", arguments: ["where": ["type": "KeyGearClassifier"]], type: .nonNull(.list(.object(CoreMlModel.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(coreMlModels: [CoreMlModel?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "coreMLModels": coreMlModels.map { (value: CoreMlModel?) -> ResultMap? in value.flatMap { (value: CoreMlModel) -> ResultMap in value.resultMap } }])
    }

    public var coreMlModels: [CoreMlModel?] {
      get {
        return (resultMap["coreMLModels"] as! [ResultMap?]).map { (value: ResultMap?) -> CoreMlModel? in value.flatMap { (value: ResultMap) -> CoreMlModel in CoreMlModel(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: CoreMlModel?) -> ResultMap? in value.flatMap { (value: CoreMlModel) -> ResultMap in value.resultMap } }, forKey: "coreMLModels")
      }
    }

    public struct CoreMlModel: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CoreMLModel"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("file", type: .object(File.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(file: File? = nil) {
        self.init(unsafeResultMap: ["__typename": "CoreMLModel", "file": file.flatMap { (value: File) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var file: File? {
        get {
          return (resultMap["file"] as? ResultMap).flatMap { File(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "file")
        }
      }

      public struct File: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Asset"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String) {
          self.init(unsafeResultMap: ["__typename": "Asset", "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Get the url for the asset with provided transformations applied.
        public var url: String {
          get {
            return resultMap["url"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }
    }
  }
}

public final class KeyGearItemQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query KeyGearItem($id: ID!, $languageCode: String!) {
      keyGearItem(id: $id) {
        __typename
        name
        category
        purchasePrice {
          __typename
          ...MonetaryAmountFragment
        }
        deductible {
          __typename
          ...MonetaryAmountFragment
        }
        maxInsurableAmount {
          __typename
          ...MonetaryAmountFragment
        }
        valuation {
          __typename
          ... on KeyGearItemValuationFixed {
            ratio
            valuation {
              __typename
              ...MonetaryAmountFragment
            }
          }
          ... on KeyGearItemValuationMarketValue {
            ratio
          }
        }
        photos {
          __typename
          file {
            __typename
            preSignedUrl
          }
        }
        receipts {
          __typename
          file {
            __typename
            preSignedUrl
          }
        }
        covered {
          __typename
          title {
            __typename
            translations(where: {language: {code: $languageCode}, project: IOS}) {
              __typename
              text
            }
          }
        }
        exceptions {
          __typename
          title {
            __typename
            translations(where: {language: {code: $languageCode}, project: IOS}) {
              __typename
              text
            }
          }
        }
      }
    }
    """

  public let operationName: String = "KeyGearItem"

  public let operationIdentifier: String? = "2ce6e12c1723a0a75bf9582761dbbbff9dc3a2fc4365e7db22129f71cc058f0b"

  public var queryDocument: String { return operationDefinition.appending(MonetaryAmountFragment.fragmentDefinition) }

  public var id: GraphQLID
  public var languageCode: String

  public init(id: GraphQLID, languageCode: String) {
    self.id = id
    self.languageCode = languageCode
  }

  public var variables: GraphQLMap? {
    return ["id": id, "languageCode": languageCode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("keyGearItem", arguments: ["id": GraphQLVariable("id")], type: .object(KeyGearItem.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(keyGearItem: KeyGearItem? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "keyGearItem": keyGearItem.flatMap { (value: KeyGearItem) -> ResultMap in value.resultMap }])
    }

    public var keyGearItem: KeyGearItem? {
      get {
        return (resultMap["keyGearItem"] as? ResultMap).flatMap { KeyGearItem(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "keyGearItem")
      }
    }

    public struct KeyGearItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("category", type: .nonNull(.scalar(KeyGearItemCategory.self))),
        GraphQLField("purchasePrice", type: .object(PurchasePrice.selections)),
        GraphQLField("deductible", type: .nonNull(.object(Deductible.selections))),
        GraphQLField("maxInsurableAmount", type: .object(MaxInsurableAmount.selections)),
        GraphQLField("valuation", type: .object(Valuation.selections)),
        GraphQLField("photos", type: .nonNull(.list(.nonNull(.object(Photo.selections))))),
        GraphQLField("receipts", type: .nonNull(.list(.nonNull(.object(Receipt.selections))))),
        GraphQLField("covered", type: .nonNull(.list(.nonNull(.object(Covered.selections))))),
        GraphQLField("exceptions", type: .nonNull(.list(.nonNull(.object(Exception.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String? = nil, category: KeyGearItemCategory, purchasePrice: PurchasePrice? = nil, deductible: Deductible, maxInsurableAmount: MaxInsurableAmount? = nil, valuation: Valuation? = nil, photos: [Photo], receipts: [Receipt], covered: [Covered], exceptions: [Exception]) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "name": name, "category": category, "purchasePrice": purchasePrice.flatMap { (value: PurchasePrice) -> ResultMap in value.resultMap }, "deductible": deductible.resultMap, "maxInsurableAmount": maxInsurableAmount.flatMap { (value: MaxInsurableAmount) -> ResultMap in value.resultMap }, "valuation": valuation.flatMap { (value: Valuation) -> ResultMap in value.resultMap }, "photos": photos.map { (value: Photo) -> ResultMap in value.resultMap }, "receipts": receipts.map { (value: Receipt) -> ResultMap in value.resultMap }, "covered": covered.map { (value: Covered) -> ResultMap in value.resultMap }, "exceptions": exceptions.map { (value: Exception) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// If this item was added automatically - what was the Hash of the identifiable information?
      /// Use this to avoid automatically adding an Item which the user has already automatically added or
      /// does not wish to have automatically added
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var category: KeyGearItemCategory {
        get {
          return resultMap["category"]! as! KeyGearItemCategory
        }
        set {
          resultMap.updateValue(newValue, forKey: "category")
        }
      }

      public var purchasePrice: PurchasePrice? {
        get {
          return (resultMap["purchasePrice"] as? ResultMap).flatMap { PurchasePrice(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "purchasePrice")
        }
      }

      public var deductible: Deductible {
        get {
          return Deductible(unsafeResultMap: resultMap["deductible"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "deductible")
        }
      }

      public var maxInsurableAmount: MaxInsurableAmount? {
        get {
          return (resultMap["maxInsurableAmount"] as? ResultMap).flatMap { MaxInsurableAmount(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "maxInsurableAmount")
        }
      }

      public var valuation: Valuation? {
        get {
          return (resultMap["valuation"] as? ResultMap).flatMap { Valuation(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "valuation")
        }
      }

      public var photos: [Photo] {
        get {
          return (resultMap["photos"] as! [ResultMap]).map { (value: ResultMap) -> Photo in Photo(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Photo) -> ResultMap in value.resultMap }, forKey: "photos")
        }
      }

      public var receipts: [Receipt] {
        get {
          return (resultMap["receipts"] as! [ResultMap]).map { (value: ResultMap) -> Receipt in Receipt(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Receipt) -> ResultMap in value.resultMap }, forKey: "receipts")
        }
      }

      public var covered: [Covered] {
        get {
          return (resultMap["covered"] as! [ResultMap]).map { (value: ResultMap) -> Covered in Covered(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Covered) -> ResultMap in value.resultMap }, forKey: "covered")
        }
      }

      public var exceptions: [Exception] {
        get {
          return (resultMap["exceptions"] as! [ResultMap]).map { (value: ResultMap) -> Exception in Exception(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Exception) -> ResultMap in value.resultMap }, forKey: "exceptions")
        }
      }

      public struct PurchasePrice: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Deductible: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct MaxInsurableAmount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Valuation: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemValuationFixed", "KeyGearItemValuationMarketValue"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["KeyGearItemValuationFixed": AsKeyGearItemValuationFixed.selections, "KeyGearItemValuationMarketValue": AsKeyGearItemValuationMarketValue.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeKeyGearItemValuationFixed(ratio: Int, valuation: AsKeyGearItemValuationFixed.Valuation) -> Valuation {
          return Valuation(unsafeResultMap: ["__typename": "KeyGearItemValuationFixed", "ratio": ratio, "valuation": valuation.resultMap])
        }

        public static func makeKeyGearItemValuationMarketValue(ratio: Int) -> Valuation {
          return Valuation(unsafeResultMap: ["__typename": "KeyGearItemValuationMarketValue", "ratio": ratio])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asKeyGearItemValuationFixed: AsKeyGearItemValuationFixed? {
          get {
            if !AsKeyGearItemValuationFixed.possibleTypes.contains(__typename) { return nil }
            return AsKeyGearItemValuationFixed(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsKeyGearItemValuationFixed: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["KeyGearItemValuationFixed"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("ratio", type: .nonNull(.scalar(Int.self))),
            GraphQLField("valuation", type: .nonNull(.object(Valuation.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(ratio: Int, valuation: Valuation) {
            self.init(unsafeResultMap: ["__typename": "KeyGearItemValuationFixed", "ratio": ratio, "valuation": valuation.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Value between 100 and 0 which corresponds to the percentage of the item's value relative to purchase price
          public var ratio: Int {
            get {
              return resultMap["ratio"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "ratio")
            }
          }

          public var valuation: Valuation {
            get {
              return Valuation(unsafeResultMap: resultMap["valuation"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "valuation")
            }
          }

          public struct Valuation: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonetaryAmountV2"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .nonNull(.scalar(String.self))),
              GraphQLField("currency", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: String, currency: String) {
              self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: String {
              get {
                return resultMap["amount"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "amount")
              }
            }

            public var currency: String {
              get {
                return resultMap["currency"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "currency")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var monetaryAmountFragment: MonetaryAmountFragment {
                get {
                  return MonetaryAmountFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }

        public var asKeyGearItemValuationMarketValue: AsKeyGearItemValuationMarketValue? {
          get {
            if !AsKeyGearItemValuationMarketValue.possibleTypes.contains(__typename) { return nil }
            return AsKeyGearItemValuationMarketValue(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsKeyGearItemValuationMarketValue: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["KeyGearItemValuationMarketValue"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("ratio", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(ratio: Int) {
            self.init(unsafeResultMap: ["__typename": "KeyGearItemValuationMarketValue", "ratio": ratio])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Value between 100 and 0 which corresponds to the percentage of the item's value relative to current market value
          public var ratio: Int {
            get {
              return resultMap["ratio"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "ratio")
            }
          }
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemPhoto"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("file", type: .nonNull(.object(File.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(file: File) {
          self.init(unsafeResultMap: ["__typename": "KeyGearItemPhoto", "file": file.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var file: File {
          get {
            return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "file")
          }
        }

        public struct File: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["S3File"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("preSignedUrl", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(preSignedUrl: String) {
            self.init(unsafeResultMap: ["__typename": "S3File", "preSignedUrl": preSignedUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var preSignedUrl: String {
            get {
              return resultMap["preSignedUrl"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preSignedUrl")
            }
          }
        }
      }

      public struct Receipt: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemReceipt"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("file", type: .nonNull(.object(File.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(file: File) {
          self.init(unsafeResultMap: ["__typename": "KeyGearItemReceipt", "file": file.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var file: File {
          get {
            return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "file")
          }
        }

        public struct File: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["S3File"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("preSignedUrl", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(preSignedUrl: String) {
            self.init(unsafeResultMap: ["__typename": "S3File", "preSignedUrl": preSignedUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var preSignedUrl: String {
            get {
              return resultMap["preSignedUrl"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preSignedUrl")
            }
          }
        }
      }

      public struct Covered: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemCoverage"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .object(Title.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(title: Title? = nil) {
          self.init(unsafeResultMap: ["__typename": "KeyGearItemCoverage", "title": title.flatMap { (value: Title) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var title: Title? {
          get {
            return (resultMap["title"] as? ResultMap).flatMap { Title(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "title")
          }
        }

        public struct Title: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Key"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("translations", arguments: ["where": ["language": ["code": GraphQLVariable("languageCode")], "project": "IOS"]], type: .list(.nonNull(.object(Translation.selections)))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(translations: [Translation]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Key", "translations": translations.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var translations: [Translation]? {
            get {
              return (resultMap["translations"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Translation] in value.map { (value: ResultMap) -> Translation in Translation(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }, forKey: "translations")
            }
          }

          public struct Translation: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Translation"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(text: String) {
              self.init(unsafeResultMap: ["__typename": "Translation", "text": text])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var text: String {
              get {
                return resultMap["text"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "text")
              }
            }
          }
        }
      }

      public struct Exception: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemCoverage"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .object(Title.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(title: Title? = nil) {
          self.init(unsafeResultMap: ["__typename": "KeyGearItemCoverage", "title": title.flatMap { (value: Title) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var title: Title? {
          get {
            return (resultMap["title"] as? ResultMap).flatMap { Title(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "title")
          }
        }

        public struct Title: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Key"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("translations", arguments: ["where": ["language": ["code": GraphQLVariable("languageCode")], "project": "IOS"]], type: .list(.nonNull(.object(Translation.selections)))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(translations: [Translation]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Key", "translations": translations.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var translations: [Translation]? {
            get {
              return (resultMap["translations"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Translation] in value.map { (value: ResultMap) -> Translation in Translation(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }, forKey: "translations")
            }
          }

          public struct Translation: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Translation"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(text: String) {
              self.init(unsafeResultMap: ["__typename": "Translation", "text": text])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var text: String {
              get {
                return resultMap["text"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "text")
              }
            }
          }
        }
      }
    }
  }
}

public final class KeyGearItemsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query KeyGearItems {
      keyGearItems(where: {deleted: false}) {
        __typename
        id
        name
        deleted
        physicalReferenceHash
        photos {
          __typename
          id
          file {
            __typename
            preSignedUrl
          }
        }
        category
        receipts {
          __typename
          id
          file {
            __typename
            preSignedUrl
          }
        }
        purchasePrice {
          __typename
          ...MonetaryAmountFragment
        }
        timeOfPurchase
      }
    }
    """

  public let operationName: String = "KeyGearItems"

  public let operationIdentifier: String? = "81640379c4d30c419435d68204a413df53e0c4f6ecd048e791d28a5985be1965"

  public var queryDocument: String { return operationDefinition.appending(MonetaryAmountFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("keyGearItems", arguments: ["where": ["deleted": false]], type: .nonNull(.list(.nonNull(.object(KeyGearItem.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(keyGearItems: [KeyGearItem]) {
      self.init(unsafeResultMap: ["__typename": "Query", "keyGearItems": keyGearItems.map { (value: KeyGearItem) -> ResultMap in value.resultMap }])
    }

    /// Used
    public var keyGearItems: [KeyGearItem] {
      get {
        return (resultMap["keyGearItems"] as! [ResultMap]).map { (value: ResultMap) -> KeyGearItem in KeyGearItem(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: KeyGearItem) -> ResultMap in value.resultMap }, forKey: "keyGearItems")
      }
    }

    public struct KeyGearItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("deleted", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("physicalReferenceHash", type: .scalar(String.self)),
        GraphQLField("photos", type: .nonNull(.list(.nonNull(.object(Photo.selections))))),
        GraphQLField("category", type: .nonNull(.scalar(KeyGearItemCategory.self))),
        GraphQLField("receipts", type: .nonNull(.list(.nonNull(.object(Receipt.selections))))),
        GraphQLField("purchasePrice", type: .object(PurchasePrice.selections)),
        GraphQLField("timeOfPurchase", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: String? = nil, deleted: Bool, physicalReferenceHash: String? = nil, photos: [Photo], category: KeyGearItemCategory, receipts: [Receipt], purchasePrice: PurchasePrice? = nil, timeOfPurchase: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "id": id, "name": name, "deleted": deleted, "physicalReferenceHash": physicalReferenceHash, "photos": photos.map { (value: Photo) -> ResultMap in value.resultMap }, "category": category, "receipts": receipts.map { (value: Receipt) -> ResultMap in value.resultMap }, "purchasePrice": purchasePrice.flatMap { (value: PurchasePrice) -> ResultMap in value.resultMap }, "timeOfPurchase": timeOfPurchase])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// If this item was added automatically - what was the Hash of the identifiable information?
      /// Use this to avoid automatically adding an Item which the user has already automatically added or
      /// does not wish to have automatically added
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var deleted: Bool {
        get {
          return resultMap["deleted"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "deleted")
        }
      }

      public var physicalReferenceHash: String? {
        get {
          return resultMap["physicalReferenceHash"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "physicalReferenceHash")
        }
      }

      public var photos: [Photo] {
        get {
          return (resultMap["photos"] as! [ResultMap]).map { (value: ResultMap) -> Photo in Photo(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Photo) -> ResultMap in value.resultMap }, forKey: "photos")
        }
      }

      public var category: KeyGearItemCategory {
        get {
          return resultMap["category"]! as! KeyGearItemCategory
        }
        set {
          resultMap.updateValue(newValue, forKey: "category")
        }
      }

      public var receipts: [Receipt] {
        get {
          return (resultMap["receipts"] as! [ResultMap]).map { (value: ResultMap) -> Receipt in Receipt(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Receipt) -> ResultMap in value.resultMap }, forKey: "receipts")
        }
      }

      public var purchasePrice: PurchasePrice? {
        get {
          return (resultMap["purchasePrice"] as? ResultMap).flatMap { PurchasePrice(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "purchasePrice")
        }
      }

      public var timeOfPurchase: String? {
        get {
          return resultMap["timeOfPurchase"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "timeOfPurchase")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemPhoto"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("file", type: .nonNull(.object(File.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, file: File) {
          self.init(unsafeResultMap: ["__typename": "KeyGearItemPhoto", "id": id, "file": file.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var file: File {
          get {
            return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "file")
          }
        }

        public struct File: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["S3File"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("preSignedUrl", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(preSignedUrl: String) {
            self.init(unsafeResultMap: ["__typename": "S3File", "preSignedUrl": preSignedUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var preSignedUrl: String {
            get {
              return resultMap["preSignedUrl"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preSignedUrl")
            }
          }
        }
      }

      public struct Receipt: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["KeyGearItemReceipt"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("file", type: .nonNull(.object(File.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, file: File) {
          self.init(unsafeResultMap: ["__typename": "KeyGearItemReceipt", "id": id, "file": file.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var file: File {
          get {
            return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "file")
          }
        }

        public struct File: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["S3File"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("preSignedUrl", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(preSignedUrl: String) {
            self.init(unsafeResultMap: ["__typename": "S3File", "preSignedUrl": preSignedUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var preSignedUrl: String {
            get {
              return resultMap["preSignedUrl"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preSignedUrl")
            }
          }
        }
      }

      public struct PurchasePrice: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public final class LogMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation Log($input: LoggingInput!) {
      log(input: $input)
    }
    """

  public let operationName: String = "Log"

  public let operationIdentifier: String? = "4a35fbef47e6941598e0c10d5865a2891e82ead4395fa99aad515285a3838e69"

  public var input: LoggingInput

  public init(input: LoggingInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("log", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(log: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "log": log])
    }

    public var log: Bool? {
      get {
        return resultMap["log"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "log")
      }
    }
  }
}

public final class LogoutMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation Logout {
      logout
    }
    """

  public let operationName: String = "Logout"

  public let operationIdentifier: String? = "d33294c28ffdaff741dcadc2dba75b4013cdc29cd5f9e8f61d3ac85d57868a04"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("logout", type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(logout: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "logout": logout])
    }

    public var logout: Bool {
      get {
        return resultMap["logout"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "logout")
      }
    }
  }
}

public final class MarketingQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Marketing {
      appMarketingImages {
        __typename
        language {
          __typename
          code
        }
        image {
          __typename
          url
        }
        blurhash
      }
    }
    """

  public let operationName: String = "Marketing"

  public let operationIdentifier: String? = "d282ab5247166924c4dc64b21b03da7e41bf53da1d6c376e8ad54fcf452a0644"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("appMarketingImages", type: .nonNull(.list(.object(AppMarketingImage.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(appMarketingImages: [AppMarketingImage?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "appMarketingImages": appMarketingImages.map { (value: AppMarketingImage?) -> ResultMap? in value.flatMap { (value: AppMarketingImage) -> ResultMap in value.resultMap } }])
    }

    public var appMarketingImages: [AppMarketingImage?] {
      get {
        return (resultMap["appMarketingImages"] as! [ResultMap?]).map { (value: ResultMap?) -> AppMarketingImage? in value.flatMap { (value: ResultMap) -> AppMarketingImage in AppMarketingImage(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: AppMarketingImage?) -> ResultMap? in value.flatMap { (value: AppMarketingImage) -> ResultMap in value.resultMap } }, forKey: "appMarketingImages")
      }
    }

    public struct AppMarketingImage: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AppMarketingImage"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("language", type: .object(Language.selections)),
        GraphQLField("image", type: .object(Image.selections)),
        GraphQLField("blurhash", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(language: Language? = nil, image: Image? = nil, blurhash: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "AppMarketingImage", "language": language.flatMap { (value: Language) -> ResultMap in value.resultMap }, "image": image.flatMap { (value: Image) -> ResultMap in value.resultMap }, "blurhash": blurhash])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var language: Language? {
        get {
          return (resultMap["language"] as? ResultMap).flatMap { Language(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "language")
        }
      }

      public var image: Image? {
        get {
          return (resultMap["image"] as? ResultMap).flatMap { Image(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "image")
        }
      }

      public var blurhash: String? {
        get {
          return resultMap["blurhash"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "blurhash")
        }
      }

      public struct Language: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Language"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("code", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(code: String) {
          self.init(unsafeResultMap: ["__typename": "Language", "code": code])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var code: String {
          get {
            return resultMap["code"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "code")
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Asset"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String) {
          self.init(unsafeResultMap: ["__typename": "Asset", "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Get the url for the asset with provided transformations applied.
        public var url: String {
          get {
            return resultMap["url"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }
    }
  }
}

public final class MemberIdQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query MemberId {
      member {
        __typename
        id
      }
    }
    """

  public let operationName: String = "MemberId"

  public let operationIdentifier: String? = "7e1bbfdb096bc0a25739d52da1835166da5905cdab859608f1a3c088226bde57"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("member", type: .nonNull(.object(Member.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(member: Member) {
      self.init(unsafeResultMap: ["__typename": "Query", "member": member.resultMap])
    }

    public var member: Member {
      get {
        return Member(unsafeResultMap: resultMap["member"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "member")
      }
    }

    public struct Member: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(GraphQLID.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil) {
        self.init(unsafeResultMap: ["__typename": "Member", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class MyHomeQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query MyHome {
      insurance {
        __typename
        address
        postalNumber
        type
        livingSpace
        ancillaryArea
        yearOfConstruction
        numberOfBathrooms
        extraBuildings {
          __typename
          ...ExtraBuildingFragment
        }
        isSubleted
      }
    }
    """

  public let operationName: String = "MyHome"

  public let operationIdentifier: String? = "a0942551a7e4f4e1b24726330ea501a757dd9cd69e8cced1413911a0ff4778bc"

  public var queryDocument: String { return operationDefinition.appending(ExtraBuildingFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("insurance", type: .nonNull(.object(Insurance.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(insurance: Insurance) {
      self.init(unsafeResultMap: ["__typename": "Query", "insurance": insurance.resultMap])
    }

    public var insurance: Insurance {
      get {
        return Insurance(unsafeResultMap: resultMap["insurance"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "insurance")
      }
    }

    public struct Insurance: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Insurance"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .scalar(String.self)),
        GraphQLField("postalNumber", type: .scalar(String.self)),
        GraphQLField("type", type: .scalar(InsuranceType.self)),
        GraphQLField("livingSpace", type: .scalar(Int.self)),
        GraphQLField("ancillaryArea", type: .scalar(Int.self)),
        GraphQLField("yearOfConstruction", type: .scalar(Int.self)),
        GraphQLField("numberOfBathrooms", type: .scalar(Int.self)),
        GraphQLField("extraBuildings", type: .list(.nonNull(.object(ExtraBuilding.selections)))),
        GraphQLField("isSubleted", type: .scalar(Bool.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(address: String? = nil, postalNumber: String? = nil, type: InsuranceType? = nil, livingSpace: Int? = nil, ancillaryArea: Int? = nil, yearOfConstruction: Int? = nil, numberOfBathrooms: Int? = nil, extraBuildings: [ExtraBuilding]? = nil, isSubleted: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "Insurance", "address": address, "postalNumber": postalNumber, "type": type, "livingSpace": livingSpace, "ancillaryArea": ancillaryArea, "yearOfConstruction": yearOfConstruction, "numberOfBathrooms": numberOfBathrooms, "extraBuildings": extraBuildings.flatMap { (value: [ExtraBuilding]) -> [ResultMap] in value.map { (value: ExtraBuilding) -> ResultMap in value.resultMap } }, "isSubleted": isSubleted])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var address: String? {
        get {
          return resultMap["address"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "address")
        }
      }

      public var postalNumber: String? {
        get {
          return resultMap["postalNumber"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "postalNumber")
        }
      }

      public var type: InsuranceType? {
        get {
          return resultMap["type"] as? InsuranceType
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var livingSpace: Int? {
        get {
          return resultMap["livingSpace"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "livingSpace")
        }
      }

      public var ancillaryArea: Int? {
        get {
          return resultMap["ancillaryArea"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "ancillaryArea")
        }
      }

      public var yearOfConstruction: Int? {
        get {
          return resultMap["yearOfConstruction"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "yearOfConstruction")
        }
      }

      public var numberOfBathrooms: Int? {
        get {
          return resultMap["numberOfBathrooms"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "numberOfBathrooms")
        }
      }

      public var extraBuildings: [ExtraBuilding]? {
        get {
          return (resultMap["extraBuildings"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [ExtraBuilding] in value.map { (value: ResultMap) -> ExtraBuilding in ExtraBuilding(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ExtraBuilding]) -> [ResultMap] in value.map { (value: ExtraBuilding) -> ResultMap in value.resultMap } }, forKey: "extraBuildings")
        }
      }

      public var isSubleted: Bool? {
        get {
          return resultMap["isSubleted"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "isSubleted")
        }
      }

      public struct ExtraBuilding: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ExtraBuildingGarage", "ExtraBuildingCarport", "ExtraBuildingShed", "ExtraBuildingStorehouse", "ExtraBuildingFriggebod", "ExtraBuildingAttefall", "ExtraBuildingOuthouse", "ExtraBuildingGuesthouse", "ExtraBuildingGazebo", "ExtraBuildingGreenhouse", "ExtraBuildingSauna", "ExtraBuildingBarn", "ExtraBuildingBoathouse", "ExtraBuildingOther"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
          GraphQLField("area", type: .nonNull(.scalar(Int.self))),
          GraphQLField("hasWaterConnected", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeExtraBuildingGarage(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGarage", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingCarport(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingCarport", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingShed(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingShed", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingStorehouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingStorehouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingFriggebod(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingFriggebod", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingAttefall(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingAttefall", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingOuthouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingOuthouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingGuesthouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGuesthouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingGazebo(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGazebo", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingGreenhouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingGreenhouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingSauna(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingSauna", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingBarn(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingBarn", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingBoathouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingBoathouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public static func makeExtraBuildingOther(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuilding {
          return ExtraBuilding(unsafeResultMap: ["__typename": "ExtraBuildingOther", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var displayName: String {
          get {
            return resultMap["displayName"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "displayName")
          }
        }

        public var area: Int {
          get {
            return resultMap["area"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "area")
          }
        }

        public var hasWaterConnected: Bool {
          get {
            return resultMap["hasWaterConnected"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasWaterConnected")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var extraBuildingFragment: ExtraBuildingFragment {
            get {
              return ExtraBuildingFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public final class MyInfoQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query MyInfo {
      member {
        __typename
        firstName
        lastName
        email
        phoneNumber
      }
    }
    """

  public let operationName: String = "MyInfo"

  public let operationIdentifier: String? = "d4c2e2c963a39d5849cc5ba863a01abb39b8996ac2856e390f58ab5b394fed21"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("member", type: .nonNull(.object(Member.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(member: Member) {
      self.init(unsafeResultMap: ["__typename": "Query", "member": member.resultMap])
    }

    public var member: Member {
      get {
        return Member(unsafeResultMap: resultMap["member"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "member")
      }
    }

    public struct Member: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("firstName", type: .scalar(String.self)),
        GraphQLField("lastName", type: .scalar(String.self)),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(firstName: String? = nil, lastName: String? = nil, email: String? = nil, phoneNumber: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Member", "firstName": firstName, "lastName": lastName, "email": email, "phoneNumber": phoneNumber])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var firstName: String? {
        get {
          return resultMap["firstName"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "firstName")
        }
      }

      public var lastName: String? {
        get {
          return resultMap["lastName"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "lastName")
        }
      }

      public var email: String? {
        get {
          return resultMap["email"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "email")
        }
      }

      public var phoneNumber: String? {
        get {
          return resultMap["phoneNumber"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "phoneNumber")
        }
      }
    }
  }
}

public final class MyPaymentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query MyPayment {
      insuranceCost {
        __typename
        ...CostFragment
      }
      bankAccount {
        __typename
        bankName
        descriptor
      }
      nextChargeDate
      payinMethodStatus
      redeemedCampaigns {
        __typename
        ...CampaignFragment
      }
      balance {
        __typename
        currentBalance {
          __typename
          ...MonetaryAmountFragment
        }
        failedCharges
      }
      chargeEstimation {
        __typename
        charge {
          __typename
          ...MonetaryAmountFragment
        }
        discount {
          __typename
          ...MonetaryAmountFragment
        }
        subscription {
          __typename
          ...MonetaryAmountFragment
        }
      }
      chargeHistory {
        __typename
        amount {
          __typename
          ...MonetaryAmountFragment
        }
        date
      }
    }
    """

  public let operationName: String = "MyPayment"

  public let operationIdentifier: String? = "3cf9857ddf1b42c09b67ea686fc6c577c1554112ac2e7885a842caee21d59f32"

  public var queryDocument: String { return operationDefinition.appending(CostFragment.fragmentDefinition).appending(CampaignFragment.fragmentDefinition).appending(IncentiveFragment.fragmentDefinition).appending(MonetaryAmountFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("insuranceCost", type: .object(InsuranceCost.selections)),
      GraphQLField("bankAccount", type: .object(BankAccount.selections)),
      GraphQLField("nextChargeDate", type: .scalar(String.self)),
      GraphQLField("payinMethodStatus", type: .nonNull(.scalar(PayinMethodStatus.self))),
      GraphQLField("redeemedCampaigns", type: .nonNull(.list(.nonNull(.object(RedeemedCampaign.selections))))),
      GraphQLField("balance", type: .nonNull(.object(Balance.selections))),
      GraphQLField("chargeEstimation", type: .nonNull(.object(ChargeEstimation.selections))),
      GraphQLField("chargeHistory", type: .nonNull(.list(.nonNull(.object(ChargeHistory.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(insuranceCost: InsuranceCost? = nil, bankAccount: BankAccount? = nil, nextChargeDate: String? = nil, payinMethodStatus: PayinMethodStatus, redeemedCampaigns: [RedeemedCampaign], balance: Balance, chargeEstimation: ChargeEstimation, chargeHistory: [ChargeHistory]) {
      self.init(unsafeResultMap: ["__typename": "Query", "insuranceCost": insuranceCost.flatMap { (value: InsuranceCost) -> ResultMap in value.resultMap }, "bankAccount": bankAccount.flatMap { (value: BankAccount) -> ResultMap in value.resultMap }, "nextChargeDate": nextChargeDate, "payinMethodStatus": payinMethodStatus, "redeemedCampaigns": redeemedCampaigns.map { (value: RedeemedCampaign) -> ResultMap in value.resultMap }, "balance": balance.resultMap, "chargeEstimation": chargeEstimation.resultMap, "chargeHistory": chargeHistory.map { (value: ChargeHistory) -> ResultMap in value.resultMap }])
    }

    /// Returns the aggregated insurance cost of a member's PENDING, ACTIVE or ACTIVE_IN_FUTURE current agreements
    public var insuranceCost: InsuranceCost? {
      get {
        return (resultMap["insuranceCost"] as? ResultMap).flatMap { InsuranceCost(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "insuranceCost")
      }
    }

    public var bankAccount: BankAccount? {
      get {
        return (resultMap["bankAccount"] as? ResultMap).flatMap { BankAccount(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "bankAccount")
      }
    }

    public var nextChargeDate: String? {
      get {
        return resultMap["nextChargeDate"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "nextChargeDate")
      }
    }

    /// Returns the status for the payin method (Trustly's direct debit for Sweden) (Adyen for Norway)
    public var payinMethodStatus: PayinMethodStatus {
      get {
        return resultMap["payinMethodStatus"]! as! PayinMethodStatus
      }
      set {
        resultMap.updateValue(newValue, forKey: "payinMethodStatus")
      }
    }

    /// Returns redeemed campaigns belonging to authedUser
    public var redeemedCampaigns: [RedeemedCampaign] {
      get {
        return (resultMap["redeemedCampaigns"] as! [ResultMap]).map { (value: ResultMap) -> RedeemedCampaign in RedeemedCampaign(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: RedeemedCampaign) -> ResultMap in value.resultMap }, forKey: "redeemedCampaigns")
      }
    }

    public var balance: Balance {
      get {
        return Balance(unsafeResultMap: resultMap["balance"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "balance")
      }
    }

    public var chargeEstimation: ChargeEstimation {
      get {
        return ChargeEstimation(unsafeResultMap: resultMap["chargeEstimation"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "chargeEstimation")
      }
    }

    public var chargeHistory: [ChargeHistory] {
      get {
        return (resultMap["chargeHistory"] as! [ResultMap]).map { (value: ResultMap) -> ChargeHistory in ChargeHistory(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: ChargeHistory) -> ResultMap in value.resultMap }, forKey: "chargeHistory")
      }
    }

    public struct InsuranceCost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["InsuranceCost"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("freeUntil", type: .scalar(String.self)),
        GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
        GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
        GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
        self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var freeUntil: String? {
        get {
          return resultMap["freeUntil"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "freeUntil")
        }
      }

      public var monthlyDiscount: MonthlyDiscount {
        get {
          return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
        }
      }

      public var monthlyGross: MonthlyGross {
        get {
          return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
        }
      }

      public var monthlyNet: MonthlyNet {
        get {
          return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var costFragment: CostFragment {
          get {
            return CostFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct MonthlyDiscount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyGross: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyNet: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }
    }

    public struct BankAccount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["BankAccount"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bankName", type: .nonNull(.scalar(String.self))),
        GraphQLField("descriptor", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(bankName: String, descriptor: String) {
        self.init(unsafeResultMap: ["__typename": "BankAccount", "bankName": bankName, "descriptor": descriptor])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bankName: String {
        get {
          return resultMap["bankName"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "bankName")
        }
      }

      public var descriptor: String {
        get {
          return resultMap["descriptor"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "descriptor")
        }
      }
    }

    public struct RedeemedCampaign: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Campaign"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("incentive", type: .object(Incentive.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(code: String, incentive: Incentive? = nil) {
        self.init(unsafeResultMap: ["__typename": "Campaign", "code": code, "incentive": incentive.flatMap { (value: Incentive) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var code: String {
        get {
          return resultMap["code"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "code")
        }
      }

      public var incentive: Incentive? {
        get {
          return (resultMap["incentive"] as? ResultMap).flatMap { Incentive(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "incentive")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var campaignFragment: CampaignFragment {
          get {
            return CampaignFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Incentive: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonthlyCostDeduction", "FreeMonths", "NoDiscount", "PercentageDiscountMonths"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["FreeMonths": AsFreeMonths.selections, "MonthlyCostDeduction": AsMonthlyCostDeduction.selections, "PercentageDiscountMonths": AsPercentageDiscountMonths.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeNoDiscount() -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "NoDiscount"])
        }

        public static func makeFreeMonths(quantity: Int? = nil) -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
        }

        public static func makeMonthlyCostDeduction(amount: AsMonthlyCostDeduction.Amount? = nil) -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: AsMonthlyCostDeduction.Amount) -> ResultMap in value.resultMap }])
        }

        public static func makePercentageDiscountMonths(percentageDiscount: Double, percentageNumberOfMonths: Int) -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var incentiveFragment: IncentiveFragment {
            get {
              return IncentiveFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public var asFreeMonths: AsFreeMonths? {
          get {
            if !AsFreeMonths.possibleTypes.contains(__typename) { return nil }
            return AsFreeMonths(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsFreeMonths: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["FreeMonths"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("quantity", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(quantity: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var quantity: Int? {
            get {
              return resultMap["quantity"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "quantity")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMonthlyCostDeduction: AsMonthlyCostDeduction? {
          get {
            if !AsMonthlyCostDeduction.possibleTypes.contains(__typename) { return nil }
            return AsMonthlyCostDeduction(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMonthlyCostDeduction: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonthlyCostDeduction"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .object(Amount.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: Amount? = nil) {
            self.init(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: Amount) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: Amount? {
            get {
              return (resultMap["amount"] as? ResultMap).flatMap { Amount(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "amount")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Amount: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonetaryAmountV2"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .nonNull(.scalar(String.self))),
              GraphQLField("currency", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: String, currency: String) {
              self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: String {
              get {
                return resultMap["amount"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "amount")
              }
            }

            public var currency: String {
              get {
                return resultMap["currency"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "currency")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var monetaryAmountFragment: MonetaryAmountFragment {
                get {
                  return MonetaryAmountFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }

        public var asPercentageDiscountMonths: AsPercentageDiscountMonths? {
          get {
            if !AsPercentageDiscountMonths.possibleTypes.contains(__typename) { return nil }
            return AsPercentageDiscountMonths(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsPercentageDiscountMonths: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PercentageDiscountMonths"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("percentageDiscount", type: .nonNull(.scalar(Double.self))),
            GraphQLField("quantity", alias: "percentageNumberOfMonths", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(percentageDiscount: Double, percentageNumberOfMonths: Int) {
            self.init(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var percentageDiscount: Double {
            get {
              return resultMap["percentageDiscount"]! as! Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "percentageDiscount")
            }
          }

          public var percentageNumberOfMonths: Int {
            get {
              return resultMap["percentageNumberOfMonths"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "percentageNumberOfMonths")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }

    public struct Balance: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Balance"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("currentBalance", type: .nonNull(.object(CurrentBalance.selections))),
        GraphQLField("failedCharges", type: .scalar(Int.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(currentBalance: CurrentBalance, failedCharges: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "Balance", "currentBalance": currentBalance.resultMap, "failedCharges": failedCharges])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var currentBalance: CurrentBalance {
        get {
          return CurrentBalance(unsafeResultMap: resultMap["currentBalance"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "currentBalance")
        }
      }

      public var failedCharges: Int? {
        get {
          return resultMap["failedCharges"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "failedCharges")
        }
      }

      public struct CurrentBalance: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }

    public struct ChargeEstimation: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ChargeEstimation"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("charge", type: .nonNull(.object(Charge.selections))),
        GraphQLField("discount", type: .nonNull(.object(Discount.selections))),
        GraphQLField("subscription", type: .nonNull(.object(Subscription.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(charge: Charge, discount: Discount, subscription: Subscription) {
        self.init(unsafeResultMap: ["__typename": "ChargeEstimation", "charge": charge.resultMap, "discount": discount.resultMap, "subscription": subscription.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var charge: Charge {
        get {
          return Charge(unsafeResultMap: resultMap["charge"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "charge")
        }
      }

      public var discount: Discount {
        get {
          return Discount(unsafeResultMap: resultMap["discount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "discount")
        }
      }

      public var subscription: Subscription {
        get {
          return Subscription(unsafeResultMap: resultMap["subscription"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "subscription")
        }
      }

      public struct Charge: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Discount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Subscription: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }

    public struct ChargeHistory: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Charge"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
        GraphQLField("date", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: Amount, date: String) {
        self.init(unsafeResultMap: ["__typename": "Charge", "amount": amount.resultMap, "date": date])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var amount: Amount {
        get {
          return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "amount")
        }
      }

      public var date: String {
        get {
          return resultMap["date"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "date")
        }
      }

      public struct Amount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public final class OfferQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Offer($locale: Locale!) {
      redeemedCampaigns {
        __typename
        ...CampaignFragment
      }
      insurance {
        __typename
        address
        type
        previousInsurer {
          __typename
          displayName
          switchable
        }
        personsInHousehold
        presaleInformationUrl
        policyUrl
        cost {
          __typename
          ...CostFragment
        }
      }
      lastQuoteOfMember {
        __typename
        ... on CompleteQuote {
          startDate
          id
          perils(locale: $locale) {
            __typename
            ...PerilFragment
          }
          insurableLimits(locale: $locale) {
            __typename
            ...InsurableLimitFragment
          }
        }
      }
    }
    """

  public let operationName: String = "Offer"

  public let operationIdentifier: String? = "f5778c42caa9260146f46b4bd5c2850405d6ba5b3c596817137e3c961dfd355d"

  public var queryDocument: String { return operationDefinition.appending(CampaignFragment.fragmentDefinition).appending(IncentiveFragment.fragmentDefinition).appending(MonetaryAmountFragment.fragmentDefinition).appending(CostFragment.fragmentDefinition).appending(PerilFragment.fragmentDefinition).appending(IconFragment.fragmentDefinition).appending(InsurableLimitFragment.fragmentDefinition) }

  public var locale: Locale

  public init(locale: Locale) {
    self.locale = locale
  }

  public var variables: GraphQLMap? {
    return ["locale": locale]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("redeemedCampaigns", type: .nonNull(.list(.nonNull(.object(RedeemedCampaign.selections))))),
      GraphQLField("insurance", type: .nonNull(.object(Insurance.selections))),
      GraphQLField("lastQuoteOfMember", type: .nonNull(.object(LastQuoteOfMember.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(redeemedCampaigns: [RedeemedCampaign], insurance: Insurance, lastQuoteOfMember: LastQuoteOfMember) {
      self.init(unsafeResultMap: ["__typename": "Query", "redeemedCampaigns": redeemedCampaigns.map { (value: RedeemedCampaign) -> ResultMap in value.resultMap }, "insurance": insurance.resultMap, "lastQuoteOfMember": lastQuoteOfMember.resultMap])
    }

    /// Returns redeemed campaigns belonging to authedUser
    public var redeemedCampaigns: [RedeemedCampaign] {
      get {
        return (resultMap["redeemedCampaigns"] as! [ResultMap]).map { (value: ResultMap) -> RedeemedCampaign in RedeemedCampaign(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: RedeemedCampaign) -> ResultMap in value.resultMap }, forKey: "redeemedCampaigns")
      }
    }

    public var insurance: Insurance {
      get {
        return Insurance(unsafeResultMap: resultMap["insurance"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "insurance")
      }
    }

    public var lastQuoteOfMember: LastQuoteOfMember {
      get {
        return LastQuoteOfMember(unsafeResultMap: resultMap["lastQuoteOfMember"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "lastQuoteOfMember")
      }
    }

    public struct RedeemedCampaign: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Campaign"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("incentive", type: .object(Incentive.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(code: String, incentive: Incentive? = nil) {
        self.init(unsafeResultMap: ["__typename": "Campaign", "code": code, "incentive": incentive.flatMap { (value: Incentive) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var code: String {
        get {
          return resultMap["code"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "code")
        }
      }

      public var incentive: Incentive? {
        get {
          return (resultMap["incentive"] as? ResultMap).flatMap { Incentive(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "incentive")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var campaignFragment: CampaignFragment {
          get {
            return CampaignFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Incentive: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonthlyCostDeduction", "FreeMonths", "NoDiscount", "PercentageDiscountMonths"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["FreeMonths": AsFreeMonths.selections, "MonthlyCostDeduction": AsMonthlyCostDeduction.selections, "PercentageDiscountMonths": AsPercentageDiscountMonths.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeNoDiscount() -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "NoDiscount"])
        }

        public static func makeFreeMonths(quantity: Int? = nil) -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
        }

        public static func makeMonthlyCostDeduction(amount: AsMonthlyCostDeduction.Amount? = nil) -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: AsMonthlyCostDeduction.Amount) -> ResultMap in value.resultMap }])
        }

        public static func makePercentageDiscountMonths(percentageDiscount: Double, percentageNumberOfMonths: Int) -> Incentive {
          return Incentive(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var incentiveFragment: IncentiveFragment {
            get {
              return IncentiveFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public var asFreeMonths: AsFreeMonths? {
          get {
            if !AsFreeMonths.possibleTypes.contains(__typename) { return nil }
            return AsFreeMonths(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsFreeMonths: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["FreeMonths"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("quantity", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(quantity: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var quantity: Int? {
            get {
              return resultMap["quantity"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "quantity")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMonthlyCostDeduction: AsMonthlyCostDeduction? {
          get {
            if !AsMonthlyCostDeduction.possibleTypes.contains(__typename) { return nil }
            return AsMonthlyCostDeduction(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMonthlyCostDeduction: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonthlyCostDeduction"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .object(Amount.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: Amount? = nil) {
            self.init(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: Amount) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: Amount? {
            get {
              return (resultMap["amount"] as? ResultMap).flatMap { Amount(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "amount")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Amount: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonetaryAmountV2"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .nonNull(.scalar(String.self))),
              GraphQLField("currency", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: String, currency: String) {
              self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: String {
              get {
                return resultMap["amount"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "amount")
              }
            }

            public var currency: String {
              get {
                return resultMap["currency"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "currency")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var monetaryAmountFragment: MonetaryAmountFragment {
                get {
                  return MonetaryAmountFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }

        public var asPercentageDiscountMonths: AsPercentageDiscountMonths? {
          get {
            if !AsPercentageDiscountMonths.possibleTypes.contains(__typename) { return nil }
            return AsPercentageDiscountMonths(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsPercentageDiscountMonths: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PercentageDiscountMonths"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("percentageDiscount", type: .nonNull(.scalar(Double.self))),
            GraphQLField("quantity", alias: "percentageNumberOfMonths", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(percentageDiscount: Double, percentageNumberOfMonths: Int) {
            self.init(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var percentageDiscount: Double {
            get {
              return resultMap["percentageDiscount"]! as! Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "percentageDiscount")
            }
          }

          public var percentageNumberOfMonths: Int {
            get {
              return resultMap["percentageNumberOfMonths"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "percentageNumberOfMonths")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }

    public struct Insurance: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Insurance"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .scalar(String.self)),
        GraphQLField("type", type: .scalar(InsuranceType.self)),
        GraphQLField("previousInsurer", type: .object(PreviousInsurer.selections)),
        GraphQLField("personsInHousehold", type: .scalar(Int.self)),
        GraphQLField("presaleInformationUrl", type: .scalar(String.self)),
        GraphQLField("policyUrl", type: .scalar(String.self)),
        GraphQLField("cost", type: .object(Cost.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(address: String? = nil, type: InsuranceType? = nil, previousInsurer: PreviousInsurer? = nil, personsInHousehold: Int? = nil, presaleInformationUrl: String? = nil, policyUrl: String? = nil, cost: Cost? = nil) {
        self.init(unsafeResultMap: ["__typename": "Insurance", "address": address, "type": type, "previousInsurer": previousInsurer.flatMap { (value: PreviousInsurer) -> ResultMap in value.resultMap }, "personsInHousehold": personsInHousehold, "presaleInformationUrl": presaleInformationUrl, "policyUrl": policyUrl, "cost": cost.flatMap { (value: Cost) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var address: String? {
        get {
          return resultMap["address"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "address")
        }
      }

      public var type: InsuranceType? {
        get {
          return resultMap["type"] as? InsuranceType
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var previousInsurer: PreviousInsurer? {
        get {
          return (resultMap["previousInsurer"] as? ResultMap).flatMap { PreviousInsurer(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "previousInsurer")
        }
      }

      public var personsInHousehold: Int? {
        get {
          return resultMap["personsInHousehold"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "personsInHousehold")
        }
      }

      public var presaleInformationUrl: String? {
        get {
          return resultMap["presaleInformationUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "presaleInformationUrl")
        }
      }

      public var policyUrl: String? {
        get {
          return resultMap["policyUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "policyUrl")
        }
      }

      public var cost: Cost? {
        get {
          return (resultMap["cost"] as? ResultMap).flatMap { Cost(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "cost")
        }
      }

      public struct PreviousInsurer: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PreviousInsurer"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("displayName", type: .scalar(String.self)),
          GraphQLField("switchable", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(displayName: String? = nil, switchable: Bool) {
          self.init(unsafeResultMap: ["__typename": "PreviousInsurer", "displayName": displayName, "switchable": switchable])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var displayName: String? {
          get {
            return resultMap["displayName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "displayName")
          }
        }

        public var switchable: Bool {
          get {
            return resultMap["switchable"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "switchable")
          }
        }
      }

      public struct Cost: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["InsuranceCost"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("freeUntil", type: .scalar(String.self)),
          GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
          GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
          GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
          self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var freeUntil: String? {
          get {
            return resultMap["freeUntil"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "freeUntil")
          }
        }

        public var monthlyDiscount: MonthlyDiscount {
          get {
            return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
          }
        }

        public var monthlyGross: MonthlyGross {
          get {
            return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
          }
        }

        public var monthlyNet: MonthlyNet {
          get {
            return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var costFragment: CostFragment {
            get {
              return CostFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct MonthlyDiscount: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }

        public struct MonthlyGross: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }

        public struct MonthlyNet: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }
      }
    }

    public struct LastQuoteOfMember: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CompleteQuote", "IncompleteQuote"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["CompleteQuote": AsCompleteQuote.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeIncompleteQuote() -> LastQuoteOfMember {
        return LastQuoteOfMember(unsafeResultMap: ["__typename": "IncompleteQuote"])
      }

      public static func makeCompleteQuote(startDate: String? = nil, id: GraphQLID, perils: [AsCompleteQuote.Peril], insurableLimits: [AsCompleteQuote.InsurableLimit]) -> LastQuoteOfMember {
        return LastQuoteOfMember(unsafeResultMap: ["__typename": "CompleteQuote", "startDate": startDate, "id": id, "perils": perils.map { (value: AsCompleteQuote.Peril) -> ResultMap in value.resultMap }, "insurableLimits": insurableLimits.map { (value: AsCompleteQuote.InsurableLimit) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asCompleteQuote: AsCompleteQuote? {
        get {
          if !AsCompleteQuote.possibleTypes.contains(__typename) { return nil }
          return AsCompleteQuote(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsCompleteQuote: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CompleteQuote"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("startDate", type: .scalar(String.self)),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("perils", arguments: ["locale": GraphQLVariable("locale")], type: .nonNull(.list(.nonNull(.object(Peril.selections))))),
          GraphQLField("insurableLimits", arguments: ["locale": GraphQLVariable("locale")], type: .nonNull(.list(.nonNull(.object(InsurableLimit.selections))))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(startDate: String? = nil, id: GraphQLID, perils: [Peril], insurableLimits: [InsurableLimit]) {
          self.init(unsafeResultMap: ["__typename": "CompleteQuote", "startDate": startDate, "id": id, "perils": perils.map { (value: Peril) -> ResultMap in value.resultMap }, "insurableLimits": insurableLimits.map { (value: InsurableLimit) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var startDate: String? {
          get {
            return resultMap["startDate"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startDate")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var perils: [Peril] {
          get {
            return (resultMap["perils"] as! [ResultMap]).map { (value: ResultMap) -> Peril in Peril(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Peril) -> ResultMap in value.resultMap }, forKey: "perils")
          }
        }

        public var insurableLimits: [InsurableLimit] {
          get {
            return (resultMap["insurableLimits"] as! [ResultMap]).map { (value: ResultMap) -> InsurableLimit in InsurableLimit(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: InsurableLimit) -> ResultMap in value.resultMap }, forKey: "insurableLimits")
          }
        }

        public struct Peril: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PerilV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("title", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .nonNull(.scalar(String.self))),
            GraphQLField("icon", type: .nonNull(.object(Icon.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(title: String, description: String, icon: Icon) {
            self.init(unsafeResultMap: ["__typename": "PerilV2", "title": title, "description": description, "icon": icon.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var title: String {
            get {
              return resultMap["title"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          public var description: String {
            get {
              return resultMap["description"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var icon: Icon {
            get {
              return Icon(unsafeResultMap: resultMap["icon"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "icon")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var perilFragment: PerilFragment {
              get {
                return PerilFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Icon: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Icon"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(variants: Variant) {
              self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Icons with variants for light and dark mode
            public var variants: Variant {
              get {
                return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "variants")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var iconFragment: IconFragment {
                get {
                  return IconFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct Variant: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["IconVariants"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
                GraphQLField("light", type: .nonNull(.object(Light.selections))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(dark: Dark, light: Light) {
                self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// A variant to use for dark user interfaces
              public var dark: Dark {
                get {
                  return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "dark")
                }
              }

              /// A variant to use for light user interfaces
              public var light: Light {
                get {
                  return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "light")
                }
              }

              public struct Dark: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["IconVariant"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(pdfUrl: String) {
                  self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// For iOS use
                public var pdfUrl: String {
                  get {
                    return resultMap["pdfUrl"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "pdfUrl")
                  }
                }
              }

              public struct Light: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["IconVariant"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(pdfUrl: String) {
                  self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// For iOS use
                public var pdfUrl: String {
                  get {
                    return resultMap["pdfUrl"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "pdfUrl")
                  }
                }
              }
            }
          }
        }

        public struct InsurableLimit: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["InsurableLimit"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("label", type: .nonNull(.scalar(String.self))),
            GraphQLField("limit", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(label: String, limit: String, description: String) {
            self.init(unsafeResultMap: ["__typename": "InsurableLimit", "label": label, "limit": limit, "description": description])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var label: String {
            get {
              return resultMap["label"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "label")
            }
          }

          public var limit: String {
            get {
              return resultMap["limit"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "limit")
            }
          }

          public var description: String {
            get {
              return resultMap["description"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var insurableLimitFragment: InsurableLimitFragment {
              get {
                return InsurableLimitFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }
}

public final class OfferClosedMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation OfferClosed {
      offerClosed
    }
    """

  public let operationName: String = "OfferClosed"

  public let operationIdentifier: String? = "2e8915f8312d118b1be03f3e60db0b12113d5d5059a1d753eb1a32377a650b53"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("offerClosed", type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(offerClosed: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "offerClosed": offerClosed])
    }

    public var offerClosed: Bool {
      get {
        return resultMap["offerClosed"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "offerClosed")
      }
    }
  }
}

public final class ProfileQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Profile {
      member {
        __typename
        firstName
        lastName
      }
      insuranceCost {
        __typename
        ...CostFragment
      }
      cashback {
        __typename
        name
        imageUrl
      }
    }
    """

  public let operationName: String = "Profile"

  public let operationIdentifier: String? = "6bcea25e4c85b8433c6176659a86a8788c34912e4dabb310327fe66c97846f0a"

  public var queryDocument: String { return operationDefinition.appending(CostFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("member", type: .nonNull(.object(Member.selections))),
      GraphQLField("insuranceCost", type: .object(InsuranceCost.selections)),
      GraphQLField("cashback", type: .object(Cashback.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(member: Member, insuranceCost: InsuranceCost? = nil, cashback: Cashback? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "member": member.resultMap, "insuranceCost": insuranceCost.flatMap { (value: InsuranceCost) -> ResultMap in value.resultMap }, "cashback": cashback.flatMap { (value: Cashback) -> ResultMap in value.resultMap }])
    }

    public var member: Member {
      get {
        return Member(unsafeResultMap: resultMap["member"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "member")
      }
    }

    /// Returns the aggregated insurance cost of a member's PENDING, ACTIVE or ACTIVE_IN_FUTURE current agreements
    public var insuranceCost: InsuranceCost? {
      get {
        return (resultMap["insuranceCost"] as? ResultMap).flatMap { InsuranceCost(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "insuranceCost")
      }
    }

    public var cashback: Cashback? {
      get {
        return (resultMap["cashback"] as? ResultMap).flatMap { Cashback(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "cashback")
      }
    }

    public struct Member: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("firstName", type: .scalar(String.self)),
        GraphQLField("lastName", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(firstName: String? = nil, lastName: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Member", "firstName": firstName, "lastName": lastName])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var firstName: String? {
        get {
          return resultMap["firstName"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "firstName")
        }
      }

      public var lastName: String? {
        get {
          return resultMap["lastName"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "lastName")
        }
      }
    }

    public struct InsuranceCost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["InsuranceCost"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("freeUntil", type: .scalar(String.self)),
        GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
        GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
        GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
        self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var freeUntil: String? {
        get {
          return resultMap["freeUntil"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "freeUntil")
        }
      }

      public var monthlyDiscount: MonthlyDiscount {
        get {
          return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
        }
      }

      public var monthlyGross: MonthlyGross {
        get {
          return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
        }
      }

      public var monthlyNet: MonthlyNet {
        get {
          return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var costFragment: CostFragment {
          get {
            return CostFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct MonthlyDiscount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyGross: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyNet: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }
    }

    public struct Cashback: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Cashback"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String? = nil, imageUrl: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Cashback", "name": name, "imageUrl": imageUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var imageUrl: String? {
        get {
          return resultMap["imageUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "imageUrl")
        }
      }
    }
  }
}

public final class RedeemCodeMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation RedeemCode($code: String!) {
      redeemCode(code: $code) {
        __typename
        cost {
          __typename
          ...CostFragment
        }
        campaigns {
          __typename
          ...CampaignFragment
        }
      }
    }
    """

  public let operationName: String = "RedeemCode"

  public let operationIdentifier: String? = "362c499368096c75a7f531610adccaaa39381881c827517ffb186519d32bc9d2"

  public var queryDocument: String { return operationDefinition.appending(CostFragment.fragmentDefinition).appending(CampaignFragment.fragmentDefinition).appending(IncentiveFragment.fragmentDefinition).appending(MonetaryAmountFragment.fragmentDefinition) }

  public var code: String

  public init(code: String) {
    self.code = code
  }

  public var variables: GraphQLMap? {
    return ["code": code]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("redeemCode", arguments: ["code": GraphQLVariable("code")], type: .nonNull(.object(RedeemCode.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(redeemCode: RedeemCode) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "redeemCode": redeemCode.resultMap])
    }

    /// Will be called from the client when 1) redeem manually a code, 2) click the link  --Fails if the code is invalid?--
    public var redeemCode: RedeemCode {
      get {
        return RedeemCode(unsafeResultMap: resultMap["redeemCode"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "redeemCode")
      }
    }

    public struct RedeemCode: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["RedemedCodeResult"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("cost", type: .nonNull(.object(Cost.selections))),
        GraphQLField("campaigns", type: .nonNull(.list(.nonNull(.object(Campaign.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(cost: Cost, campaigns: [Campaign]) {
        self.init(unsafeResultMap: ["__typename": "RedemedCodeResult", "cost": cost.resultMap, "campaigns": campaigns.map { (value: Campaign) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var cost: Cost {
        get {
          return Cost(unsafeResultMap: resultMap["cost"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "cost")
        }
      }

      /// The currently redeemed incentive, this can be null
      public var campaigns: [Campaign] {
        get {
          return (resultMap["campaigns"] as! [ResultMap]).map { (value: ResultMap) -> Campaign in Campaign(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Campaign) -> ResultMap in value.resultMap }, forKey: "campaigns")
        }
      }

      public struct Cost: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["InsuranceCost"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("freeUntil", type: .scalar(String.self)),
          GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
          GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
          GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
          self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var freeUntil: String? {
          get {
            return resultMap["freeUntil"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "freeUntil")
          }
        }

        public var monthlyDiscount: MonthlyDiscount {
          get {
            return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
          }
        }

        public var monthlyGross: MonthlyGross {
          get {
            return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
          }
        }

        public var monthlyNet: MonthlyNet {
          get {
            return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var costFragment: CostFragment {
            get {
              return CostFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct MonthlyDiscount: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }

        public struct MonthlyGross: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }

        public struct MonthlyNet: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }
      }

      public struct Campaign: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Campaign"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("code", type: .nonNull(.scalar(String.self))),
          GraphQLField("incentive", type: .object(Incentive.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(code: String, incentive: Incentive? = nil) {
          self.init(unsafeResultMap: ["__typename": "Campaign", "code": code, "incentive": incentive.flatMap { (value: Incentive) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var code: String {
          get {
            return resultMap["code"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "code")
          }
        }

        public var incentive: Incentive? {
          get {
            return (resultMap["incentive"] as? ResultMap).flatMap { Incentive(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "incentive")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var campaignFragment: CampaignFragment {
            get {
              return CampaignFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Incentive: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonthlyCostDeduction", "FreeMonths", "NoDiscount", "PercentageDiscountMonths"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["FreeMonths": AsFreeMonths.selections, "MonthlyCostDeduction": AsMonthlyCostDeduction.selections, "PercentageDiscountMonths": AsPercentageDiscountMonths.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeNoDiscount() -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "NoDiscount"])
          }

          public static func makeFreeMonths(quantity: Int? = nil) -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
          }

          public static func makeMonthlyCostDeduction(amount: AsMonthlyCostDeduction.Amount? = nil) -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: AsMonthlyCostDeduction.Amount) -> ResultMap in value.resultMap }])
          }

          public static func makePercentageDiscountMonths(percentageDiscount: Double, percentageNumberOfMonths: Int) -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public var asFreeMonths: AsFreeMonths? {
            get {
              if !AsFreeMonths.possibleTypes.contains(__typename) { return nil }
              return AsFreeMonths(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsFreeMonths: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["FreeMonths"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("quantity", type: .scalar(Int.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(quantity: Int? = nil) {
              self.init(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var quantity: Int? {
              get {
                return resultMap["quantity"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "quantity")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var incentiveFragment: IncentiveFragment {
                get {
                  return IncentiveFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }

          public var asMonthlyCostDeduction: AsMonthlyCostDeduction? {
            get {
              if !AsMonthlyCostDeduction.possibleTypes.contains(__typename) { return nil }
              return AsMonthlyCostDeduction(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsMonthlyCostDeduction: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonthlyCostDeduction"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .object(Amount.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: Amount? = nil) {
              self.init(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: Amount) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: Amount? {
              get {
                return (resultMap["amount"] as? ResultMap).flatMap { Amount(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "amount")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var incentiveFragment: IncentiveFragment {
                get {
                  return IncentiveFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct Amount: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MonetaryAmountV2"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("amount", type: .nonNull(.scalar(String.self))),
                GraphQLField("currency", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(amount: String, currency: String) {
                self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var amount: String {
                get {
                  return resultMap["amount"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "amount")
                }
              }

              public var currency: String {
                get {
                  return resultMap["currency"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "currency")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var monetaryAmountFragment: MonetaryAmountFragment {
                  get {
                    return MonetaryAmountFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }
          }

          public var asPercentageDiscountMonths: AsPercentageDiscountMonths? {
            get {
              if !AsPercentageDiscountMonths.possibleTypes.contains(__typename) { return nil }
              return AsPercentageDiscountMonths(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsPercentageDiscountMonths: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["PercentageDiscountMonths"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("percentageDiscount", type: .nonNull(.scalar(Double.self))),
              GraphQLField("quantity", alias: "percentageNumberOfMonths", type: .nonNull(.scalar(Int.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(percentageDiscount: Double, percentageNumberOfMonths: Int) {
              self.init(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var percentageDiscount: Double {
              get {
                return resultMap["percentageDiscount"]! as! Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "percentageDiscount")
              }
            }

            public var percentageNumberOfMonths: Int {
              get {
                return resultMap["percentageNumberOfMonths"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "percentageNumberOfMonths")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var incentiveFragment: IncentiveFragment {
                get {
                  return IncentiveFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }
      }
    }
  }
}

public final class ReferralsScreenQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ReferralsScreen {
      insuranceCost {
        __typename
        ...CostFragment
      }
      referralInformation {
        __typename
        campaign {
          __typename
          code
          incentive {
            __typename
            ... on MonthlyCostDeduction {
              amount {
                __typename
                amount
              }
            }
          }
        }
        referredBy {
          __typename
          ... on ActiveReferral {
            discount {
              __typename
              amount
            }
            name
          }
          ... on InProgressReferral {
            name
          }
          ... on AcceptedReferral {
            quantity
          }
          ... on TerminatedReferral {
            name
          }
        }
        invitations {
          __typename
          ... on ActiveReferral {
            discount {
              __typename
              amount
            }
            name
          }
          ... on InProgressReferral {
            name
          }
          ... on AcceptedReferral {
            quantity
          }
          ... on TerminatedReferral {
            name
          }
        }
      }
    }
    """

  public let operationName: String = "ReferralsScreen"

  public let operationIdentifier: String? = "5c31eef27f64586a8ac3edc5384d86b6e2fbc0974c64b9b328613072382400bd"

  public var queryDocument: String { return operationDefinition.appending(CostFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("insuranceCost", type: .object(InsuranceCost.selections)),
      GraphQLField("referralInformation", type: .nonNull(.object(ReferralInformation.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(insuranceCost: InsuranceCost? = nil, referralInformation: ReferralInformation) {
      self.init(unsafeResultMap: ["__typename": "Query", "insuranceCost": insuranceCost.flatMap { (value: InsuranceCost) -> ResultMap in value.resultMap }, "referralInformation": referralInformation.resultMap])
    }

    /// Returns the aggregated insurance cost of a member's PENDING, ACTIVE or ACTIVE_IN_FUTURE current agreements
    public var insuranceCost: InsuranceCost? {
      get {
        return (resultMap["insuranceCost"] as? ResultMap).flatMap { InsuranceCost(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "insuranceCost")
      }
    }

    /// Returns information about the authed member's referralCampaign and referrals
    public var referralInformation: ReferralInformation {
      get {
        return ReferralInformation(unsafeResultMap: resultMap["referralInformation"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "referralInformation")
      }
    }

    public struct InsuranceCost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["InsuranceCost"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("freeUntil", type: .scalar(String.self)),
        GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
        GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
        GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
        self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var freeUntil: String? {
        get {
          return resultMap["freeUntil"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "freeUntil")
        }
      }

      public var monthlyDiscount: MonthlyDiscount {
        get {
          return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
        }
      }

      public var monthlyGross: MonthlyGross {
        get {
          return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
        }
      }

      public var monthlyNet: MonthlyNet {
        get {
          return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var costFragment: CostFragment {
          get {
            return CostFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct MonthlyDiscount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyGross: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }

      public struct MonthlyNet: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }
      }
    }

    public struct ReferralInformation: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Referrals"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("campaign", type: .nonNull(.object(Campaign.selections))),
        GraphQLField("referredBy", type: .object(ReferredBy.selections)),
        GraphQLField("invitations", type: .nonNull(.list(.nonNull(.object(Invitation.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(campaign: Campaign, referredBy: ReferredBy? = nil, invitations: [Invitation]) {
        self.init(unsafeResultMap: ["__typename": "Referrals", "campaign": campaign.resultMap, "referredBy": referredBy.flatMap { (value: ReferredBy) -> ResultMap in value.resultMap }, "invitations": invitations.map { (value: Invitation) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var campaign: Campaign {
        get {
          return Campaign(unsafeResultMap: resultMap["campaign"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "campaign")
        }
      }

      public var referredBy: ReferredBy? {
        get {
          return (resultMap["referredBy"] as? ResultMap).flatMap { ReferredBy(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "referredBy")
        }
      }

      public var invitations: [Invitation] {
        get {
          return (resultMap["invitations"] as! [ResultMap]).map { (value: ResultMap) -> Invitation in Invitation(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Invitation) -> ResultMap in value.resultMap }, forKey: "invitations")
        }
      }

      public struct Campaign: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Campaign"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("code", type: .nonNull(.scalar(String.self))),
          GraphQLField("incentive", type: .object(Incentive.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(code: String, incentive: Incentive? = nil) {
          self.init(unsafeResultMap: ["__typename": "Campaign", "code": code, "incentive": incentive.flatMap { (value: Incentive) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var code: String {
          get {
            return resultMap["code"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "code")
          }
        }

        public var incentive: Incentive? {
          get {
            return (resultMap["incentive"] as? ResultMap).flatMap { Incentive(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "incentive")
          }
        }

        public struct Incentive: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonthlyCostDeduction", "FreeMonths", "NoDiscount", "PercentageDiscountMonths"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["MonthlyCostDeduction": AsMonthlyCostDeduction.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeFreeMonths() -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "FreeMonths"])
          }

          public static func makeNoDiscount() -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "NoDiscount"])
          }

          public static func makePercentageDiscountMonths() -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "PercentageDiscountMonths"])
          }

          public static func makeMonthlyCostDeduction(amount: AsMonthlyCostDeduction.Amount? = nil) -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: AsMonthlyCostDeduction.Amount) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var asMonthlyCostDeduction: AsMonthlyCostDeduction? {
            get {
              if !AsMonthlyCostDeduction.possibleTypes.contains(__typename) { return nil }
              return AsMonthlyCostDeduction(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsMonthlyCostDeduction: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonthlyCostDeduction"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .object(Amount.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: Amount? = nil) {
              self.init(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: Amount) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: Amount? {
              get {
                return (resultMap["amount"] as? ResultMap).flatMap { Amount(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "amount")
              }
            }

            public struct Amount: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MonetaryAmountV2"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("amount", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(amount: String) {
                self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var amount: String {
                get {
                  return resultMap["amount"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "amount")
                }
              }
            }
          }
        }
      }

      public struct ReferredBy: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ActiveReferral", "InProgressReferral", "AcceptedReferral", "TerminatedReferral"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["ActiveReferral": AsActiveReferral.selections, "InProgressReferral": AsInProgressReferral.selections, "AcceptedReferral": AsAcceptedReferral.selections, "TerminatedReferral": AsTerminatedReferral.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeActiveReferral(discount: AsActiveReferral.Discount, name: String? = nil) -> ReferredBy {
          return ReferredBy(unsafeResultMap: ["__typename": "ActiveReferral", "discount": discount.resultMap, "name": name])
        }

        public static func makeInProgressReferral(name: String? = nil) -> ReferredBy {
          return ReferredBy(unsafeResultMap: ["__typename": "InProgressReferral", "name": name])
        }

        public static func makeAcceptedReferral(quantity: Int? = nil) -> ReferredBy {
          return ReferredBy(unsafeResultMap: ["__typename": "AcceptedReferral", "quantity": quantity])
        }

        public static func makeTerminatedReferral(name: String? = nil) -> ReferredBy {
          return ReferredBy(unsafeResultMap: ["__typename": "TerminatedReferral", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asActiveReferral: AsActiveReferral? {
          get {
            if !AsActiveReferral.possibleTypes.contains(__typename) { return nil }
            return AsActiveReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsActiveReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["ActiveReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("discount", type: .nonNull(.object(Discount.selections))),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(discount: Discount, name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "ActiveReferral", "discount": discount.resultMap, "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var discount: Discount {
            get {
              return Discount(unsafeResultMap: resultMap["discount"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "discount")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public struct Discount: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonetaryAmountV2"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: String) {
              self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: String {
              get {
                return resultMap["amount"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "amount")
              }
            }
          }
        }

        public var asInProgressReferral: AsInProgressReferral? {
          get {
            if !AsInProgressReferral.possibleTypes.contains(__typename) { return nil }
            return AsInProgressReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsInProgressReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["InProgressReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "InProgressReferral", "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }

        public var asAcceptedReferral: AsAcceptedReferral? {
          get {
            if !AsAcceptedReferral.possibleTypes.contains(__typename) { return nil }
            return AsAcceptedReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsAcceptedReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["AcceptedReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("quantity", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(quantity: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "AcceptedReferral", "quantity": quantity])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var quantity: Int? {
            get {
              return resultMap["quantity"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "quantity")
            }
          }
        }

        public var asTerminatedReferral: AsTerminatedReferral? {
          get {
            if !AsTerminatedReferral.possibleTypes.contains(__typename) { return nil }
            return AsTerminatedReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsTerminatedReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["TerminatedReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "TerminatedReferral", "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }
      }

      public struct Invitation: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ActiveReferral", "InProgressReferral", "AcceptedReferral", "TerminatedReferral"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["ActiveReferral": AsActiveReferral.selections, "InProgressReferral": AsInProgressReferral.selections, "AcceptedReferral": AsAcceptedReferral.selections, "TerminatedReferral": AsTerminatedReferral.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeActiveReferral(discount: AsActiveReferral.Discount, name: String? = nil) -> Invitation {
          return Invitation(unsafeResultMap: ["__typename": "ActiveReferral", "discount": discount.resultMap, "name": name])
        }

        public static func makeInProgressReferral(name: String? = nil) -> Invitation {
          return Invitation(unsafeResultMap: ["__typename": "InProgressReferral", "name": name])
        }

        public static func makeAcceptedReferral(quantity: Int? = nil) -> Invitation {
          return Invitation(unsafeResultMap: ["__typename": "AcceptedReferral", "quantity": quantity])
        }

        public static func makeTerminatedReferral(name: String? = nil) -> Invitation {
          return Invitation(unsafeResultMap: ["__typename": "TerminatedReferral", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asActiveReferral: AsActiveReferral? {
          get {
            if !AsActiveReferral.possibleTypes.contains(__typename) { return nil }
            return AsActiveReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsActiveReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["ActiveReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("discount", type: .nonNull(.object(Discount.selections))),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(discount: Discount, name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "ActiveReferral", "discount": discount.resultMap, "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var discount: Discount {
            get {
              return Discount(unsafeResultMap: resultMap["discount"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "discount")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public struct Discount: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonetaryAmountV2"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: String) {
              self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: String {
              get {
                return resultMap["amount"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "amount")
              }
            }
          }
        }

        public var asInProgressReferral: AsInProgressReferral? {
          get {
            if !AsInProgressReferral.possibleTypes.contains(__typename) { return nil }
            return AsInProgressReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsInProgressReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["InProgressReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "InProgressReferral", "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }

        public var asAcceptedReferral: AsAcceptedReferral? {
          get {
            if !AsAcceptedReferral.possibleTypes.contains(__typename) { return nil }
            return AsAcceptedReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsAcceptedReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["AcceptedReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("quantity", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(quantity: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "AcceptedReferral", "quantity": quantity])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var quantity: Int? {
            get {
              return resultMap["quantity"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "quantity")
            }
          }
        }

        public var asTerminatedReferral: AsTerminatedReferral? {
          get {
            if !AsTerminatedReferral.possibleTypes.contains(__typename) { return nil }
            return AsTerminatedReferral(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsTerminatedReferral: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["TerminatedReferral"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "TerminatedReferral", "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }
      }
    }
  }
}

public final class RegisterPushTokenMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation RegisterPushToken($pushToken: String!) {
      registerPushToken(pushToken: $pushToken)
    }
    """

  public let operationName: String = "RegisterPushToken"

  public let operationIdentifier: String? = "243ce23d5c681ab42edbe0b26fea318643dd01459147bffedc9911a29c6ccc64"

  public var pushToken: String

  public init(pushToken: String) {
    self.pushToken = pushToken
  }

  public var variables: GraphQLMap? {
    return ["pushToken": pushToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("registerPushToken", arguments: ["pushToken": GraphQLVariable("pushToken")], type: .scalar(Bool.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(registerPushToken: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "registerPushToken": registerPushToken])
    }

    public var registerPushToken: Bool? {
      get {
        return resultMap["registerPushToken"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "registerPushToken")
      }
    }
  }
}

public final class RemoveDiscountCodeMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation RemoveDiscountCode {
      removeDiscountCode {
        __typename
        campaigns {
          __typename
          ...CampaignFragment
        }
        cost {
          __typename
          ...CostFragment
        }
      }
    }
    """

  public let operationName: String = "RemoveDiscountCode"

  public let operationIdentifier: String? = "d7819cbd9e1e9be9f60e020a41817bb8566d9c6dc430fd00b51be6c2ab42beb6"

  public var queryDocument: String { return operationDefinition.appending(CampaignFragment.fragmentDefinition).appending(IncentiveFragment.fragmentDefinition).appending(MonetaryAmountFragment.fragmentDefinition).appending(CostFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeDiscountCode", type: .nonNull(.object(RemoveDiscountCode.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeDiscountCode: RemoveDiscountCode) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeDiscountCode": removeDiscountCode.resultMap])
    }

    public var removeDiscountCode: RemoveDiscountCode {
      get {
        return RemoveDiscountCode(unsafeResultMap: resultMap["removeDiscountCode"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "removeDiscountCode")
      }
    }

    public struct RemoveDiscountCode: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["RedemedCodeResult"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("campaigns", type: .nonNull(.list(.nonNull(.object(Campaign.selections))))),
        GraphQLField("cost", type: .nonNull(.object(Cost.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(campaigns: [Campaign], cost: Cost) {
        self.init(unsafeResultMap: ["__typename": "RedemedCodeResult", "campaigns": campaigns.map { (value: Campaign) -> ResultMap in value.resultMap }, "cost": cost.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The currently redeemed incentive, this can be null
      public var campaigns: [Campaign] {
        get {
          return (resultMap["campaigns"] as! [ResultMap]).map { (value: ResultMap) -> Campaign in Campaign(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Campaign) -> ResultMap in value.resultMap }, forKey: "campaigns")
        }
      }

      public var cost: Cost {
        get {
          return Cost(unsafeResultMap: resultMap["cost"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "cost")
        }
      }

      public struct Campaign: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Campaign"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("code", type: .nonNull(.scalar(String.self))),
          GraphQLField("incentive", type: .object(Incentive.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(code: String, incentive: Incentive? = nil) {
          self.init(unsafeResultMap: ["__typename": "Campaign", "code": code, "incentive": incentive.flatMap { (value: Incentive) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var code: String {
          get {
            return resultMap["code"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "code")
          }
        }

        public var incentive: Incentive? {
          get {
            return (resultMap["incentive"] as? ResultMap).flatMap { Incentive(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "incentive")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var campaignFragment: CampaignFragment {
            get {
              return CampaignFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Incentive: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonthlyCostDeduction", "FreeMonths", "NoDiscount", "PercentageDiscountMonths"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["FreeMonths": AsFreeMonths.selections, "MonthlyCostDeduction": AsMonthlyCostDeduction.selections, "PercentageDiscountMonths": AsPercentageDiscountMonths.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeNoDiscount() -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "NoDiscount"])
          }

          public static func makeFreeMonths(quantity: Int? = nil) -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
          }

          public static func makeMonthlyCostDeduction(amount: AsMonthlyCostDeduction.Amount? = nil) -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: AsMonthlyCostDeduction.Amount) -> ResultMap in value.resultMap }])
          }

          public static func makePercentageDiscountMonths(percentageDiscount: Double, percentageNumberOfMonths: Int) -> Incentive {
            return Incentive(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var incentiveFragment: IncentiveFragment {
              get {
                return IncentiveFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public var asFreeMonths: AsFreeMonths? {
            get {
              if !AsFreeMonths.possibleTypes.contains(__typename) { return nil }
              return AsFreeMonths(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsFreeMonths: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["FreeMonths"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("quantity", type: .scalar(Int.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(quantity: Int? = nil) {
              self.init(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var quantity: Int? {
              get {
                return resultMap["quantity"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "quantity")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var incentiveFragment: IncentiveFragment {
                get {
                  return IncentiveFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }

          public var asMonthlyCostDeduction: AsMonthlyCostDeduction? {
            get {
              if !AsMonthlyCostDeduction.possibleTypes.contains(__typename) { return nil }
              return AsMonthlyCostDeduction(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsMonthlyCostDeduction: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MonthlyCostDeduction"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("amount", type: .object(Amount.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(amount: Amount? = nil) {
              self.init(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: Amount) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var amount: Amount? {
              get {
                return (resultMap["amount"] as? ResultMap).flatMap { Amount(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "amount")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var incentiveFragment: IncentiveFragment {
                get {
                  return IncentiveFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct Amount: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MonetaryAmountV2"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("amount", type: .nonNull(.scalar(String.self))),
                GraphQLField("currency", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(amount: String, currency: String) {
                self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var amount: String {
                get {
                  return resultMap["amount"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "amount")
                }
              }

              public var currency: String {
                get {
                  return resultMap["currency"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "currency")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var monetaryAmountFragment: MonetaryAmountFragment {
                  get {
                    return MonetaryAmountFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }
          }

          public var asPercentageDiscountMonths: AsPercentageDiscountMonths? {
            get {
              if !AsPercentageDiscountMonths.possibleTypes.contains(__typename) { return nil }
              return AsPercentageDiscountMonths(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsPercentageDiscountMonths: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["PercentageDiscountMonths"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("percentageDiscount", type: .nonNull(.scalar(Double.self))),
              GraphQLField("quantity", alias: "percentageNumberOfMonths", type: .nonNull(.scalar(Int.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(percentageDiscount: Double, percentageNumberOfMonths: Int) {
              self.init(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var percentageDiscount: Double {
              get {
                return resultMap["percentageDiscount"]! as! Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "percentageDiscount")
              }
            }

            public var percentageNumberOfMonths: Int {
              get {
                return resultMap["percentageNumberOfMonths"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "percentageNumberOfMonths")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var incentiveFragment: IncentiveFragment {
                get {
                  return IncentiveFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }
      }

      public struct Cost: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["InsuranceCost"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("freeUntil", type: .scalar(String.self)),
          GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
          GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
          GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
          self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var freeUntil: String? {
          get {
            return resultMap["freeUntil"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "freeUntil")
          }
        }

        public var monthlyDiscount: MonthlyDiscount {
          get {
            return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
          }
        }

        public var monthlyGross: MonthlyGross {
          get {
            return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
          }
        }

        public var monthlyNet: MonthlyNet {
          get {
            return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var costFragment: CostFragment {
            get {
              return CostFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct MonthlyDiscount: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }

        public struct MonthlyGross: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }

        public struct MonthlyNet: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MonetaryAmountV2"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("amount", type: .nonNull(.scalar(String.self))),
            GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(amount: String, currency: String) {
            self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var amount: String {
            get {
              return resultMap["amount"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "amount")
            }
          }

          public var currency: String {
            get {
              return resultMap["currency"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }
        }
      }
    }
  }
}

public final class RemoveStartDateMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation RemoveStartDate($id: ID!) {
      removeStartDate(input: {id: $id}) {
        __typename
        ... on CompleteQuote {
          id
          startDate
        }
      }
    }
    """

  public let operationName: String = "RemoveStartDate"

  public let operationIdentifier: String? = "7d6fdcd8e05997baadab9f30c73c15acfa5056c343827ecce9fa31dd668077b3"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeStartDate", arguments: ["input": ["id": GraphQLVariable("id")]], type: .nonNull(.object(RemoveStartDate.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeStartDate: RemoveStartDate) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeStartDate": removeStartDate.resultMap])
    }

    public var removeStartDate: RemoveStartDate {
      get {
        return RemoveStartDate(unsafeResultMap: resultMap["removeStartDate"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "removeStartDate")
      }
    }

    public struct RemoveStartDate: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CompleteQuote", "UnderwritingLimitsHit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["CompleteQuote": AsCompleteQuote.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeUnderwritingLimitsHit() -> RemoveStartDate {
        return RemoveStartDate(unsafeResultMap: ["__typename": "UnderwritingLimitsHit"])
      }

      public static func makeCompleteQuote(id: GraphQLID, startDate: String? = nil) -> RemoveStartDate {
        return RemoveStartDate(unsafeResultMap: ["__typename": "CompleteQuote", "id": id, "startDate": startDate])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asCompleteQuote: AsCompleteQuote? {
        get {
          if !AsCompleteQuote.possibleTypes.contains(__typename) { return nil }
          return AsCompleteQuote(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsCompleteQuote: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CompleteQuote"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("startDate", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, startDate: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "CompleteQuote", "id": id, "startDate": startDate])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var startDate: String? {
          get {
            return resultMap["startDate"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startDate")
          }
        }
      }
    }
  }
}

public final class SelectCharityMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SelectCharity($id: ID!) {
      selectCashbackOption(id: $id) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "SelectCharity"

  public let operationIdentifier: String? = "fef5f10d0ca69b23d95e1b8758256a578d48fc55d92db3253e35094523f91d27"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("selectCashbackOption", arguments: ["id": GraphQLVariable("id")], type: .nonNull(.object(SelectCashbackOption.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(selectCashbackOption: SelectCashbackOption) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "selectCashbackOption": selectCashbackOption.resultMap])
    }

    public var selectCashbackOption: SelectCashbackOption {
      get {
        return SelectCashbackOption(unsafeResultMap: resultMap["selectCashbackOption"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "selectCashbackOption")
      }
    }

    public struct SelectCashbackOption: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Cashback"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(GraphQLID.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil) {
        self.init(unsafeResultMap: ["__typename": "Cashback", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class SelectedCharityQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query SelectedCharity {
      cashback {
        __typename
        id
        name
        title
        imageUrl
        description
        paragraph
      }
    }
    """

  public let operationName: String = "SelectedCharity"

  public let operationIdentifier: String? = "f4ff185ba12cf7f9df033cf6c1effac494930283ed097c0e94f790dfa9bfdb3d"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("cashback", type: .object(Cashback.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(cashback: Cashback? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "cashback": cashback.flatMap { (value: Cashback) -> ResultMap in value.resultMap }])
    }

    public var cashback: Cashback? {
      get {
        return (resultMap["cashback"] as? ResultMap).flatMap { Cashback(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "cashback")
      }
    }

    public struct Cashback: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Cashback"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(GraphQLID.self)),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("title", type: .scalar(String.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("paragraph", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, name: String? = nil, title: String? = nil, imageUrl: String? = nil, description: String? = nil, paragraph: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Cashback", "id": id, "name": name, "title": title, "imageUrl": imageUrl, "description": description, "paragraph": paragraph])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var title: String? {
        get {
          return resultMap["title"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public var imageUrl: String? {
        get {
          return resultMap["imageUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var description: String? {
        get {
          return resultMap["description"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "description")
        }
      }

      public var paragraph: String? {
        get {
          return resultMap["paragraph"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "paragraph")
        }
      }
    }
  }
}

public final class SendChatAudioResponseMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SendChatAudioResponse($globalID: ID!, $file: Upload!) {
      sendChatAudioResponse(input: {globalId: $globalID, file: $file})
    }
    """

  public let operationName: String = "SendChatAudioResponse"

  public let operationIdentifier: String? = "9aad937432f3d7e27868e3992a6aa1a330c267f40293e67407edeb63230320a8"

  public var globalID: GraphQLID
  public var file: String

  public init(globalID: GraphQLID, file: String) {
    self.globalID = globalID
    self.file = file
  }

  public var variables: GraphQLMap? {
    return ["globalID": globalID, "file": file]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sendChatAudioResponse", arguments: ["input": ["globalId": GraphQLVariable("globalID"), "file": GraphQLVariable("file")]], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendChatAudioResponse: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendChatAudioResponse": sendChatAudioResponse])
    }

    public var sendChatAudioResponse: Bool {
      get {
        return resultMap["sendChatAudioResponse"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendChatAudioResponse")
      }
    }
  }
}

public final class SendChatFileResponseMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SendChatFileResponse($globalID: ID!, $key: String!, $mimeType: String!) {
      sendChatFileResponse(input: {globalId: $globalID, body: {key: $key, mimeType: $mimeType}})
    }
    """

  public let operationName: String = "SendChatFileResponse"

  public let operationIdentifier: String? = "b2b51a542eaa7a6ce8018271c6a725e9b063ca29bf37b613c37fdd785e071c44"

  public var globalID: GraphQLID
  public var key: String
  public var mimeType: String

  public init(globalID: GraphQLID, key: String, mimeType: String) {
    self.globalID = globalID
    self.key = key
    self.mimeType = mimeType
  }

  public var variables: GraphQLMap? {
    return ["globalID": globalID, "key": key, "mimeType": mimeType]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sendChatFileResponse", arguments: ["input": ["globalId": GraphQLVariable("globalID"), "body": ["key": GraphQLVariable("key"), "mimeType": GraphQLVariable("mimeType")]]], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendChatFileResponse: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendChatFileResponse": sendChatFileResponse])
    }

    public var sendChatFileResponse: Bool {
      get {
        return resultMap["sendChatFileResponse"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendChatFileResponse")
      }
    }
  }
}

public final class SendChatSingleSelectResponseMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SendChatSingleSelectResponse($globalId: ID!, $selectedValue: ID!) {
      sendChatSingleSelectResponse(input: {globalId: $globalId, body: {selectedValue: $selectedValue}})
    }
    """

  public let operationName: String = "SendChatSingleSelectResponse"

  public let operationIdentifier: String? = "50a3e67f58b90685487f84e6444fa5f7fb9d1beba8a57cd72b2fc249847c2ef7"

  public var globalId: GraphQLID
  public var selectedValue: GraphQLID

  public init(globalId: GraphQLID, selectedValue: GraphQLID) {
    self.globalId = globalId
    self.selectedValue = selectedValue
  }

  public var variables: GraphQLMap? {
    return ["globalId": globalId, "selectedValue": selectedValue]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sendChatSingleSelectResponse", arguments: ["input": ["globalId": GraphQLVariable("globalId"), "body": ["selectedValue": GraphQLVariable("selectedValue")]]], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendChatSingleSelectResponse: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendChatSingleSelectResponse": sendChatSingleSelectResponse])
    }

    public var sendChatSingleSelectResponse: Bool {
      get {
        return resultMap["sendChatSingleSelectResponse"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendChatSingleSelectResponse")
      }
    }
  }
}

public final class SendChatTextResponseMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SendChatTextResponse($globalId: ID!, $text: String!) {
      sendChatTextResponse(input: {globalId: $globalId, body: {text: $text}})
    }
    """

  public let operationName: String = "SendChatTextResponse"

  public let operationIdentifier: String? = "d17ef6107c1996703a75e3f26950df1edaecb9e04615e75dd05647834d133311"

  public var globalId: GraphQLID
  public var text: String

  public init(globalId: GraphQLID, text: String) {
    self.globalId = globalId
    self.text = text
  }

  public var variables: GraphQLMap? {
    return ["globalId": globalId, "text": text]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sendChatTextResponse", arguments: ["input": ["globalId": GraphQLVariable("globalId"), "body": ["text": GraphQLVariable("text")]]], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendChatTextResponse: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendChatTextResponse": sendChatTextResponse])
    }

    public var sendChatTextResponse: Bool {
      get {
        return resultMap["sendChatTextResponse"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendChatTextResponse")
      }
    }
  }
}

public final class SignOfferMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SignOffer {
      signOfferV2 {
        __typename
        autoStartToken
      }
    }
    """

  public let operationName: String = "SignOffer"

  public let operationIdentifier: String? = "8b98850ac61596f74105b09026a9b1496986c89769dcea03bf88db0cba4a107c"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("signOfferV2", type: .nonNull(.object(SignOfferV2.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(signOfferV2: SignOfferV2) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "signOfferV2": signOfferV2.resultMap])
    }

    public var signOfferV2: SignOfferV2 {
      get {
        return SignOfferV2(unsafeResultMap: resultMap["signOfferV2"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "signOfferV2")
      }
    }

    public struct SignOfferV2: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["BankIdSignResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("autoStartToken", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(autoStartToken: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "BankIdSignResponse", "autoStartToken": autoStartToken])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var autoStartToken: String? {
        get {
          return resultMap["autoStartToken"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "autoStartToken")
        }
      }
    }
  }
}

public final class SignStatusSubscription: GraphQLSubscription {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    subscription SignStatus {
      signStatus {
        __typename
        status {
          __typename
          collectStatus {
            __typename
            status
            code
          }
          signState
        }
      }
    }
    """

  public let operationName: String = "SignStatus"

  public let operationIdentifier: String? = "1ec6d91540b53bdc883068ef71f3a5c0dbd4f525e6acc2d526aa2df841480898"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("signStatus", type: .object(SignStatus.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(signStatus: SignStatus? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "signStatus": signStatus.flatMap { (value: SignStatus) -> ResultMap in value.resultMap }])
    }

    public var signStatus: SignStatus? {
      get {
        return (resultMap["signStatus"] as? ResultMap).flatMap { SignStatus(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "signStatus")
      }
    }

    public struct SignStatus: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SignEvent"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("status", type: .object(Status.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(status: Status? = nil) {
        self.init(unsafeResultMap: ["__typename": "SignEvent", "status": status.flatMap { (value: Status) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var status: Status? {
        get {
          return (resultMap["status"] as? ResultMap).flatMap { Status(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "status")
        }
      }

      public struct Status: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SignStatus"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("collectStatus", type: .object(CollectStatus.selections)),
          GraphQLField("signState", type: .scalar(SignState.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(collectStatus: CollectStatus? = nil, signState: SignState? = nil) {
          self.init(unsafeResultMap: ["__typename": "SignStatus", "collectStatus": collectStatus.flatMap { (value: CollectStatus) -> ResultMap in value.resultMap }, "signState": signState])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var collectStatus: CollectStatus? {
          get {
            return (resultMap["collectStatus"] as? ResultMap).flatMap { CollectStatus(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "collectStatus")
          }
        }

        public var signState: SignState? {
          get {
            return resultMap["signState"] as? SignState
          }
          set {
            resultMap.updateValue(newValue, forKey: "signState")
          }
        }

        public struct CollectStatus: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["CollectStatus"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("status", type: .scalar(BankIdStatus.self)),
            GraphQLField("code", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(status: BankIdStatus? = nil, code: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "CollectStatus", "status": status, "code": code])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var status: BankIdStatus? {
            get {
              return resultMap["status"] as? BankIdStatus
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }

          public var code: String? {
            get {
              return resultMap["code"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "code")
            }
          }
        }
      }
    }
  }
}

public final class StartDirectDebitRegistrationMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation StartDirectDebitRegistration {
      startDirectDebitRegistration
    }
    """

  public let operationName: String = "StartDirectDebitRegistration"

  public let operationIdentifier: String? = "920328423f6b60eb57388371c2fa3f233f8b87d17f16040ab4044635110c2139"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("startDirectDebitRegistration", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(startDirectDebitRegistration: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "startDirectDebitRegistration": startDirectDebitRegistration])
    }

    public var startDirectDebitRegistration: String {
      get {
        return resultMap["startDirectDebitRegistration"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "startDirectDebitRegistration")
      }
    }
  }
}

public final class TranslationsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Translations($code: String) {
      languages(where: {code: $code}) {
        __typename
        translations(where: {project_in: [IOS, App]}) {
          __typename
          key {
            __typename
            value
          }
          text
        }
      }
    }
    """

  public let operationName: String = "Translations"

  public let operationIdentifier: String? = "a70f6991bca3f523836e87b5a257e5bf4466a58f0fbd6756488f5273a30a316a"

  public var code: String?

  public init(code: String? = nil) {
    self.code = code
  }

  public var variables: GraphQLMap? {
    return ["code": code]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("languages", arguments: ["where": ["code": GraphQLVariable("code")]], type: .nonNull(.list(.object(Language.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(languages: [Language?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "languages": languages.map { (value: Language?) -> ResultMap? in value.flatMap { (value: Language) -> ResultMap in value.resultMap } }])
    }

    public var languages: [Language?] {
      get {
        return (resultMap["languages"] as! [ResultMap?]).map { (value: ResultMap?) -> Language? in value.flatMap { (value: ResultMap) -> Language in Language(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Language?) -> ResultMap? in value.flatMap { (value: Language) -> ResultMap in value.resultMap } }, forKey: "languages")
      }
    }

    public struct Language: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Language"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("translations", arguments: ["where": ["project_in": ["IOS", "App"]]], type: .list(.nonNull(.object(Translation.selections)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(translations: [Translation]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Language", "translations": translations.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var translations: [Translation]? {
        get {
          return (resultMap["translations"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Translation] in value.map { (value: ResultMap) -> Translation in Translation(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }, forKey: "translations")
        }
      }

      public struct Translation: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Translation"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .object(Key.selections)),
          GraphQLField("text", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(key: Key? = nil, text: String) {
          self.init(unsafeResultMap: ["__typename": "Translation", "key": key.flatMap { (value: Key) -> ResultMap in value.resultMap }, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var key: Key? {
          get {
            return (resultMap["key"] as? ResultMap).flatMap { Key(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "key")
          }
        }

        public var text: String {
          get {
            return resultMap["text"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "text")
          }
        }

        public struct Key: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Key"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("value", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(value: String) {
            self.init(unsafeResultMap: ["__typename": "Key", "value": value])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var value: String {
            get {
              return resultMap["value"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "value")
            }
          }
        }
      }
    }
  }
}

public final class TriggerCallMeChatMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation TriggerCallMeChat {
      triggerCallMeChat
    }
    """

  public let operationName: String = "TriggerCallMeChat"

  public let operationIdentifier: String? = "140d647b4468f8d8f20fb9d15df54176bdff4ad7e724b8673743b04889de89ac"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("triggerCallMeChat", type: .scalar(Bool.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(triggerCallMeChat: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "triggerCallMeChat": triggerCallMeChat])
    }

    public var triggerCallMeChat: Bool? {
      get {
        return resultMap["triggerCallMeChat"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "triggerCallMeChat")
      }
    }
  }
}

public final class TriggerClaimChatMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation TriggerClaimChat($claimTypeId: ID) {
      triggerClaimChat(input: {claimTypeId: $claimTypeId})
    }
    """

  public let operationName: String = "TriggerClaimChat"

  public let operationIdentifier: String? = "de42518bf2e68e1b37226f0004d7c50d6208c6e3d8f7d04ed89f40c00767618f"

  public var claimTypeId: GraphQLID?

  public init(claimTypeId: GraphQLID? = nil) {
    self.claimTypeId = claimTypeId
  }

  public var variables: GraphQLMap? {
    return ["claimTypeId": claimTypeId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("triggerClaimChat", arguments: ["input": ["claimTypeId": GraphQLVariable("claimTypeId")]], type: .scalar(Bool.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(triggerClaimChat: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "triggerClaimChat": triggerClaimChat])
    }

    public var triggerClaimChat: Bool? {
      get {
        return resultMap["triggerClaimChat"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "triggerClaimChat")
      }
    }
  }
}

public final class TriggerFreeTextChatMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation TriggerFreeTextChat {
      triggerFreeTextChat
    }
    """

  public let operationName: String = "TriggerFreeTextChat"

  public let operationIdentifier: String? = "77a7314edb7ddce98083b1d7351f25e40120c8f95964cf5fc49a1cdeff0656a4"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("triggerFreeTextChat", type: .scalar(Bool.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(triggerFreeTextChat: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "triggerFreeTextChat": triggerFreeTextChat])
    }

    public var triggerFreeTextChat: Bool? {
      get {
        return resultMap["triggerFreeTextChat"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "triggerFreeTextChat")
      }
    }
  }
}

public final class TriggerResetChatMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation TriggerResetChat {
      resetConversation
    }
    """

  public let operationName: String = "TriggerResetChat"

  public let operationIdentifier: String? = "6f53559ed574f6cc86aafbe52e815854ae966db35602b17eb24241e992f6f19b"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("resetConversation", type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(resetConversation: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "resetConversation": resetConversation])
    }

    public var resetConversation: Bool {
      get {
        return resultMap["resetConversation"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "resetConversation")
      }
    }
  }
}

public final class UpdateEmailMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateEmail($email: String!) {
      updateEmail(input: $email) {
        __typename
        email
      }
    }
    """

  public let operationName: String = "UpdateEmail"

  public let operationIdentifier: String? = "b647262011d41b10974cf6210880211bbfbfd8c702bda6b1bd675f850badc8d3"

  public var email: String

  public init(email: String) {
    self.email = email
  }

  public var variables: GraphQLMap? {
    return ["email": email]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateEmail", arguments: ["input": GraphQLVariable("email")], type: .nonNull(.object(UpdateEmail.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateEmail: UpdateEmail) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateEmail": updateEmail.resultMap])
    }

    public var updateEmail: UpdateEmail {
      get {
        return UpdateEmail(unsafeResultMap: resultMap["updateEmail"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateEmail")
      }
    }

    public struct UpdateEmail: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("email", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(email: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Member", "email": email])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var email: String? {
        get {
          return resultMap["email"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "email")
        }
      }
    }
  }
}

public final class UpdateKeyGearItemNameMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateKeyGearItemName($id: ID!, $name: String!) {
      updateKeyGearItemName(itemId: $id, updatedName: $name) {
        __typename
        name
      }
    }
    """

  public let operationName: String = "UpdateKeyGearItemName"

  public let operationIdentifier: String? = "8b11b6763551778d24a192ef222079e627605ffdcc4f38303b3a8db932448b55"

  public var id: GraphQLID
  public var name: String

  public init(id: GraphQLID, name: String) {
    self.id = id
    self.name = name
  }

  public var variables: GraphQLMap? {
    return ["id": id, "name": name]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateKeyGearItemName", arguments: ["itemId": GraphQLVariable("id"), "updatedName": GraphQLVariable("name")], type: .nonNull(.object(UpdateKeyGearItemName.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateKeyGearItemName: UpdateKeyGearItemName) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateKeyGearItemName": updateKeyGearItemName.resultMap])
    }

    public var updateKeyGearItemName: UpdateKeyGearItemName {
      get {
        return UpdateKeyGearItemName(unsafeResultMap: resultMap["updateKeyGearItemName"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateKeyGearItemName")
      }
    }

    public struct UpdateKeyGearItemName: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// If this item was added automatically - what was the Hash of the identifiable information?
      /// Use this to avoid automatically adding an Item which the user has already automatically added or
      /// does not wish to have automatically added
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class UpdateKeyGearValuationMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateKeyGearValuation($itemId: ID!, $purchasePrice: MonetaryAmountV2Input!, $purchaseDate: LocalDate!) {
      updatePurchasePriceForKeyGearItem(itemId: $itemId, newPrice: $purchasePrice) {
        __typename
        id
      }
      updateTimeOfPurchaseForKeyGearItem(id: $itemId, newTimeOfPurchase: $purchaseDate) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "UpdateKeyGearValuation"

  public let operationIdentifier: String? = "c475e1019588e68d6b75af2b4d7e7e089e1c5027f89885c1c975802802ede616"

  public var itemId: GraphQLID
  public var purchasePrice: MonetaryAmountV2Input
  public var purchaseDate: String

  public init(itemId: GraphQLID, purchasePrice: MonetaryAmountV2Input, purchaseDate: String) {
    self.itemId = itemId
    self.purchasePrice = purchasePrice
    self.purchaseDate = purchaseDate
  }

  public var variables: GraphQLMap? {
    return ["itemId": itemId, "purchasePrice": purchasePrice, "purchaseDate": purchaseDate]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updatePurchasePriceForKeyGearItem", arguments: ["itemId": GraphQLVariable("itemId"), "newPrice": GraphQLVariable("purchasePrice")], type: .nonNull(.object(UpdatePurchasePriceForKeyGearItem.selections))),
      GraphQLField("updateTimeOfPurchaseForKeyGearItem", arguments: ["id": GraphQLVariable("itemId"), "newTimeOfPurchase": GraphQLVariable("purchaseDate")], type: .nonNull(.object(UpdateTimeOfPurchaseForKeyGearItem.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updatePurchasePriceForKeyGearItem: UpdatePurchasePriceForKeyGearItem, updateTimeOfPurchaseForKeyGearItem: UpdateTimeOfPurchaseForKeyGearItem) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updatePurchasePriceForKeyGearItem": updatePurchasePriceForKeyGearItem.resultMap, "updateTimeOfPurchaseForKeyGearItem": updateTimeOfPurchaseForKeyGearItem.resultMap])
    }

    /// # send null to remove
    public var updatePurchasePriceForKeyGearItem: UpdatePurchasePriceForKeyGearItem {
      get {
        return UpdatePurchasePriceForKeyGearItem(unsafeResultMap: resultMap["updatePurchasePriceForKeyGearItem"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updatePurchasePriceForKeyGearItem")
      }
    }

    /// # send null to remove
    public var updateTimeOfPurchaseForKeyGearItem: UpdateTimeOfPurchaseForKeyGearItem {
      get {
        return UpdateTimeOfPurchaseForKeyGearItem(unsafeResultMap: resultMap["updateTimeOfPurchaseForKeyGearItem"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateTimeOfPurchaseForKeyGearItem")
      }
    }

    public struct UpdatePurchasePriceForKeyGearItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }

    public struct UpdateTimeOfPurchaseForKeyGearItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["KeyGearItem"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "KeyGearItem", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class UpdateLanguageMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateLanguage($language: String!, $pickedLocale: Locale!) {
      updateLanguage(input: $language)
      updatePickedLocale(pickedLocale: $pickedLocale) {
        __typename
        acceptLanguage
      }
    }
    """

  public let operationName: String = "UpdateLanguage"

  public let operationIdentifier: String? = "68f0cabb0c53297fec0b9ed2d76c2051255418e8b86052cf33c3b949d63650f1"

  public var language: String
  public var pickedLocale: Locale

  public init(language: String, pickedLocale: Locale) {
    self.language = language
    self.pickedLocale = pickedLocale
  }

  public var variables: GraphQLMap? {
    return ["language": language, "pickedLocale": pickedLocale]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateLanguage", arguments: ["input": GraphQLVariable("language")], type: .nonNull(.scalar(Bool.self))),
      GraphQLField("updatePickedLocale", arguments: ["pickedLocale": GraphQLVariable("pickedLocale")], type: .nonNull(.object(UpdatePickedLocale.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateLanguage: Bool, updatePickedLocale: UpdatePickedLocale) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateLanguage": updateLanguage, "updatePickedLocale": updatePickedLocale.resultMap])
    }

    public var updateLanguage: Bool {
      get {
        return resultMap["updateLanguage"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateLanguage")
      }
    }

    public var updatePickedLocale: UpdatePickedLocale {
      get {
        return UpdatePickedLocale(unsafeResultMap: resultMap["updatePickedLocale"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updatePickedLocale")
      }
    }

    public struct UpdatePickedLocale: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("acceptLanguage", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(acceptLanguage: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Member", "acceptLanguage": acceptLanguage])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var acceptLanguage: String? {
        get {
          return resultMap["acceptLanguage"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "acceptLanguage")
        }
      }
    }
  }
}

public final class UpdatePhoneNumberMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdatePhoneNumber($phoneNumber: String!) {
      updatePhoneNumber(input: $phoneNumber) {
        __typename
        phoneNumber
      }
    }
    """

  public let operationName: String = "UpdatePhoneNumber"

  public let operationIdentifier: String? = "63bee85b5166db970f09651d2f2ee964a0849a649df2d8aa9ea262465711d750"

  public var phoneNumber: String

  public init(phoneNumber: String) {
    self.phoneNumber = phoneNumber
  }

  public var variables: GraphQLMap? {
    return ["phoneNumber": phoneNumber]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updatePhoneNumber", arguments: ["input": GraphQLVariable("phoneNumber")], type: .nonNull(.object(UpdatePhoneNumber.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updatePhoneNumber: UpdatePhoneNumber) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updatePhoneNumber": updatePhoneNumber.resultMap])
    }

    public var updatePhoneNumber: UpdatePhoneNumber {
      get {
        return UpdatePhoneNumber(unsafeResultMap: resultMap["updatePhoneNumber"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updatePhoneNumber")
      }
    }

    public struct UpdatePhoneNumber: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Member"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("phoneNumber", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(phoneNumber: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Member", "phoneNumber": phoneNumber])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var phoneNumber: String? {
        get {
          return resultMap["phoneNumber"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "phoneNumber")
        }
      }
    }
  }
}

public final class UploadFileMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UploadFile($file: Upload!) {
      uploadFile(file: $file) {
        __typename
        signedUrl
        key
        bucket
      }
    }
    """

  public let operationName: String = "UploadFile"

  public let operationIdentifier: String? = "359cc1d4de6cba613c61cc02581340e643b52c0b61a19444e512ddb37dc7b3a0"

  public var file: String

  public init(file: String) {
    self.file = file
  }

  public var variables: GraphQLMap? {
    return ["file": file]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadFile", arguments: ["file": GraphQLVariable("file")], type: .nonNull(.object(UploadFile.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(uploadFile: UploadFile) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "uploadFile": uploadFile.resultMap])
    }

    public var uploadFile: UploadFile {
      get {
        return UploadFile(unsafeResultMap: resultMap["uploadFile"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "uploadFile")
      }
    }

    public struct UploadFile: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["File"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("signedUrl", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(signedUrl: String, key: String, bucket: String) {
        self.init(unsafeResultMap: ["__typename": "File", "signedUrl": signedUrl, "key": key, "bucket": bucket])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// signedUrl is valid for 30 minutes after upload, don't hang on to this.
      public var signedUrl: String {
        get {
          return resultMap["signedUrl"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "signedUrl")
        }
      }

      /// S3 key that can be used to retreive new signed urls in the future.
      public var key: String {
        get {
          return resultMap["key"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "key")
        }
      }

      /// S3 bucket that the file was uploaded to.
      public var bucket: String {
        get {
          return resultMap["bucket"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "bucket")
        }
      }
    }
  }
}

public final class UploadFilesMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UploadFiles($files: [Upload!]!) {
      uploadFiles(files: $files) {
        __typename
        signedUrl
        key
        bucket
      }
    }
    """

  public let operationName: String = "UploadFiles"

  public let operationIdentifier: String? = "2bae54ddb72c547ee38848896aef4d54af05aba233aa8f25c2d87cdb24cabb26"

  public var files: [String]

  public init(files: [String]) {
    self.files = files
  }

  public var variables: GraphQLMap? {
    return ["files": files]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadFiles", arguments: ["files": GraphQLVariable("files")], type: .list(.nonNull(.object(UploadFile.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(uploadFiles: [UploadFile]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "uploadFiles": uploadFiles.flatMap { (value: [UploadFile]) -> [ResultMap] in value.map { (value: UploadFile) -> ResultMap in value.resultMap } }])
    }

    public var uploadFiles: [UploadFile]? {
      get {
        return (resultMap["uploadFiles"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [UploadFile] in value.map { (value: ResultMap) -> UploadFile in UploadFile(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [UploadFile]) -> [ResultMap] in value.map { (value: UploadFile) -> ResultMap in value.resultMap } }, forKey: "uploadFiles")
      }
    }

    public struct UploadFile: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["File"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("signedUrl", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(signedUrl: String, key: String, bucket: String) {
        self.init(unsafeResultMap: ["__typename": "File", "signedUrl": signedUrl, "key": key, "bucket": bucket])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// signedUrl is valid for 30 minutes after upload, don't hang on to this.
      public var signedUrl: String {
        get {
          return resultMap["signedUrl"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "signedUrl")
        }
      }

      /// S3 key that can be used to retreive new signed urls in the future.
      public var key: String {
        get {
          return resultMap["key"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "key")
        }
      }

      /// S3 bucket that the file was uploaded to.
      public var bucket: String {
        get {
          return resultMap["bucket"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "bucket")
        }
      }
    }
  }
}

public final class WelcomeQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Welcome($locale: Locale!) {
      welcome(platform: iOS, locale: $locale) {
        __typename
        illustration {
          __typename
          ...IconFragment
        }
        title
        paragraph
      }
    }
    """

  public let operationName: String = "Welcome"

  public let operationIdentifier: String? = "97dd247c880c5dcfa8b346fa272bc1ae75a14eef83facf227e2c91b8d79a8fde"

  public var queryDocument: String { return operationDefinition.appending(IconFragment.fragmentDefinition) }

  public var locale: Locale

  public init(locale: Locale) {
    self.locale = locale
  }

  public var variables: GraphQLMap? {
    return ["locale": locale]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("welcome", arguments: ["platform": "iOS", "locale": GraphQLVariable("locale")], type: .nonNull(.list(.nonNull(.object(Welcome.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(welcome: [Welcome]) {
      self.init(unsafeResultMap: ["__typename": "Query", "welcome": welcome.map { (value: Welcome) -> ResultMap in value.resultMap }])
    }

    public var welcome: [Welcome] {
      get {
        return (resultMap["welcome"] as! [ResultMap]).map { (value: ResultMap) -> Welcome in Welcome(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Welcome) -> ResultMap in value.resultMap }, forKey: "welcome")
      }
    }

    public struct Welcome: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Welcome"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("illustration", type: .nonNull(.object(Illustration.selections))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("paragraph", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(illustration: Illustration, title: String, paragraph: String) {
        self.init(unsafeResultMap: ["__typename": "Welcome", "illustration": illustration.resultMap, "title": title, "paragraph": paragraph])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Illustration shown for the page
      public var illustration: Illustration {
        get {
          return Illustration(unsafeResultMap: resultMap["illustration"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "illustration")
        }
      }

      /// Text key for the title of the page
      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      /// Text key for the paragraph shown below the title
      public var paragraph: String {
        get {
          return resultMap["paragraph"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "paragraph")
        }
      }

      public struct Illustration: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Icon"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(variants: Variant) {
          self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Icons with variants for light and dark mode
        public var variants: Variant {
          get {
            return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "variants")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var iconFragment: IconFragment {
            get {
              return IconFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Variant: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["IconVariants"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
            GraphQLField("light", type: .nonNull(.object(Light.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(dark: Dark, light: Light) {
            self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A variant to use for dark user interfaces
          public var dark: Dark {
            get {
              return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "dark")
            }
          }

          /// A variant to use for light user interfaces
          public var light: Light {
            get {
              return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "light")
            }
          }

          public struct Dark: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["IconVariant"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(pdfUrl: String) {
              self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// For iOS use
            public var pdfUrl: String {
              get {
                return resultMap["pdfUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "pdfUrl")
              }
            }
          }

          public struct Light: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["IconVariant"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(pdfUrl: String) {
              self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// For iOS use
            public var pdfUrl: String {
              get {
                return resultMap["pdfUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "pdfUrl")
              }
            }
          }
        }
      }
    }
  }
}

public final class WhatsNewQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query WhatsNew($locale: Locale!, $sinceVersion: String!) {
      news(platform: iOS, locale: $locale, sinceVersion: $sinceVersion) {
        __typename
        illustration {
          __typename
          ...IconFragment
        }
        title
        paragraph
      }
    }
    """

  public let operationName: String = "WhatsNew"

  public let operationIdentifier: String? = "203f316e8c8e550f5beaf5ead26d169c598aa40ddf36aed3fefc6bcc6ffad75b"

  public var queryDocument: String { return operationDefinition.appending(IconFragment.fragmentDefinition) }

  public var locale: Locale
  public var sinceVersion: String

  public init(locale: Locale, sinceVersion: String) {
    self.locale = locale
    self.sinceVersion = sinceVersion
  }

  public var variables: GraphQLMap? {
    return ["locale": locale, "sinceVersion": sinceVersion]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("news", arguments: ["platform": "iOS", "locale": GraphQLVariable("locale"), "sinceVersion": GraphQLVariable("sinceVersion")], type: .nonNull(.list(.nonNull(.object(News.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(news: [News]) {
      self.init(unsafeResultMap: ["__typename": "Query", "news": news.map { (value: News) -> ResultMap in value.resultMap }])
    }

    public var news: [News] {
      get {
        return (resultMap["news"] as! [ResultMap]).map { (value: ResultMap) -> News in News(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: News) -> ResultMap in value.resultMap }, forKey: "news")
      }
    }

    public struct News: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["News"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("illustration", type: .nonNull(.object(Illustration.selections))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("paragraph", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(illustration: Illustration, title: String, paragraph: String) {
        self.init(unsafeResultMap: ["__typename": "News", "illustration": illustration.resultMap, "title": title, "paragraph": paragraph])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Illustration shown for the page
      public var illustration: Illustration {
        get {
          return Illustration(unsafeResultMap: resultMap["illustration"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "illustration")
        }
      }

      /// Text key for the title of the page
      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      /// Text key for the paragraph shown below the title
      public var paragraph: String {
        get {
          return resultMap["paragraph"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "paragraph")
        }
      }

      public struct Illustration: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Icon"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(variants: Variant) {
          self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Icons with variants for light and dark mode
        public var variants: Variant {
          get {
            return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "variants")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var iconFragment: IconFragment {
            get {
              return IconFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Variant: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["IconVariants"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
            GraphQLField("light", type: .nonNull(.object(Light.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(dark: Dark, light: Light) {
            self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A variant to use for dark user interfaces
          public var dark: Dark {
            get {
              return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "dark")
            }
          }

          /// A variant to use for light user interfaces
          public var light: Light {
            get {
              return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "light")
            }
          }

          public struct Dark: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["IconVariant"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(pdfUrl: String) {
              self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// For iOS use
            public var pdfUrl: String {
              get {
                return resultMap["pdfUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "pdfUrl")
              }
            }
          }

          public struct Light: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["IconVariant"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(pdfUrl: String) {
              self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// For iOS use
            public var pdfUrl: String {
              get {
                return resultMap["pdfUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "pdfUrl")
              }
            }
          }
        }
      }
    }
  }
}

public struct CampaignFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CampaignFragment on Campaign {
      __typename
      code
      incentive {
        __typename
        ...IncentiveFragment
      }
    }
    """

  public static let possibleTypes: [String] = ["Campaign"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("code", type: .nonNull(.scalar(String.self))),
    GraphQLField("incentive", type: .object(Incentive.selections)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(code: String, incentive: Incentive? = nil) {
    self.init(unsafeResultMap: ["__typename": "Campaign", "code": code, "incentive": incentive.flatMap { (value: Incentive) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var code: String {
    get {
      return resultMap["code"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "code")
    }
  }

  public var incentive: Incentive? {
    get {
      return (resultMap["incentive"] as? ResultMap).flatMap { Incentive(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "incentive")
    }
  }

  public struct Incentive: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MonthlyCostDeduction", "FreeMonths", "NoDiscount", "PercentageDiscountMonths"]

    public static let selections: [GraphQLSelection] = [
      GraphQLTypeCase(
        variants: ["FreeMonths": AsFreeMonths.selections, "MonthlyCostDeduction": AsMonthlyCostDeduction.selections, "PercentageDiscountMonths": AsPercentageDiscountMonths.selections],
        default: [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        ]
      )
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeNoDiscount() -> Incentive {
      return Incentive(unsafeResultMap: ["__typename": "NoDiscount"])
    }

    public static func makeFreeMonths(quantity: Int? = nil) -> Incentive {
      return Incentive(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
    }

    public static func makeMonthlyCostDeduction(amount: AsMonthlyCostDeduction.Amount? = nil) -> Incentive {
      return Incentive(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: AsMonthlyCostDeduction.Amount) -> ResultMap in value.resultMap }])
    }

    public static func makePercentageDiscountMonths(percentageDiscount: Double, percentageNumberOfMonths: Int) -> Incentive {
      return Incentive(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var incentiveFragment: IncentiveFragment {
        get {
          return IncentiveFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public var asFreeMonths: AsFreeMonths? {
      get {
        if !AsFreeMonths.possibleTypes.contains(__typename) { return nil }
        return AsFreeMonths(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsFreeMonths: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["FreeMonths"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("quantity", type: .scalar(Int.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(quantity: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var quantity: Int? {
        get {
          return resultMap["quantity"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "quantity")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var incentiveFragment: IncentiveFragment {
          get {
            return IncentiveFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMonthlyCostDeduction: AsMonthlyCostDeduction? {
      get {
        if !AsMonthlyCostDeduction.possibleTypes.contains(__typename) { return nil }
        return AsMonthlyCostDeduction(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMonthlyCostDeduction: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MonthlyCostDeduction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .object(Amount.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: Amount? = nil) {
        self.init(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: Amount) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var amount: Amount? {
        get {
          return (resultMap["amount"] as? ResultMap).flatMap { Amount(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "amount")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var incentiveFragment: IncentiveFragment {
          get {
            return IncentiveFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Amount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MonetaryAmountV2"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(amount: String, currency: String) {
          self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var amount: String {
          get {
            return resultMap["amount"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "amount")
          }
        }

        public var currency: String {
          get {
            return resultMap["currency"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var monetaryAmountFragment: MonetaryAmountFragment {
            get {
              return MonetaryAmountFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }

    public var asPercentageDiscountMonths: AsPercentageDiscountMonths? {
      get {
        if !AsPercentageDiscountMonths.possibleTypes.contains(__typename) { return nil }
        return AsPercentageDiscountMonths(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsPercentageDiscountMonths: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PercentageDiscountMonths"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("percentageDiscount", type: .nonNull(.scalar(Double.self))),
        GraphQLField("quantity", alias: "percentageNumberOfMonths", type: .nonNull(.scalar(Int.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(percentageDiscount: Double, percentageNumberOfMonths: Int) {
        self.init(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var percentageDiscount: Double {
        get {
          return resultMap["percentageDiscount"]! as! Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "percentageDiscount")
        }
      }

      public var percentageNumberOfMonths: Int {
        get {
          return resultMap["percentageNumberOfMonths"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "percentageNumberOfMonths")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var incentiveFragment: IncentiveFragment {
          get {
            return IncentiveFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public struct MessageData: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MessageData on Message {
      __typename
      globalId
      id
      body {
        __typename
        ... on MessageBodySingleSelect {
          type
          id
          text
          choices {
            __typename
            ... on MessageBodyChoicesSelection {
              text
              value
            }
            ... on MessageBodyChoicesLink {
              view
              text
              value
            }
          }
        }
        ... on MessageBodyMultipleSelect {
          type
          id
          text
        }
        ... on MessageBodyText {
          type
          id
          text
          placeholder
          keyboard
          textContentType
        }
        ... on MessageBodyNumber {
          type
          id
          text
          placeholder
          keyboard
          textContentType
        }
        ... on MessageBodyAudio {
          type
          id
          text
        }
        ... on MessageBodyBankIdCollect {
          type
          id
          text
        }
        ... on MessageBodyFile {
          type
          id
          text
          mimeType
          file {
            __typename
            signedUrl
          }
        }
        ... on MessageBodyParagraph {
          type
          id
          text
        }
        ... on MessageBodyUndefined {
          type
          id
          text
        }
      }
      header {
        __typename
        messageId
        fromMyself
        timeStamp
        richTextChatCompatible
        editAllowed
        shouldRequestPushNotifications
        pollingInterval
        loadingIndicator
        statusMessage
      }
    }
    """

  public static let possibleTypes: [String] = ["Message"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("body", type: .nonNull(.object(Body.selections))),
    GraphQLField("header", type: .nonNull(.object(Header.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(globalId: GraphQLID, id: GraphQLID, body: Body, header: Header) {
    self.init(unsafeResultMap: ["__typename": "Message", "globalId": globalId, "id": id, "body": body.resultMap, "header": header.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var globalId: GraphQLID {
    get {
      return resultMap["globalId"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "globalId")
    }
  }

  public var id: GraphQLID {
    get {
      return resultMap["id"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var body: Body {
    get {
      return Body(unsafeResultMap: resultMap["body"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "body")
    }
  }

  public var header: Header {
    get {
      return Header(unsafeResultMap: resultMap["header"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "header")
    }
  }

  public struct Body: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

    public static let selections: [GraphQLSelection] = [
      GraphQLTypeCase(
        variants: ["MessageBodySingleSelect": AsMessageBodySingleSelect.selections, "MessageBodyMultipleSelect": AsMessageBodyMultipleSelect.selections, "MessageBodyText": AsMessageBodyText.selections, "MessageBodyNumber": AsMessageBodyNumber.selections, "MessageBodyAudio": AsMessageBodyAudio.selections, "MessageBodyBankIdCollect": AsMessageBodyBankIdCollect.selections, "MessageBodyFile": AsMessageBodyFile.selections, "MessageBodyParagraph": AsMessageBodyParagraph.selections, "MessageBodyUndefined": AsMessageBodyUndefined.selections],
        default: [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        ]
      )
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeMessageBodySingleSelect(type: String, id: GraphQLID, text: String, choices: [AsMessageBodySingleSelect.Choice?]? = nil) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "type": type, "id": id, "text": text, "choices": choices.flatMap { (value: [AsMessageBodySingleSelect.Choice?]) -> [ResultMap?] in value.map { (value: AsMessageBodySingleSelect.Choice?) -> ResultMap? in value.flatMap { (value: AsMessageBodySingleSelect.Choice) -> ResultMap in value.resultMap } } }])
    }

    public static func makeMessageBodyMultipleSelect(type: String, id: GraphQLID, text: String) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "type": type, "id": id, "text": text])
    }

    public static func makeMessageBodyText(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyText", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
    }

    public static func makeMessageBodyNumber(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyNumber", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
    }

    public static func makeMessageBodyAudio(type: String, id: GraphQLID, text: String) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyAudio", "type": type, "id": id, "text": text])
    }

    public static func makeMessageBodyBankIdCollect(type: String, id: GraphQLID, text: String) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "type": type, "id": id, "text": text])
    }

    public static func makeMessageBodyFile(type: String, id: GraphQLID, text: String, mimeType: String? = nil, file: AsMessageBodyFile.File) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyFile", "type": type, "id": id, "text": text, "mimeType": mimeType, "file": file.resultMap])
    }

    public static func makeMessageBodyParagraph(type: String, id: GraphQLID, text: String) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph", "type": type, "id": id, "text": text])
    }

    public static func makeMessageBodyUndefined(type: String, id: GraphQLID, text: String) -> Body {
      return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined", "type": type, "id": id, "text": text])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asMessageBodySingleSelect: AsMessageBodySingleSelect? {
      get {
        if !AsMessageBodySingleSelect.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodySingleSelect(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodySingleSelect: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodySingleSelect"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("choices", type: .list(.object(Choice.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String, choices: [Choice?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "type": type, "id": id, "text": text, "choices": choices.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var choices: [Choice?]? {
        get {
          return (resultMap["choices"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Choice?] in value.map { (value: ResultMap?) -> Choice? in value.flatMap { (value: ResultMap) -> Choice in Choice(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }, forKey: "choices")
        }
      }

      public struct Choice: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MessageBodyChoicesUndefined", "MessageBodyChoicesSelection", "MessageBodyChoicesLink"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["MessageBodyChoicesSelection": AsMessageBodyChoicesSelection.selections, "MessageBodyChoicesLink": AsMessageBodyChoicesLink.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodyChoicesUndefined() -> Choice {
          return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesUndefined"])
        }

        public static func makeMessageBodyChoicesSelection(text: String, value: String) -> Choice {
          return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "text": text, "value": value])
        }

        public static func makeMessageBodyChoicesLink(view: MessageBodyChoicesLinkView? = nil, text: String, value: String) -> Choice {
          return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "view": view, "text": text, "value": value])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asMessageBodyChoicesSelection: AsMessageBodyChoicesSelection? {
          get {
            if !AsMessageBodyChoicesSelection.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyChoicesSelection(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyChoicesSelection: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyChoicesSelection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("value", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String, value: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "text": text, "value": value])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var value: String {
            get {
              return resultMap["value"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "value")
            }
          }
        }

        public var asMessageBodyChoicesLink: AsMessageBodyChoicesLink? {
          get {
            if !AsMessageBodyChoicesLink.possibleTypes.contains(__typename) { return nil }
            return AsMessageBodyChoicesLink(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMessageBodyChoicesLink: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MessageBodyChoicesLink"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("view", type: .scalar(MessageBodyChoicesLinkView.self)),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("value", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(view: MessageBodyChoicesLinkView? = nil, text: String, value: String) {
            self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "view": view, "text": text, "value": value])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var view: MessageBodyChoicesLinkView? {
            get {
              return resultMap["view"] as? MessageBodyChoicesLinkView
            }
            set {
              resultMap.updateValue(newValue, forKey: "view")
            }
          }

          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var value: String {
            get {
              return resultMap["value"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "value")
            }
          }
        }
      }
    }

    public var asMessageBodyMultipleSelect: AsMessageBodyMultipleSelect? {
      get {
        if !AsMessageBodyMultipleSelect.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyMultipleSelect(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyMultipleSelect: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyMultipleSelect"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "type": type, "id": id, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }
    }

    public var asMessageBodyText: AsMessageBodyText? {
      get {
        if !AsMessageBodyText.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyText(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyText: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyText"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("placeholder", type: .scalar(String.self)),
        GraphQLField("keyboard", type: .scalar(KeyboardType.self)),
        GraphQLField("textContentType", type: .scalar(TextContentType.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyText", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var placeholder: String? {
        get {
          return resultMap["placeholder"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "placeholder")
        }
      }

      public var keyboard: KeyboardType? {
        get {
          return resultMap["keyboard"] as? KeyboardType
        }
        set {
          resultMap.updateValue(newValue, forKey: "keyboard")
        }
      }

      public var textContentType: TextContentType? {
        get {
          return resultMap["textContentType"] as? TextContentType
        }
        set {
          resultMap.updateValue(newValue, forKey: "textContentType")
        }
      }
    }

    public var asMessageBodyNumber: AsMessageBodyNumber? {
      get {
        if !AsMessageBodyNumber.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyNumber(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyNumber: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyNumber"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("placeholder", type: .scalar(String.self)),
        GraphQLField("keyboard", type: .scalar(KeyboardType.self)),
        GraphQLField("textContentType", type: .scalar(TextContentType.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String, placeholder: String? = nil, keyboard: KeyboardType? = nil, textContentType: TextContentType? = nil) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyNumber", "type": type, "id": id, "text": text, "placeholder": placeholder, "keyboard": keyboard, "textContentType": textContentType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var placeholder: String? {
        get {
          return resultMap["placeholder"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "placeholder")
        }
      }

      public var keyboard: KeyboardType? {
        get {
          return resultMap["keyboard"] as? KeyboardType
        }
        set {
          resultMap.updateValue(newValue, forKey: "keyboard")
        }
      }

      public var textContentType: TextContentType? {
        get {
          return resultMap["textContentType"] as? TextContentType
        }
        set {
          resultMap.updateValue(newValue, forKey: "textContentType")
        }
      }
    }

    public var asMessageBodyAudio: AsMessageBodyAudio? {
      get {
        if !AsMessageBodyAudio.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyAudio(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyAudio: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyAudio"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyAudio", "type": type, "id": id, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }
    }

    public var asMessageBodyBankIdCollect: AsMessageBodyBankIdCollect? {
      get {
        if !AsMessageBodyBankIdCollect.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyBankIdCollect(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyBankIdCollect: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyBankIdCollect"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "type": type, "id": id, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }
    }

    public var asMessageBodyFile: AsMessageBodyFile? {
      get {
        if !AsMessageBodyFile.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyFile(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyFile: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyFile"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("mimeType", type: .scalar(String.self)),
        GraphQLField("file", type: .nonNull(.object(File.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String, mimeType: String? = nil, file: File) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyFile", "type": type, "id": id, "text": text, "mimeType": mimeType, "file": file.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var mimeType: String? {
        get {
          return resultMap["mimeType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "mimeType")
        }
      }

      public var file: File {
        get {
          return File(unsafeResultMap: resultMap["file"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "file")
        }
      }

      public struct File: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["File"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("signedUrl", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(signedUrl: String) {
          self.init(unsafeResultMap: ["__typename": "File", "signedUrl": signedUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// signedUrl is valid for 30 minutes after upload, don't hang on to this.
        public var signedUrl: String {
          get {
            return resultMap["signedUrl"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "signedUrl")
          }
        }
      }
    }

    public var asMessageBodyParagraph: AsMessageBodyParagraph? {
      get {
        if !AsMessageBodyParagraph.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyParagraph(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyParagraph: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyParagraph"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyParagraph", "type": type, "id": id, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }
    }

    public var asMessageBodyUndefined: AsMessageBodyUndefined? {
      get {
        if !AsMessageBodyUndefined.possibleTypes.contains(__typename) { return nil }
        return AsMessageBodyUndefined(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMessageBodyUndefined: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageBodyUndefined"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: String, id: GraphQLID, text: String) {
        self.init(unsafeResultMap: ["__typename": "MessageBodyUndefined", "type": type, "id": id, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return resultMap["type"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }
    }
  }

  public struct Header: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MessageHeader"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("messageId", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("fromMyself", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("timeStamp", type: .nonNull(.scalar(String.self))),
      GraphQLField("richTextChatCompatible", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("editAllowed", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("shouldRequestPushNotifications", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("pollingInterval", type: .nonNull(.scalar(Int.self))),
      GraphQLField("loadingIndicator", type: .scalar(String.self)),
      GraphQLField("statusMessage", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(messageId: GraphQLID, fromMyself: Bool, timeStamp: String, richTextChatCompatible: Bool, editAllowed: Bool, shouldRequestPushNotifications: Bool, pollingInterval: Int, loadingIndicator: String? = nil, statusMessage: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "MessageHeader", "messageId": messageId, "fromMyself": fromMyself, "timeStamp": timeStamp, "richTextChatCompatible": richTextChatCompatible, "editAllowed": editAllowed, "shouldRequestPushNotifications": shouldRequestPushNotifications, "pollingInterval": pollingInterval, "loadingIndicator": loadingIndicator, "statusMessage": statusMessage])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var messageId: GraphQLID {
      get {
        return resultMap["messageId"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "messageId")
      }
    }

    public var fromMyself: Bool {
      get {
        return resultMap["fromMyself"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "fromMyself")
      }
    }

    public var timeStamp: String {
      get {
        return resultMap["timeStamp"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "timeStamp")
      }
    }

    public var richTextChatCompatible: Bool {
      get {
        return resultMap["richTextChatCompatible"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "richTextChatCompatible")
      }
    }

    public var editAllowed: Bool {
      get {
        return resultMap["editAllowed"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "editAllowed")
      }
    }

    public var shouldRequestPushNotifications: Bool {
      get {
        return resultMap["shouldRequestPushNotifications"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "shouldRequestPushNotifications")
      }
    }

    public var pollingInterval: Int {
      get {
        return resultMap["pollingInterval"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "pollingInterval")
      }
    }

    public var loadingIndicator: String? {
      get {
        return resultMap["loadingIndicator"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "loadingIndicator")
      }
    }

    public var statusMessage: String? {
      get {
        return resultMap["statusMessage"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "statusMessage")
      }
    }
  }
}

public struct CostFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CostFragment on InsuranceCost {
      __typename
      freeUntil
      monthlyDiscount {
        __typename
        amount
        currency
      }
      monthlyGross {
        __typename
        amount
        currency
      }
      monthlyNet {
        __typename
        amount
        currency
      }
    }
    """

  public static let possibleTypes: [String] = ["InsuranceCost"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("freeUntil", type: .scalar(String.self)),
    GraphQLField("monthlyDiscount", type: .nonNull(.object(MonthlyDiscount.selections))),
    GraphQLField("monthlyGross", type: .nonNull(.object(MonthlyGross.selections))),
    GraphQLField("monthlyNet", type: .nonNull(.object(MonthlyNet.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(freeUntil: String? = nil, monthlyDiscount: MonthlyDiscount, monthlyGross: MonthlyGross, monthlyNet: MonthlyNet) {
    self.init(unsafeResultMap: ["__typename": "InsuranceCost", "freeUntil": freeUntil, "monthlyDiscount": monthlyDiscount.resultMap, "monthlyGross": monthlyGross.resultMap, "monthlyNet": monthlyNet.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var freeUntil: String? {
    get {
      return resultMap["freeUntil"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "freeUntil")
    }
  }

  public var monthlyDiscount: MonthlyDiscount {
    get {
      return MonthlyDiscount(unsafeResultMap: resultMap["monthlyDiscount"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "monthlyDiscount")
    }
  }

  public var monthlyGross: MonthlyGross {
    get {
      return MonthlyGross(unsafeResultMap: resultMap["monthlyGross"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "monthlyGross")
    }
  }

  public var monthlyNet: MonthlyNet {
    get {
      return MonthlyNet(unsafeResultMap: resultMap["monthlyNet"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "monthlyNet")
    }
  }

  public struct MonthlyDiscount: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MonetaryAmountV2"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("amount", type: .nonNull(.scalar(String.self))),
      GraphQLField("currency", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(amount: String, currency: String) {
      self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var amount: String {
      get {
        return resultMap["amount"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "amount")
      }
    }

    public var currency: String {
      get {
        return resultMap["currency"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "currency")
      }
    }
  }

  public struct MonthlyGross: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MonetaryAmountV2"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("amount", type: .nonNull(.scalar(String.self))),
      GraphQLField("currency", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(amount: String, currency: String) {
      self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var amount: String {
      get {
        return resultMap["amount"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "amount")
      }
    }

    public var currency: String {
      get {
        return resultMap["currency"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "currency")
      }
    }
  }

  public struct MonthlyNet: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MonetaryAmountV2"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("amount", type: .nonNull(.scalar(String.self))),
      GraphQLField("currency", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(amount: String, currency: String) {
      self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var amount: String {
      get {
        return resultMap["amount"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "amount")
      }
    }

    public var currency: String {
      get {
        return resultMap["currency"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "currency")
      }
    }
  }
}

public struct ExtraBuildingFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment ExtraBuildingFragment on ExtraBuildingCore {
      __typename
      displayName
      area
      hasWaterConnected
    }
    """

  public static let possibleTypes: [String] = ["ExtraBuildingGarage", "ExtraBuildingCarport", "ExtraBuildingShed", "ExtraBuildingStorehouse", "ExtraBuildingFriggebod", "ExtraBuildingAttefall", "ExtraBuildingOuthouse", "ExtraBuildingGuesthouse", "ExtraBuildingGazebo", "ExtraBuildingGreenhouse", "ExtraBuildingSauna", "ExtraBuildingBarn", "ExtraBuildingBoathouse", "ExtraBuildingOther"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
    GraphQLField("area", type: .nonNull(.scalar(Int.self))),
    GraphQLField("hasWaterConnected", type: .nonNull(.scalar(Bool.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeExtraBuildingGarage(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingGarage", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingCarport(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingCarport", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingShed(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingShed", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingStorehouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingStorehouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingFriggebod(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingFriggebod", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingAttefall(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingAttefall", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingOuthouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingOuthouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingGuesthouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingGuesthouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingGazebo(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingGazebo", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingGreenhouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingGreenhouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingSauna(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingSauna", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingBarn(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingBarn", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingBoathouse(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingBoathouse", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public static func makeExtraBuildingOther(displayName: String, area: Int, hasWaterConnected: Bool) -> ExtraBuildingFragment {
    return ExtraBuildingFragment(unsafeResultMap: ["__typename": "ExtraBuildingOther", "displayName": displayName, "area": area, "hasWaterConnected": hasWaterConnected])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var displayName: String {
    get {
      return resultMap["displayName"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "displayName")
    }
  }

  public var area: Int {
    get {
      return resultMap["area"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "area")
    }
  }

  public var hasWaterConnected: Bool {
    get {
      return resultMap["hasWaterConnected"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hasWaterConnected")
    }
  }
}

public struct IconFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment IconFragment on Icon {
      __typename
      variants {
        __typename
        dark {
          __typename
          pdfUrl
        }
        light {
          __typename
          pdfUrl
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["Icon"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(variants: Variant) {
    self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Icons with variants for light and dark mode
  public var variants: Variant {
    get {
      return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "variants")
    }
  }

  public struct Variant: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["IconVariants"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
      GraphQLField("light", type: .nonNull(.object(Light.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(dark: Dark, light: Light) {
      self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// A variant to use for dark user interfaces
    public var dark: Dark {
      get {
        return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "dark")
      }
    }

    /// A variant to use for light user interfaces
    public var light: Light {
      get {
        return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "light")
      }
    }

    public struct Dark: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["IconVariant"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pdfUrl: String) {
        self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// For iOS use
      public var pdfUrl: String {
        get {
          return resultMap["pdfUrl"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "pdfUrl")
        }
      }
    }

    public struct Light: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["IconVariant"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pdfUrl: String) {
        self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// For iOS use
      public var pdfUrl: String {
        get {
          return resultMap["pdfUrl"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "pdfUrl")
        }
      }
    }
  }
}

public struct IncentiveFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment IncentiveFragment on Incentive {
      __typename
      ... on FreeMonths {
        quantity
      }
      ... on MonthlyCostDeduction {
        amount {
          __typename
          ...MonetaryAmountFragment
        }
      }
      ... on PercentageDiscountMonths {
        percentageDiscount
        percentageNumberOfMonths: quantity
      }
    }
    """

  public static let possibleTypes: [String] = ["MonthlyCostDeduction", "FreeMonths", "NoDiscount", "PercentageDiscountMonths"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["FreeMonths": AsFreeMonths.selections, "MonthlyCostDeduction": AsMonthlyCostDeduction.selections, "PercentageDiscountMonths": AsPercentageDiscountMonths.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeNoDiscount() -> IncentiveFragment {
    return IncentiveFragment(unsafeResultMap: ["__typename": "NoDiscount"])
  }

  public static func makeFreeMonths(quantity: Int? = nil) -> IncentiveFragment {
    return IncentiveFragment(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
  }

  public static func makeMonthlyCostDeduction(amount: AsMonthlyCostDeduction.Amount? = nil) -> IncentiveFragment {
    return IncentiveFragment(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: AsMonthlyCostDeduction.Amount) -> ResultMap in value.resultMap }])
  }

  public static func makePercentageDiscountMonths(percentageDiscount: Double, percentageNumberOfMonths: Int) -> IncentiveFragment {
    return IncentiveFragment(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var asFreeMonths: AsFreeMonths? {
    get {
      if !AsFreeMonths.possibleTypes.contains(__typename) { return nil }
      return AsFreeMonths(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsFreeMonths: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FreeMonths"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("quantity", type: .scalar(Int.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(quantity: Int? = nil) {
      self.init(unsafeResultMap: ["__typename": "FreeMonths", "quantity": quantity])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var quantity: Int? {
      get {
        return resultMap["quantity"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "quantity")
      }
    }
  }

  public var asMonthlyCostDeduction: AsMonthlyCostDeduction? {
    get {
      if !AsMonthlyCostDeduction.possibleTypes.contains(__typename) { return nil }
      return AsMonthlyCostDeduction(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsMonthlyCostDeduction: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MonthlyCostDeduction"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("amount", type: .object(Amount.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(amount: Amount? = nil) {
      self.init(unsafeResultMap: ["__typename": "MonthlyCostDeduction", "amount": amount.flatMap { (value: Amount) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var amount: Amount? {
      get {
        return (resultMap["amount"] as? ResultMap).flatMap { Amount(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "amount")
      }
    }

    public struct Amount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MonetaryAmountV2"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.scalar(String.self))),
        GraphQLField("currency", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String, currency: String) {
        self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var amount: String {
        get {
          return resultMap["amount"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "amount")
        }
      }

      public var currency: String {
        get {
          return resultMap["currency"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "currency")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var monetaryAmountFragment: MonetaryAmountFragment {
          get {
            return MonetaryAmountFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public var asPercentageDiscountMonths: AsPercentageDiscountMonths? {
    get {
      if !AsPercentageDiscountMonths.possibleTypes.contains(__typename) { return nil }
      return AsPercentageDiscountMonths(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsPercentageDiscountMonths: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["PercentageDiscountMonths"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("percentageDiscount", type: .nonNull(.scalar(Double.self))),
      GraphQLField("quantity", alias: "percentageNumberOfMonths", type: .nonNull(.scalar(Int.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(percentageDiscount: Double, percentageNumberOfMonths: Int) {
      self.init(unsafeResultMap: ["__typename": "PercentageDiscountMonths", "percentageDiscount": percentageDiscount, "percentageNumberOfMonths": percentageNumberOfMonths])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var percentageDiscount: Double {
      get {
        return resultMap["percentageDiscount"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "percentageDiscount")
      }
    }

    public var percentageNumberOfMonths: Int {
      get {
        return resultMap["percentageNumberOfMonths"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "percentageNumberOfMonths")
      }
    }
  }
}

public struct InsurableLimitFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment InsurableLimitFragment on InsurableLimit {
      __typename
      label
      limit
      description
    }
    """

  public static let possibleTypes: [String] = ["InsurableLimit"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("label", type: .nonNull(.scalar(String.self))),
    GraphQLField("limit", type: .nonNull(.scalar(String.self))),
    GraphQLField("description", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(label: String, limit: String, description: String) {
    self.init(unsafeResultMap: ["__typename": "InsurableLimit", "label": label, "limit": limit, "description": description])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var label: String {
    get {
      return resultMap["label"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "label")
    }
  }

  public var limit: String {
    get {
      return resultMap["limit"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "limit")
    }
  }

  public var description: String {
    get {
      return resultMap["description"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "description")
    }
  }
}

public struct MonetaryAmountFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MonetaryAmountFragment on MonetaryAmountV2 {
      __typename
      amount
      currency
    }
    """

  public static let possibleTypes: [String] = ["MonetaryAmountV2"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("amount", type: .nonNull(.scalar(String.self))),
    GraphQLField("currency", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(amount: String, currency: String) {
    self.init(unsafeResultMap: ["__typename": "MonetaryAmountV2", "amount": amount, "currency": currency])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var amount: String {
    get {
      return resultMap["amount"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var currency: String {
    get {
      return resultMap["currency"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "currency")
    }
  }
}

public struct PerilCategoryFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment PerilCategoryFragment on PerilCategory {
      __typename
      title
      description
      perils {
        __typename
        id
        title
        description
      }
    }
    """

  public static let possibleTypes: [String] = ["PerilCategory"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("title", type: .scalar(String.self)),
    GraphQLField("description", type: .scalar(String.self)),
    GraphQLField("perils", type: .list(.object(Peril.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(title: String? = nil, description: String? = nil, perils: [Peril?]? = nil) {
    self.init(unsafeResultMap: ["__typename": "PerilCategory", "title": title, "description": description, "perils": perils.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var title: String? {
    get {
      return resultMap["title"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: String? {
    get {
      return resultMap["description"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "description")
    }
  }

  public var perils: [Peril?]? {
    get {
      return (resultMap["perils"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Peril?] in value.map { (value: ResultMap?) -> Peril? in value.flatMap { (value: ResultMap) -> Peril in Peril(unsafeResultMap: value) } } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Peril?]) -> [ResultMap?] in value.map { (value: Peril?) -> ResultMap? in value.flatMap { (value: Peril) -> ResultMap in value.resultMap } } }, forKey: "perils")
    }
  }

  public struct Peril: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Peril"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .scalar(GraphQLID.self)),
      GraphQLField("title", type: .scalar(String.self)),
      GraphQLField("description", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: GraphQLID? = nil, title: String? = nil, description: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Peril", "id": id, "title": title, "description": description])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: GraphQLID? {
      get {
        return resultMap["id"] as? GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    public var title: String? {
      get {
        return resultMap["title"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "title")
      }
    }

    public var description: String? {
      get {
        return resultMap["description"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "description")
      }
    }
  }
}

public struct PerilFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment PerilFragment on PerilV2 {
      __typename
      title
      description
      icon {
        __typename
        ...IconFragment
      }
    }
    """

  public static let possibleTypes: [String] = ["PerilV2"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("title", type: .nonNull(.scalar(String.self))),
    GraphQLField("description", type: .nonNull(.scalar(String.self))),
    GraphQLField("icon", type: .nonNull(.object(Icon.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(title: String, description: String, icon: Icon) {
    self.init(unsafeResultMap: ["__typename": "PerilV2", "title": title, "description": description, "icon": icon.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var title: String {
    get {
      return resultMap["title"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "title")
    }
  }

  public var description: String {
    get {
      return resultMap["description"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "description")
    }
  }

  public var icon: Icon {
    get {
      return Icon(unsafeResultMap: resultMap["icon"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "icon")
    }
  }

  public struct Icon: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Icon"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("variants", type: .nonNull(.object(Variant.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(variants: Variant) {
      self.init(unsafeResultMap: ["__typename": "Icon", "variants": variants.resultMap])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Icons with variants for light and dark mode
    public var variants: Variant {
      get {
        return Variant(unsafeResultMap: resultMap["variants"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "variants")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var iconFragment: IconFragment {
        get {
          return IconFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public struct Variant: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["IconVariants"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("dark", type: .nonNull(.object(Dark.selections))),
        GraphQLField("light", type: .nonNull(.object(Light.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(dark: Dark, light: Light) {
        self.init(unsafeResultMap: ["__typename": "IconVariants", "dark": dark.resultMap, "light": light.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A variant to use for dark user interfaces
      public var dark: Dark {
        get {
          return Dark(unsafeResultMap: resultMap["dark"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "dark")
        }
      }

      /// A variant to use for light user interfaces
      public var light: Light {
        get {
          return Light(unsafeResultMap: resultMap["light"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "light")
        }
      }

      public struct Dark: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["IconVariant"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(pdfUrl: String) {
          self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// For iOS use
        public var pdfUrl: String {
          get {
            return resultMap["pdfUrl"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "pdfUrl")
          }
        }
      }

      public struct Light: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["IconVariant"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("pdfUrl", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(pdfUrl: String) {
          self.init(unsafeResultMap: ["__typename": "IconVariant", "pdfUrl": pdfUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// For iOS use
        public var pdfUrl: String {
          get {
            return resultMap["pdfUrl"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "pdfUrl")
          }
        }
      }
    }
  }
}
