# Taken from https://medium.com/onfido-tech/distributing-compiled-swift-frameworks-via-cocoapods-8cb67a584d57
# create folder where we place built frameworks
mkdir build
# build framework for simulators
xcodebuild clean build   -project Connect.xcodeproj   -scheme Connect   -configuration Release   -sdk iphonesimulator   -derivedDataPath derived_data -xcconfig Config.xcconfig
# create folder to store compiled framework for simulator
mkdir build/simulator
# copy compiled framework for simulator into our build folder
cp -r derived_data/Build/Products/Release-iphonesimulator/Connect.framework build/simulator
#build framework for devices
xcodebuild clean build   -project Connect.xcodeproj   -scheme Connect   -configuration Release   -sdk iphoneos   -derivedDataPath derived_data -xcconfig Config.xcconfig
# create folder to store compiled framework for simulator
mkdir build/devices
# copy compiled framework for simulator into our build folder
cp -r derived_data/Build/Products/Release-iphoneos/Connect.framework build/devices
# create folder to store compiled universal framework
mkdir build/universal
####################### Create universal framework #############################
# copy device framework into universal folder
cp -r build/devices/Connect.framework build/universal/
# create framework binary compatible with simulators and devices, and replace binary in universal framework
lipo -create   build/simulator/Connect.framework/Connect   build/devices/Connect.framework/Connect   -output build/universal/Connect.framework/Connect
# copy simulator Swift public interface to universal framework
cp build/simulator/Connect.framework/Modules/Connect.swiftmodule/* build/universal/Connect.framework/Modules/Connect.swiftmodule
