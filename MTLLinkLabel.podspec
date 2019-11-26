#
#  Be sure to run `pod spec lint MyLibrary.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "MTLLinkLabel"
  s.version      = "0.1.7"
  s.summary      = "Linkable UILabel"

  s.description  = <<-DESC
                    MTLLinkLabel is linkable UILabel.
                   DESC

  s.homepage     = "http://mtl.recruit.co.jp"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "kokoro" => "korotan1@mac.com" }
  s.social_media_url   = "https://twitter.com/kokoron"

  s.platform     = :ios
  s.ios.deployment_target = '11.0'

  s.source       = { :git => "https://github.com/recruit-mtl/MTLLinkLabel.git",
                      :tag => "v0.1.6"
                    }

  # s.header_dir = "MTLLinkLabel"
  #
  # s.header_mappings_dir = "MTLLinkLabel"

  # s.public_header_files = "MTLLinkLabel/*.h"
  s.source_files  = "MTLLinkLabel/*.swift"

  s.requires_arc = true

end
