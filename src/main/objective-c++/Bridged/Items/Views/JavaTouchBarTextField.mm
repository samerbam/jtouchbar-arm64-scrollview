/*
 * JTouchBar
 *
 * Copyright (c) 2018 - 2019 thizzer.com
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 *
 * @author  	M. ten Veldhuis
 */

#import <AppKit/AppKit.h>
#import <string>
#import "JavaTouchBarTextField.h"
#import "JNIContext.h"


@implementation JavaTouchBarTextField {}

- (NSView *)createOrUpdateView:(NSView *)view env:(JNIEnv *)env jTouchBarView:(jobject)jTouchBarView {
    NSTextField *textField;
    if(view == nil || ![view isKindOfClass:[NSTextField class]]) {
        textField = [NSTextField labelWithString:@""];
    } else {
        textField = static_cast<NSTextField *>(view);
    }

    // update stringValue
    std::string stringValue = JNIContext::CallStringMethod(env, jTouchBarView, "getStringValue");
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField setStringValue:[NSString stringWithUTF8String:stringValue.c_str()]];
    });

    return textField;
}

@end