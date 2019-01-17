platform :ios, '9.0'

target 'Hedvig' do
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Hedvig
  pod 'DeviceKit', '~> 1.3'
  pod 'lottie-ios'
  pod 'SwiftLint'
  pod 'DynamicColor', '~> 4.0.2'
  pod 'SwiftFormat/CLI'
  pod 'Apollo'
  pod 'Apollo/WebSocket'
  pod 'Disk', '~> 0.4.0'
  pod 'FlowFramework', '~> 1.3'
  pod 'PresentationFramework', git: 'https://github.com/hedviginsurance/presentation.git'
  pod 'FormFramework/Presentation', git: 'https://github.com/hedviginsurance/form.git'
  pod 'FormFramework', git: 'https://github.com/hedviginsurance/form.git'
  pod 'SnapKit', '~> 4.0.0'
  pod 'UICollectionView+AnimatedScroll', git: 'https://github.com/HedvigInsurance/UICollectionView-AnimatedScroll.git'
  pod 'FlowFeedback', git: 'https://github.com/HedvigInsurance/FlowFeedback.git'
  pod 'SwiftGen'
  pod 'Firebase/Core'

  target 'HedvigTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  system("sh scripts/update-translations.sh")
  system("sh scripts/update-graphql-schema.sh")
end
