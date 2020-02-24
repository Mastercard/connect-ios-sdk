Pod::Spec.new do |s|
    s.name         = "Connect"
    s.version      = "0.1.1"
    s.summary      = "iOS Connect SDK"
    s.description  = <<-DESC
    iOS framework for Connect
    DESC
    s.homepage     = "https://www.finicity.com"
    s.license = { :type => 'Copyright', :text => <<-LICENSE
                   Copyright 2020
                   
                  LICENSE
                }
    s.author             = { "Finicity" => "sid.pitt@finicity.com" }
    s.source       = { :git => "https://github.com/sid-finicity/ios-sdk.git", :tag => "#{s.version}" }
    s.public_header_files = "Connect.framework/Headers/*.h"
    s.source_files = "Connect.framework/Headers/*.h"
    s.vendored_frameworks = "Connect.framework"
    s.platform = :ios
    s.swift_version = "4.2"
    s.ios.deployment_target  = '12.0'
end
