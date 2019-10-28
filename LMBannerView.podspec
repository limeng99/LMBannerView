
Pod::Spec.new do |s|
    s.name             = "LMBannerView"
    s.version          = "0.1.2"
    s.summary          = "轮播图"
    s.homepage         = "https://github.com/limeng99/LMBannerView"
    s.license          = "MIT"
    s.author           = { "Limeng" => "LM" }
    s.source           = { :git => "https://github.com/limeng99/LMBannerView", :tag => "0.1.2" }
    s.platform         = :ios
    s.requires_arc     = true
    s.ios.deployment_target = "8.0"
    s.source_files     = "LMBannerView/Classes/*.{h,m}"
end
