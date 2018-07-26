Pod::Spec.new do |s|
  # 1
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name  = "AWSSNSSubscriptor"
  s.summary = "AWS's manager that handle subscription of sns's service."
  #s.summary = "Addon from SVProgressHUD with dismiss on touch up inside the alert."
  s.requires_arc = true

  # 2
  s.version      = "0.0.1"

  # 3
  #s.licence = { :type => "MIT", :file => "LICENSE" }

  # 4
  s.author = { "alfredolucomav" => "alfredo.luco@mavericks" }

  # 5
  s.homepage = ""

  # 6
  s.source = { :git => "", :tag => "0.0.1" }

  # 7
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AWSSNS'

  # 8
  s.ios.source_files = 'Sources/**/*.swift'

end

