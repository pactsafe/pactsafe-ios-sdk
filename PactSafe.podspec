Pod::Spec.new do |spec|
  spec.name           = "PactSafe"
  spec.version        = "1.0.1"
  spec.summary        = "The PactSafe SDK makes for easier integration of PactSafe into your Swift project."
  spec.homepage       = "https://github.com/pactsafe/pactsafe-ios-sdk"
  spec.license        = { :type => "MIT", :file => "LICENSE" }
  spec.author         = { "Tim Morse" => "tim@pactsafe.com" }
  spec.platform       = :ios, "10.0"
  spec.source         = { :git => "https://github.com/pactsafe/pactsafe-ios-sdk.git", :tag => spec.version }
  spec.source_files   = "Sources/PactSafe/*.swift"
  spec.swift_version  = "5.0"
  spec.ios.framework  = 'UIKit'
end
