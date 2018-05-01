# Uncomment this line to define a global platform for your project
platform :ios, '9.1'
use_frameworks!

target 'RKRett' do
    #pod 'ResearchKit', '~> 1.0'
    pod 'ResearchKit'
    pod 'CareKit'
    pod 'SVProgressHUD'
    pod 'RealmSwift'
    pod 'SwiftKeychainWrapper'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod 'JBChartView'
    pod 'ScrollableGraphView'
    pod 'Buglife', '~> 2.5'
    pod 'Parse'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end

target 'RKRettTests' do
    pod 'RealmSwift'
end
