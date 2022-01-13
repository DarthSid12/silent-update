#import "SilentUpdatePlugin.h"
#if __has_include(<silent_update/silent_update-Swift.h>)
#import <silent_update/silent_update-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "silent_update-Swift.h"
#endif

@implementation SilentUpdatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSilentUpdatePlugin registerWithRegistrar:registrar];
}
@end
