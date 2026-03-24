# hCore

Foundational module providing dependency injection, shared models, localization, networking utilities, feature flags, and UIKit/SwiftUI extensions used across all feature modules in the Hedvig iOS app.

## Architecture
- **Dependency Injection** -- A lightweight, custom DI container (`Dependencies`) with `@Inject` property wrappers; no third-party DI framework
- **Shared Domain Models** -- Insurance-related value types (MonetaryAmount, Premium, TypeOfContract, etc.) with GraphQL fragment initializers
- **Feature Flags** -- Abstraction over Unleash for runtime feature toggling, exposed as `@Published` properties on an `ObservableObject`
- **Localization** -- Generated `L10n` enum (via SwiftGen) and locale management for the Swedish market (sv_SE, en_SE)
- **Extensions** -- Utility extensions on Foundation, UIKit, and SwiftUI types used broadly by every other module
- **Networking** -- Thin `NetworkClient` wrapper around URLSession with JSON decoding and multipart form support

## Key Files

### Dependency Injection
- `Dependencies/Dependencies.swift` -- `Dependencies` container, `Module` registration, `@Inject` and `@InjectObservableObject` property wrappers

### Feature Flags
- `FeatureFlags/FeatureFlagsProtocol.swift` -- `FeatureFlagsClient` protocol, `FeatureData` struct, `FeatureFlags` ObservableObject singleton
- `FeatureFlags/FeatureFlagUnleash.swift` -- Production Unleash-backed implementation of `FeatureFlagsClient`
- `FeatureFlags/FeatureFlagsDemo.swift` -- Demo/testing implementation that returns all flags disabled with `isDemoMode = true`

### Networking
- `Networking/NetworkClient.swift` -- `NetworkClient` with generic `handleResponse`/`handleResponseForced`, `NetworkError` enum, `MultipartFormDataRequest`

### Models
- `Models/MonetaryAmount.swift` -- Currency-aware amount with locale-specific formatting, arithmetic operators, and GraphQL fragment init
- `Models/Premium.swift` -- Gross/net monetary pair with arithmetic operators and array `.sum()`
- `Models/TypeOfContract.swift` -- Enum of all Swedish insurance contract types with fuzzy resolution fallback
- `Models/ProductVariant.swift` -- Insurance product details (perils, limits, documents) from GraphQL
- `Models/AddonVariant.swift` -- Add-on product details from GraphQL
- `Models/File.swift` -- File model with `FileSource` enum (data, URL, PHPickerResult); includes NSItemProvider helpers
- `Models/MimeType.swift` -- Comprehensive MIME type enum with `isImage`/`isVideo` helpers and bidirectional mime string lookup
- `Models/hPDFDocument.swift` -- PDF document model with `TypeOfDocument` enum
- `Models/InsurableLimits.swift` -- Label/limit/description triplet for insurance coverage limits
- `Models/Deflect.swift` -- `Partner`, `LinkOnlyPartner`, `DeflectQuestion` models for claim deflection flows
- `Models/EditType.swift` -- Enum of insurance-editing operations (change address, co-insured, tier, cancellation, etc.)
- `Models/ItemCost.swift` -- `ItemCost` and `ItemDiscount` for line-item pricing from GraphQL
- `Models/IntentCost.swift` -- `IntentCost` and `QuoteCost` for quote-level pricing
- `Models/UploadFile.swift` -- Simple data/name/mimeType struct for file uploads
- `Models/ServerBasedDate.swift` -- Typealias `ServerBasedDate = String` with display formatting extensions
- `Models/MimeType.swift` -- Shared MimeType enum (also listed under Models)

### Localization
- `Localization.swift` -- `Localization.Locale` enum (sv_SE, en_SE) with `currentLocale` subject, web paths, accept-language headers
- `L10nDerivation.swift` -- `L10nDerivation` struct and `TranslationArgumentable` protocol for re-rendering localized strings after language changes
- `Derived/Strings.swift` -- Auto-generated `L10n` enum from SwiftGen; do not edit manually

### Application State
- `ApplicationState.swift` -- `ApplicationState` with persisted `Screen` enum (loggedIn, notLoggedIn, onboarding, etc.) and locale preferences
- `ApplicationContext.swift` -- Actor-isolated `isLoggedIn` state with Combine publisher

