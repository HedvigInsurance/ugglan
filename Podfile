platform :ios, '9.0'

target 'Hedvig' do
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Hedvig
  pod 'Tempura'
  pod 'PinLayout'
  pod 'SwiftLint'
  pod 'DynamicColor', '~> 4.0.2'
  pod 'SwiftFormat/CLI'
  pod 'Apollo'
  pod 'Apollo/WebSocket'
  pod 'Disk', '~> 0.4.0'
  pod 'FlowFramework', '~> 1.0'
  pod 'FormFramework/Presentation', git: 'https://github.com/hedviginsurance/form.git'
  pod 'FormFramework', git: 'https://github.com/hedviginsurance/form.git'
  pod 'SnapKit', '~> 4.0.0'
  pod 'UICollectionView+AnimatedScroll', git: 'https://github.com/HedvigInsurance/UICollectionView-AnimatedScroll.git'

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      if config.name == 'Release'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      else
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      end    
    end
  end

  target 'HedvigTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'TempuraTesting'
    pod 'Tempura'
    pod 'PinLayout'
  end
end
