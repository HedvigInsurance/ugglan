// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  public typealias AssetColorTypeAlias = NSColor
  public typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  public typealias AssetColorTypeAlias = UIColor
  public typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum hCoreUIAssets {
  public static let attachFile = ImageAsset(name: "AttachFile")
  public static let camera = ImageAsset(name: "Camera")
  public static let files = ImageAsset(name: "Files")
  public static let gif = ImageAsset(name: "GIF")
  public static let pause = ImageAsset(name: "Pause")
  public static let photoLibrary = ImageAsset(name: "PhotoLibrary")
  public static let play = ImageAsset(name: "Play")
  public static let restart = ImageAsset(name: "Restart")
  public static let sendChat = ImageAsset(name: "SendChat")
  public static let claimsHeader = ImageAsset(name: "ClaimsHeader")
  public static let `continue` = ImageAsset(name: "Continue")
  public static let apartment = ImageAsset(name: "Apartment")
  public static let coverage = ImageAsset(name: "Coverage")
  public static let documents = ImageAsset(name: "Documents")
  public static let house = ImageAsset(name: "House")
  public static let insuranceInfo = ImageAsset(name: "InsuranceInfo")
  public static let circularCheckmark = ImageAsset(name: "CircularCheckmark")
  public static let redClock = ImageAsset(name: "RedClock")
  public static let redCross = ImageAsset(name: "RedCross")
  public static let flagGB = ImageAsset(name: "Flag-GB")
  public static let flagNO = ImageAsset(name: "Flag-NO")
  public static let flagSE = ImageAsset(name: "Flag-SE")
  public static let addButton = ImageAsset(name: "AddButton")
  public static let backButton = ImageAsset(name: "BackButton")
  public static let backButtonWhite = ImageAsset(name: "BackButtonWhite")
  public static let bankIdLogo = ImageAsset(name: "BankIdLogo")
  public static let chat = ImageAsset(name: "Chat")
  public static let chevronRight = ImageAsset(name: "ChevronRight")
  public static let chevronRightWhite = ImageAsset(name: "ChevronRightWhite")
  public static let close = ImageAsset(name: "Close")
  public static let editIcon = ImageAsset(name: "EditIcon")
  public static let menuIcon = ImageAsset(name: "MenuIcon")
  public static let pinkCircularCross = ImageAsset(name: "PinkCircularCross")
  public static let pinkCircularExclamationPoint = ImageAsset(name: "PinkCircularExclamationPoint")
  public static let symbol = ImageAsset(name: "Symbol")
  public static let keyGearAddPhoto = ImageAsset(name: "KeyGearAddPhoto")
  public static let keyGearOverviewHeader = ImageAsset(name: "KeyGearOverviewHeader")
  public static let keyGearPhonePlaceholder = ImageAsset(name: "KeyGearPhonePlaceholder")
  public static let keyGearTabletPlaceholder = ImageAsset(name: "KeyGearTabletPlaceholder")
  public static let keyGearWatchPlacholder = ImageAsset(name: "KeyGearWatchPlacholder")
  public static let receipt = ImageAsset(name: "Receipt")
  public static let launchScreenBackground = ColorAsset(name: "LaunchScreenBackground")
  public static let activatePushNotificationsIllustration = ImageAsset(name: "ActivatePushNotificationsIllustration")
  public static let paymentSetupIllustration = ImageAsset(name: "PaymentSetupIllustration")
  public static let charityPlain = ImageAsset(name: "CharityPlain")
  public static let cogwheel = ImageAsset(name: "Cogwheel")
  public static let infoPurple = ImageAsset(name: "InfoPurple")
  public static let myInfoRowIcon = ImageAsset(name: "MyInfoRowIcon")
  public static let paymentRowIcon = ImageAsset(name: "PaymentRowIcon")
  public static let clock = ImageAsset(name: "Clock")
  public static let copy = ImageAsset(name: "Copy")
  public static let ghost = ImageAsset(name: "Ghost")
  public static let inviteSuccess = ImageAsset(name: "InviteSuccess")
  public static let claimsTabIcon = ImageAsset(name: "ClaimsTabIcon")
  public static let dashboardTab = ImageAsset(name: "DashboardTab")
  public static let keyGearTabIcon = ImageAsset(name: "KeyGearTabIcon")
  public static let profileTab = ImageAsset(name: "ProfileTab")
  public static let referralsTab = ImageAsset(name: "ReferralsTab")
  public static let wordmark = ImageAsset(name: "Wordmark")
  public static let wordmarkWhite = ImageAsset(name: "WordmarkWhite")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ColorAsset {
  public fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  public var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

public extension AssetColorTypeAlias {
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

public struct DataAsset {
  public fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  public var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
public extension NSDataAsset {
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

public struct ImageAsset {
  public fileprivate(set) var name: String

  public var image: AssetImageTypeAlias {
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

public extension AssetImageTypeAlias {
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
