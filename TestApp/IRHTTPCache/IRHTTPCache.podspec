Pod::Spec.new do |spec|
  spec.name         = "IRHTTPCache"
  spec.version      = "1.0.0"
  spec.summary      = "HTTP Cache."
  spec.description  = "HTTP Cache."
  spec.homepage     = "https://github.com/irons163/IRHTTPCache.git"
  spec.license      = "MIT"
  spec.author       = "irons163"
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/irons163/IRHTTPCache.git", :tag => spec.version.to_s }
  spec.source_files  = "IRHTTPCache/Classes/**/*.{h,m,xib}"
  spec.dependency "IRCocoaHTTPServer"
end
