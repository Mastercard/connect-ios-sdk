Pod::Spec.new do |spec|
  spec.name         = "FinicityConnect"
  spec.module_name  = "Connect"
  spec.version      = "1.3.0"
  spec.summary      = "Connect iOS SDK"
  spec.description  = <<-DESC
                      The Connect iOS SDK allows you to embed Finicity Connect anywhere you want within your own mobile applications.
                      DESC
  spec.homepage     = "https://docs.finicity.com/connect-ios-sdk/"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = "Finicity"
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/Finicity/connect-ios-sdk.git", :tag => "#{spec.version}" }
  spec.ios.vendored_frameworks = "Connect.xcframework"
end
