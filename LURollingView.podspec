#
# Be sure to run `pod lib lint LURollingView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LURollingView"
  s.version          = "0.1.2"
  s.summary          = "Using LURollingView to create rolling labels"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Using LURollingLabel to create rolling labels
                       DESC

  s.homepage         = "https://github.com/lunnersword/LURollingView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "bingchen" => "bingchen@kongge.com" }
  s.source           = { :git => "https://github.com/lunnersword/LURollingView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'LURollingView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LURollingView' => ['LURollingView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
