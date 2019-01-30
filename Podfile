platform :ios, '9.0'
project 'project.xcodeproj'

target 'ugglan' do
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
  pod 'FlowFramework', git: 'https://github.com/hedviginsurance/flow.git'
  pod 'PresentationFramework', git: 'https://github.com/hedviginsurance/presentation.git'
  pod 'FormFramework/Presentation', git: 'https://github.com/hedviginsurance/form.git'
  pod 'FormFramework', git: 'https://github.com/hedviginsurance/form.git'
  pod 'SnapKit', '~> 4.0.0'
  pod 'UICollectionView+AnimatedScroll', git: 'https://github.com/HedvigInsurance/UICollectionView-AnimatedScroll.git'
  pod 'FlowFeedback', git: 'https://github.com/HedvigInsurance/FlowFeedback.git'
  pod 'SwiftGen'
  pod 'Firebase/Core'
  pod 'AcknowList'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    if config.name == 'Release'
      config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
    end    
  end

  system("git config --local core.hooksPath .githooks/")
  system("Pods/SwiftGen/bin/swiftgen")
  system("sh scripts/update-translations.sh")
  system("sh scripts/update-graphql-schema.sh")
  system("sh scripts/generate-apollo-files.sh")
end
