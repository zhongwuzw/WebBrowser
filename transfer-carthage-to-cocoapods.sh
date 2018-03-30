#!/bin/bash

# substitute GCDWebServers
sed -i '' "10 a\ 
#import <GCDWebServer.h>
"  WebBrowser/Network/WebServer.h

sed -i '' "11 a\ 
#import <GCDWebServerDataResponse.h>
"  WebBrowser/Network/WebServer.h

sed -i '' '/#import <GCDWebServers\/GCDWebServers.h>/d' WebBrowser/Network/WebServer.h

# remove carthage framework reference
sed -i '' '/GCDWebServers.framework/d' WebBrowser.xcodeproj/project.pbxproj
sed -i '' '/CocoaLumberjack.framework/d' WebBrowser.xcodeproj/project.pbxproj
sed -i '' '/MBProgressHUD.framework/d' WebBrowser.xcodeproj/project.pbxproj
sed -i '' '/AFNetworking.framework/d' WebBrowser.xcodeproj/project.pbxproj
sed -i '' '/Mantle.framework/d' WebBrowser.xcodeproj/project.pbxproj
sed -i '' '/SDWebImage.framework/d' WebBrowser.xcodeproj/project.pbxproj

# remove Run Script
sed -i '' '/Begin PBXShellScriptBuildPhase section/,/End PBXShellScriptBuildPhase section/d' WebBrowser.xcodeproj/project.pbxproj