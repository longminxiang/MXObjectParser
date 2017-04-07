Pod::Spec.new do |s|
  s.name             = "MXObjectParser"
  s.version          = "0.1.2"
  s.summary          = "parse object with dic"

  s.homepage         = "https://github.com/longminxiang/MXObjectParser"

  s.license          = 'MIT'
  s.author           = { "Eric Lung" => "longminxiang@gmail.com" }
  s.source           = { :git => "https://github.com/longminxiang/MXObjectParser.git", :tag => "v" + s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true

  s.source_files = 'MXObjectParser/**/*.{h,m}'

end
