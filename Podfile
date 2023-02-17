platform :ios, '14.0'
workspace 'MEDIAMUG'

inhibit_all_warnings!
use_frameworks!

def sdk
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
end

target 'MEDIAMUG' do
  project 'MEDIAMUG/MEDIAMUG'

#  sdk
  pod 'WaterfallGrid'
  pod 'ExytePopupView'
  pod 'YouTubePlayer'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
