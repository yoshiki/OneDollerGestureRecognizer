Pod::Spec.new do |s|
  s.name = "OneDollerGestureRecognizer"
  s.version = "0.0.1"
  s.summary = "A library to recognize gesture using the $1 Unistroke Recognizer in Swift."
  s.homepage = "https://github.com/yoshiki/OneDollerGestureRecognizer"
  s.license = "MIT"
  s.author = { "Yoshiki Kurihara" => "clouder@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.source = { :git => "https://github.com/yoshiki/OneDollerGestureRecognizer.git", :tag => s.version.to_s }
  s.source_files  = "OneDollerGestureRecognizer/*.swift"
  s.requires_arc = true
end