### Deep Linking
- `DeepLink.swift` -- `DeepLink` enum of all supported deep link paths, with URL parsing and display text; `DeeplinkProperty` for query parameters

### Date Formatting
- `DateFormat/Date+LocalDateString.swift` -- `DateService` class with locale-aware formatters; extensions on Date for display formats (dd MMM yyyy, timestamps, etc.)
- `DateFormat/Date+Calendar.swift` -- `isFirstDayOfMonth`/`isLastDayOfMonth` helpers on Date
- `DateFormat/String+toDate.swift` -- String-to-Date parsing via `localDateToDate`, `localDateToIso8601Date`
- `DateFormat/String+BirthDate.swift` -- Swedish SSN/birth date conversion helpers (`calculate12DigitSSN`, `calculate10DigitBirthDate`)

### Input Masking
- `Masking.swift` -- `MaskType` enum and `Masking` struct for validating and formatting Swedish personal numbers, postal codes, emails, phone numbers, etc.; also a SwiftUI `ViewModifier`

### UIKit Extensions
- `UIApplication+GetTopViewController.swift` -- Methods to traverse the view controller hierarchy (`getTopViewController`, `getTopVisibleVc`, `getRootViewController`)
- `UIApplication+safearea.swift` -- `safeArea` convenience on UIApplication
- `UIApplication+dismissKeyboard.swift` -- Static `dismissKeyboard()` helper (note: calling convention is `UIApplication.dismissKeyboard()`)
- `UIDevice+modelName.swift` -- Hardware identifier to human-readable device name mapping
- `UIColor+DynamicPolyfill.swift` -- Convenience inits for light/dark dynamic colors
- `UIColor+UIImage.swift` -- `asImage()` to create a 1px UIImage from a UIColor
- `UIBarButtonItem+UIView.swift` -- Access underlying UIView from a UIBarButtonItem via KVC
- `UIView+LayoutSuperviews.swift` -- `layoutSuperviewsIfNeeded()` recursive layout helper

### SwiftUI Extensions & Views
- `SafariView+SwiftUI.swift` -- `SafariView` UIViewControllerRepresentable wrapping SFSafariViewController
- `PasteView.swift` -- `PasteView` UIViewRepresentable that enables paste menu on long press
- `ScrollView+Inspect.swift` -- `findScrollView` modifier, `ForceScrollViewIndicatorInset`, `ForceScrollViewTopInset`, `ContentOffsetModifier`
- `View+OnUpdate.swift` -- `onUpdate(of:perform:)` convenience wrapper around `onChange`

### WebView Helpers
- `Viewable/WKWebView+OpenBankId.swift` -- `addOpenBankIDBehaviour` on WKWebViewConfiguration for BankID URL scheme handling
- `Viewable/WKWebView+WKUIDelegate.swift` -- `WebViewDelegate` with Combine publishers for navigation actions, loading state, and errors

### Miscellaneous Utilities
- `Helpers/UrlOpener.swift` -- `URLOpener` protocol and `DefaultURLOpener` with DI convenience (`Dependencies.urlOpener`)
- `Helpers/GraphQLErrors+description.swift` -- Localized error descriptions for `GraphQLError`
- `Perils.swift` -- `Perils` struct for insurance coverage perils with GraphQL fragment inits
- `Viewable/FileUploadManager.swift` -- Temp directory management for uploaded file data
- `Viewable/PillowType.swift` -- `PillowType` enum for insurance icon/image selection
- `HelpCenter+chatType.swift` -- `ChatType` enum (conversation, inbox, new conversation, claim conversation)
- `Animations/ImpactGenerator.swift` -- `ImpactGenerator` with `soft()` and `light()` haptic feedback
- `AskForRating.swift` -- `AskForRating` for session-based StoreKit review prompting
- `Unique.swift` -- `uniqued()` and `uniqued(on:)` extensions on Sequence (ported from swift-algorithms)
- `Transient.swift` -- `@Transient` and `@OptionalTransient` property wrappers that skip values during Codable encoding
- `Task.swift` -- `eraseToAnyCancellable()` on Task, `Task.sleep(seconds:)` with Float parameter
- `AsyncDelay.swift` -- Free function `delay(_ timeInterval:)` for async sleep
- `TakeLeft-Right.swift` -- `takeLeft`/`takeRight` combinator functions
- `GaussianDistGenerator.swift` -- `generateGaussianHeights` for random distribution (used in UI animations)
- `LiquidGlass.swift` -- Global `isLiquidGlassEnabled` flag
- `Markdown+typealias.swift` -- `Markdown` typealias for String
- `NotificationCenter+NotificationName.swift` -- App-wide notification names (openChat, openDeepLink, claimCreated, tierChanged, etc.)

