Pod::Spec.new do |s|
  s.name         = "Sentry"
  s.version      = "7.27.0"
  s.summary      = "Sentry client for cocoa"
  s.homepage     = "https://github.com/getsentry/sentry-cocoa"
  s.license      = "mit"
  s.authors      = "Sentry"
  s.source       = { :git => "https://github.com/getsentry/sentry-cocoa.git",
                     :tag => s.version.to_s }

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.module_name  = "Sentry"
  s.requires_arc = true
  s.swift_versions = "5.0"
  s.frameworks = 'Foundation'
  s.libraries = 'z', 'c++'
  s.pod_target_xcconfig = {
      'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES',
      'CLANG_CXX_LANGUAGE_STANDARD' => 'c++14',
      'CLANG_CXX_LIBRARY' => 'libc++'
}
  
  s.default_subspecs = ['Sentry', 'SentryObjc']
  s.source_files = "Sources/Configuration/CocoaPodHeader/Sentry.h"
  
  s.subspec 'Sentry' do |sp|
      sp.source_files = "Sources/SentrySwift/**/*.{swift}"
      sp.exclude_files = "Sources/SentrySwift/TypeAlias.swift"
  end
  
  s.subspec 'SentryObjc' do |sp|
      sp.source_files = "Sources/Sentry/**/*.{h,hpp,m,mm,c,cpp}", "Sources/SentryCrash/**/*.{h,hpp,m,mm,c,cpp}"
        
      sp.public_header_files =
        "Sources/Sentry/Public/*.h"
    
  end
  
  
end
