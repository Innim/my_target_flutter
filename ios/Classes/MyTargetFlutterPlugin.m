#import "MyTargetFlutterPlugin.h"
#if __has_include(<my_target_flutter/my_target_flutter-Swift.h>)
#import <my_target_flutter/my_target_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "my_target_flutter-Swift.h"
#endif

@implementation MyTargetFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMyTargetFlutterPlugin registerWithRegistrar:registrar];
}
@end