### String Extensions
- `String+isDeepLink.swift` -- `isDeepLink` computed property
- `String+isPhoneNumber.swift` -- `isValidPhone` computed property
- `String+join.swift` -- `displayName` on `[String]` joining with bullet separator
- `Codable+String.swift` -- `asString` on any Encodable for JSON string output

### URL Extensions
- `URL+AppendQueryItem.swift` -- `appending(_:value:)` for adding query parameters
- `URL+Helpers.swift` -- Optional-string URL initializer
- `URL+MimeType.swift` -- `mimeType` computed property based on path extension

### Bundle Extensions
- `Bundle+appVersion.swift` -- `appVersion` from Info.plist
- `Bundle+URLScheme.swift` -- `urlScheme` and `urlSchemes` from CFBundleURLTypes

## Public API Surface

### Protocols
- `FeatureFlagsClient` -- Defines feature flag setup, context updating, and Combine publisher contract
- `URLOpener` -- Abstraction for opening URLs (allows test substitution)
- `TranslationArgumentable` -- Enables types to be used as L10n format arguments

### Property Wrappers
- `@Inject<Value>` -- Resolves a dependency from the DI container at access time
- `@InjectObservableObject<T>` -- Resolves an ObservableObject and wraps it in @StateObject for SwiftUI
- `@Transient<Value>` -- Codable wrapper that only encodes the default value (transient field)
- `@OptionalTransient<Value>` -- Like @Transient but the wrapped value is optional

### Key Types
- `Dependencies` -- Singleton DI container; register with `add(module:)`, resolve with `resolve()`
- `Module` -- DI registration unit wrapping a factory closure
- `FeatureFlags` -- ObservableObject singleton exposing `@Published` booleans for each feature flag
- `ApplicationState` -- Persisted app screen state and locale preferences
- `ApplicationContext` -- Actor for login state with Combine publisher
- `DeepLink` -- Enum of all deep link destinations with URL parsing
- `NetworkClient` -- URLSession wrapper with typed JSON decoding
- `NetworkError` -- Error enum (networkError, badRequest, parsingError) with LocalizedError
- `MonetaryAmount` -- Currency-aware amount with formatting and arithmetic
- `Premium` -- Gross/net pair of MonetaryAmount
- `DateService` -- Locale-aware date formatters registered via DI
- `Masking` -- Input validation and formatting for Swedish data formats
- `MaskType` -- Enum of input mask types (personalNumber, postalCode, email, etc.)
- `L10n` -- Auto-generated localization strings enum
- `Localization.Locale` -- Supported locale enum with current locale subject
- `ChatType` -- Enum distinguishing chat entry points

### Key Typealiases
- `Markdown = String`
- `ServerBasedDate = String`

## Dependencies
- **hGraphQL** -- Only direct module dependency; provides OctopusGraphQL fragments used by model initializers
- External: Apollo, Combine, SwiftUI, UnleashProxyClientSwift, SwiftUIIntrospect, GameKit

Almost every other module in the app imports hCore.

## Gotchas
- `Dependencies.resolve()` will `fatalError` at runtime if a dependency has not been registered -- there is no compile-time safety net for missing registrations
- `DateService` is resolved from the DI container, so date formatting extensions on Date and String will crash if `DateService` has not been registered
- `Masking` also conforms to `ViewModifier`, so it can be used both imperatively (calling `maskValue`/`isValid`) and declaratively (as `.modifier(masking)`)
- `TypeOfContract.resolve(for:)` uses a fuzzy substring match as a fallback before returning `.unknown` -- this can silently match the wrong contract type if raw values share substrings
- `L10n` / `Derived/Strings.swift` is auto-generated by SwiftGen from localization files; do not edit it manually
- The `log` global variable is force-unwrapped (`public var log: (any Logging)!`), so it must be initialized before any logging call or the app will crash
- `FeatureFlagsUnleash` contains hardcoded Unleash API keys and URL inline in the source
- `Localization.Locale` only supports Swedish locales (sv_SE, en_SE); there is no multi-market locale support
