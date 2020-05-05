// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let attachFile = ImageAsset(name: "AttachFile")
  internal static let camera = ImageAsset(name: "Camera")
  internal static let files = ImageAsset(name: "Files")
  internal static let gif = ImageAsset(name: "GIF")
  internal static let pause = ImageAsset(name: "Pause")
  internal static let photoLibrary = ImageAsset(name: "PhotoLibrary")
  internal static let play = ImageAsset(name: "Play")
  internal static let restart = ImageAsset(name: "Restart")
  internal static let sendChat = ImageAsset(name: "SendChat")
  internal static let claimsHeader = ImageAsset(name: "ClaimsHeader")
  internal static let `continue` = ImageAsset(name: "Continue")
  internal static let apartment = ImageAsset(name: "Apartment")
  internal static let coverage = ImageAsset(name: "Coverage")
  internal static let documents = ImageAsset(name: "Documents")
  internal static let house = ImageAsset(name: "House")
  internal static let insuranceInfo = ImageAsset(name: "InsuranceInfo")
  internal static let circularCheckmark = ImageAsset(name: "CircularCheckmark")
  internal static let redClock = ImageAsset(name: "RedClock")
  internal static let redCross = ImageAsset(name: "RedCross")
  internal static let flagGB = ImageAsset(name: "Flag-GB")
  internal static let flagNO = ImageAsset(name: "Flag-NO")
  internal static let flagSE = ImageAsset(name: "Flag-SE")
  internal static let addButton = ImageAsset(name: "AddButton")
  internal static let backButton = ImageAsset(name: "BackButton")
  internal static let backButtonWhite = ImageAsset(name: "BackButtonWhite")
  internal static let bankIdLogo = ImageAsset(name: "BankIdLogo")
  internal static let chat = ImageAsset(name: "Chat")
  internal static let chevronRight = ImageAsset(name: "ChevronRight")
  internal static let chevronRightWhite = ImageAsset(name: "ChevronRightWhite")
  internal static let close = ImageAsset(name: "Close")
  internal static let editIcon = ImageAsset(name: "EditIcon")
  internal static let menuIcon = ImageAsset(name: "MenuIcon")
  internal static let pinkCircularCross = ImageAsset(name: "PinkCircularCross")
  internal static let pinkCircularExclamationPoint = ImageAsset(name: "PinkCircularExclamationPoint")
  internal static let symbol = ImageAsset(name: "Symbol")
  internal static let keyGearAddPhoto = ImageAsset(name: "KeyGearAddPhoto")
  internal static let keyGearOverviewHeader = ImageAsset(name: "KeyGearOverviewHeader")
  internal static let keyGearPhonePlaceholder = ImageAsset(name: "KeyGearPhonePlaceholder")
  internal static let keyGearTabletPlaceholder = ImageAsset(name: "KeyGearTabletPlaceholder")
  internal static let keyGearWatchPlacholder = ImageAsset(name: "KeyGearWatchPlacholder")
  internal static let receipt = ImageAsset(name: "Receipt")
  internal static let launchScreenBackground = ColorAsset(name: "LaunchScreenBackground")
  internal static let activatePushNotificationsIllustration = ImageAsset(name: "ActivatePushNotificationsIllustration")
  internal static let paymentSetupIllustration = ImageAsset(name: "PaymentSetupIllustration")
  internal static let charityPlain = ImageAsset(name: "CharityPlain")
  internal static let cogwheel = ImageAsset(name: "Cogwheel")
  internal static let infoPurple = ImageAsset(name: "InfoPurple")
  internal static let myInfoRowIcon = ImageAsset(name: "MyInfoRowIcon")
  internal static let paymentRowIcon = ImageAsset(name: "PaymentRowIcon")
  internal static let clock = ImageAsset(name: "Clock")
  internal static let copy = ImageAsset(name: "Copy")
  internal static let ghost = ImageAsset(name: "Ghost")
  internal static let inviteSuccess = ImageAsset(name: "InviteSuccess")
  internal static let claimsTabIcon = ImageAsset(name: "ClaimsTabIcon")
  internal static let dashboardTab = ImageAsset(name: "DashboardTab")
  internal static let keyGearTabIcon = ImageAsset(name: "KeyGearTabIcon")
  internal static let profileTab = ImageAsset(name: "ProfileTab")
  internal static let referralsTab = ImageAsset(name: "ReferralsTab")
  internal static let wordmark = ImageAsset(name: "Wordmark")
  internal static let wordmarkWhite = ImageAsset(name: "WordmarkWhite")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
