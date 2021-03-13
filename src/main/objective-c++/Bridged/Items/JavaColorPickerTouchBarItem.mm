/*
 * JTouchBar
 *
 * Copyright (c) 2021 thizzer.com
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 *
 * @author      C. Klein
 */

#import "JavaColorPickerTouchBarItem.h"
#import "JNIContext.h"


@implementation JavaColorPickerTouchBarItem {
    NSColorPickerTouchBarItem *_touchBarItem;
}

- (NSTouchBarItem*) getTouchBarItem {
    if(self.javaRepr == nullptr) {
        return nil;
    }

    if(_touchBarItem == nil) {
        JNIEnv *env; JNIContext context(&env);

        NSString *identifier = [super getIdentifier:env reload:true];

        _touchBarItem = [[NSColorPickerTouchBarItem alloc] initWithIdentifier:identifier];

        [_touchBarItem setTarget:self];
        [_touchBarItem setAction:@selector(colorChosen:)];
    }

    return _touchBarItem;
}

- (void) colorChosen:(NSColorPickerTouchBarItem *)colorPicker {
    if(self.javaRepr == nullptr) {
        return;
    }
    JNIEnv *env; JNIContext context(&env);

    NSColor *color = [colorPicker color];
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];

    jclass colorClass = env->FindClass("com/thizzer/jtouchbar/common/Color");
    jmethodID colorConstructor = env->GetMethodID(colorClass, "<init>", "(FFFF)V");
    jobject colorObj = env->NewObject(colorClass, colorConstructor, r, g, b, a);

    jobject actionListener = JNIContext::CallObjectMethod(env, self.javaRepr, "getAction",
            "com/thizzer/jtouchbar/item/ColorPickerTouchBarItem$ColorSelectedListener");
    if(actionListener != nullptr) {
        JNIContext::CallVoidMethod(env, actionListener, "onColorSelected",
                "Lcom/thizzer/jtouchbar/item/ColorPickerTouchBarItem;Lcom/thizzer/jtouchbar/common/Color;",
                self.javaRepr, colorObj);
    }

    env->DeleteLocalRef(colorObj);
    env->DeleteLocalRef(actionListener);
}
@end