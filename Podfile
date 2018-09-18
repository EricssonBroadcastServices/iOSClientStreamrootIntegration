# Uncomment the next line to define a global platform for your project

inhibit_all_warnings!

def streamrootPod
  pod 'StreamrootSDK', '~> 3.3.0'
end

target 'ExposureStreamrootIntegration-iOS' do
  platform :ios, '9.3'
  use_frameworks!

  streamrootPod

end

target 'ExposureStreamrootIntegration-tvOS' do
 platform :tvos, '10.2'
  use_frameworks!
 
  streamrootPod

end


target 'ExposureStreamrootIntegrationTests' do
    platform :ios, '9.3'
    use_frameworks!
    
    streamrootPod
    
end

target 'ExposureStreamrootIntegration-tvOSTests' do
    platform :tvos, '10.2'
    use_frameworks!
    
    streamrootPod
    
end

target 'StreamrootIntegrationApp' do
    platform :ios, '9.3'
    use_frameworks!
    
    streamrootPod
    
end


target 'StreamrootIntegrationTvOSApp' do
    platform :tvos, '10.2'
    use_frameworks!
    
    streamrootPod
    
end

