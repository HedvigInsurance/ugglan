// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
@MainActor 
public enum hCoreUIAssets {
  public static let flagSE = ImageAsset(name: "FlagSE")
  public static let flagUK = ImageAsset(name: "FlagUK")
  public static let attentionSmall = ImageAsset(name: "AttentionSmall")
  public static let campaignSmall = ImageAsset(name: "CampaignSmall")
  public static let checkmarkFilledSmall = ImageAsset(name: "CheckmarkFilledSmall")
  public static let checkmarkSmall = ImageAsset(name: "CheckmarkSmall")
  public static let chevronDownSmall20 = ImageAsset(name: "ChevronDownSmall20")
  public static let circleFilledSmall = ImageAsset(name: "CircleFilledSmall")
  public static let circleOutlinedSmall = ImageAsset(name: "CircleOutlinedSmall")
  public static let closeSmall = ImageAsset(name: "CloseSmall")
  public static let infoFilledSmall = ImageAsset(name: "InfoFilledSmall")
  public static let plusSmall = ImageAsset(name: "PlusSmall")
  public static let starSmall = ImageAsset(name: "StarSmall")
  public static let warningTriangleFilledSmall = ImageAsset(name: "WarningTriangleFilledSmall")
  public static let envelope = ImageAsset(name: "envelope")
  public static let firstVet = ImageAsset(name: "firstVet")
  public static let arrowDown = ImageAsset(name: "ArrowDown")
  public static let arrowLeft = ImageAsset(name: "ArrowLeft")
  public static let arrowNorthEast = ImageAsset(name: "ArrowNorthEast")
  public static let arrowRight = ImageAsset(name: "ArrowRight")
  public static let arrowUp = ImageAsset(name: "ArrowUp")
  public static let attach = ImageAsset(name: "Attach")
  public static let attentionFilled = ImageAsset(name: "AttentionFilled")
  public static let attentionOutlined = ImageAsset(name: "AttentionOutlined")
  public static let bandage = ImageAsset(name: "Bandage")
  public static let bookmark = ImageAsset(name: "Bookmark")
  public static let camera = ImageAsset(name: "Camera")
  public static let campaign = ImageAsset(name: "Campaign")
  public static let campaignOutlined = ImageAsset(name: "CampaignOutlined")
  public static let certified = ImageAsset(name: "Certified")
  public static let checkmark = ImageAsset(name: "Checkmark")
  public static let checkmarkFilled = ImageAsset(name: "CheckmarkFilled")
  public static let checkmarkOutlined = ImageAsset(name: "CheckmarkOutlined")
  public static let chevronDown = ImageAsset(name: "ChevronDown")
  public static let chevronDownSmall = ImageAsset(name: "ChevronDownSmall")
  public static let chevronLeft = ImageAsset(name: "ChevronLeft")
  public static let chevronLeftSmall = ImageAsset(name: "ChevronLeftSmall")
  public static let chevronRight = ImageAsset(name: "ChevronRight")
  public static let chevronRightSmall = ImageAsset(name: "ChevronRightSmall")
  public static let chevronUp = ImageAsset(name: "ChevronUp")
  public static let chevronUpSmall = ImageAsset(name: "ChevronUpSmall")
  public static let circleFilled = ImageAsset(name: "CircleFilled")
  public static let circleOutlined = ImageAsset(name: "CircleOutlined")
  public static let clock = ImageAsset(name: "Clock")
  public static let close = ImageAsset(name: "Close")
  public static let copy = ImageAsset(name: "Copy")
  public static let document = ImageAsset(name: "Document")
  public static let documentPlus = ImageAsset(name: "DocumentPlus")
  public static let dots = ImageAsset(name: "Dots")
  public static let download = ImageAsset(name: "Download")
  public static let eq = ImageAsset(name: "EQ")
  public static let forever = ImageAsset(name: "Forever")
  public static let helipadFilled = ImageAsset(name: "HelipadFilled")
  public static let helipadOutlined = ImageAsset(name: "HelipadOutlined")
  public static let houseArrow = ImageAsset(name: "HouseArrow")
  public static let id = ImageAsset(name: "ID")
  public static let image = ImageAsset(name: "Image")
  public static let infoFilled = ImageAsset(name: "InfoFilled")
  public static let infoOutlined = ImageAsset(name: "InfoOutlined")
  public static let link = ImageAsset(name: "Link")
  public static let lock = ImageAsset(name: "Lock")
  public static let mic = ImageAsset(name: "Mic")
  public static let minus = ImageAsset(name: "Minus")
  public static let notification = ImageAsset(name: "Notification")
  public static let pause = ImageAsset(name: "Pause")
  public static let paymentFilled = ImageAsset(name: "PaymentFilled")
  public static let paymentFilledNotification = ImageAsset(name: "PaymentFilledNotification")
  public static let paymentOutlineNotification = ImageAsset(name: "PaymentOutlineNotification")
  public static let paymentOutlined = ImageAsset(name: "PaymentOutlined")
  public static let payments = ImageAsset(name: "Payments")
  public static let penEdit = ImageAsset(name: "Pen-Edit")
  public static let pillowHome = ImageAsset(name: "PillowHome")
  public static let pin = ImageAsset(name: "Pin")
  public static let play = ImageAsset(name: "Play")
  public static let plus = ImageAsset(name: "Plus")
  public static let profileFilled = ImageAsset(name: "ProfileFilled")
  public static let profileOutlined = ImageAsset(name: "ProfileOutlined")
  public static let refresh = ImageAsset(name: "Refresh")
  public static let reload = ImageAsset(name: "Reload")
  public static let search = ImageAsset(name: "Search")
  public static let settings = ImageAsset(name: "Settings")
  public static let settingsNotification = ImageAsset(name: "SettingsNotification")
  public static let shieldFilled = ImageAsset(name: "ShieldFilled")
  public static let shieldFilledNotification = ImageAsset(name: "ShieldFilledNotification")
  public static let shieldOutlined = ImageAsset(name: "ShieldOutlined")
  public static let shieldOutlinedNotification = ImageAsset(name: "ShieldOutlinedNotification")
  public static let star = ImageAsset(name: "Star")
  public static let stop = ImageAsset(name: "Stop")
  public static let swap = ImageAsset(name: "Swap")
  public static let trash = ImageAsset(name: "Trash")
  public static let travel = ImageAsset(name: "Travel")
  public static let warningTriangleFilled = ImageAsset(name: "WarningTriangleFilled")
  public static let warningTriangleOutlined = ImageAsset(name: "WarningTriangleOutlined")
  public static let hedvig = ImageAsset(name: "Hedvig")
  public static let helipadBig = ImageAsset(name: "HelipadBig")
  public static let edit = ImageAsset(name: "Edit")
  public static let euroBonusWithValueRowIcon = ImageAsset(name: "EuroBonusWithValueRowIcon")
  public static let file = ImageAsset(name: "File")
  public static let pdf = ImageAsset(name: "PDF")
  public static let sendChat = ImageAsset(name: "SendChat")
  public static let trustly = ImageAsset(name: "Trustly")
  public static let kivra = ImageAsset(name: "kivra")
  public static let swish = ImageAsset(name: "swish")
  public static let bigPillowAccident = ImageAsset(name: "big.pillow.accident")
  public static let bigPillowBlack = ImageAsset(name: "big.pillow.black")
  public static let bigPillowCar = ImageAsset(name: "big.pillow.car")
  public static let bigPillowCat = ImageAsset(name: "big.pillow.cat")
  public static let bigPillowDog = ImageAsset(name: "big.pillow.dog")
  public static let bigPillowHome = ImageAsset(name: "big.pillow.home")
  public static let bigPillowHomeowner = ImageAsset(name: "big.pillow.homeowner")
  public static let bigPillowPet = ImageAsset(name: "big.pillow.pet")
  public static let bigPillowRental = ImageAsset(name: "big.pillow.rental")
  public static let bigPillowSafety = ImageAsset(name: "big.pillow.safety")
  public static let bigPillowStudent = ImageAsset(name: "big.pillow.student")
  public static let bigPillowVacationHome = ImageAsset(name: "big.pillow.vacationHome")
  public static let bigPillowVilla = ImageAsset(name: "big.pillow.villa")
  public static let eurobonus = ImageAsset(name: "eurobonus")
  public static let hundarBadarPet = ImageAsset(name: "hundarBadarPet")
  public static let campaignQuickNav = ImageAsset(name: "CampaignQuickNav")
  public static let chatQuickNav = ImageAsset(name: "ChatQuickNav")
  public static let firstVetQuickNav = ImageAsset(name: "FirstVetQuickNav")
  public static let attention = ImageAsset(name: "Attention")
  public static let bankID = ImageAsset(name: "BankID")
  public static let check = ImageAsset(name: "Check")
  public static let inbox = ImageAsset(name: "Inbox")
  public static let inboxNotification = ImageAsset(name: "InboxNotification")
  public static let info = ImageAsset(name: "Info")
  public static let warning = ImageAsset(name: "warning")
  public static let submitClaimBg = ImageAsset(name: "SubmitClaimBg")
  public static let contractTab = ImageAsset(name: "ContractTab")
  public static let contractTabActive = ImageAsset(name: "ContractTabActive")
  public static let foreverTab = ImageAsset(name: "ForeverTab")
  public static let foreverTabActive = ImageAsset(name: "ForeverTabActive")
  public static let homeTab = ImageAsset(name: "HomeTab")
  public static let homeTabActive = ImageAsset(name: "HomeTabActive")
  public static let keyGearTabIcon = ImageAsset(name: "KeyGearTabIcon")
  public static let paymentsTab = ImageAsset(name: "PaymentsTab")
  public static let paymentsTabActive = ImageAsset(name: "PaymentsTabActive")
  public static let profileTab = ImageAsset(name: "ProfileTab")
  public static let profileTabActive = ImageAsset(name: "ProfileTabActive")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
