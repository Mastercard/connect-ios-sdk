Pod::Spec.new do |spec|
  spec.name         = "MastercardOpenBankingConnect"
  spec.module_name  = "Connect"
  spec.version      = "2.1.0"
  spec.summary      = "Connect iOS SDK"
  spec.description  = <<-DESC
                      The Connect iOS SDK allows you to embed MastercardOpenBanking Connect anywhere you want within your own mobile applications.
                      DESC
  spec.homepage     = "https://developer.mastercard.com/open-banking-us/documentation/connect/mobile-sdks/#ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = "MastercardOpenBanking"
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/Mastercard/connect-ios-sdk.git", :tag => "#{spec.version}" }
  spec.ios.vendored_frameworks = "Connect.xcframework"
end
