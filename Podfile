# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'taksiUygulamasi' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for taksiUygulamasi
pod 'Firebase'
pod 'FirebaseFirestore'
pod 'FirebaseAuth'
post_install do |installer|
   installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64 i386"
   end
   end
 end
end
