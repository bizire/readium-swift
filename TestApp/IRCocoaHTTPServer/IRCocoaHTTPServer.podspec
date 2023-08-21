Pod::Spec.new do |spec|
  spec.name         = "IRCocoaHTTPServer"
  spec.version      = "1.0.0"
  spec.summary      = "HTTP server."
  spec.description  = "HTTP server."
  spec.homepage     = "https://github.com/irons163/IRCocoaHTTPServer.git"
  spec.license      = "MIT"
  spec.author       = "irons163"
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/irons163/IRCocoaHTTPServer.git", :tag => spec.version.to_s }
  spec.source_files  = "IRCocoaHTTPServer/**/*.{h,m,xib}"
end