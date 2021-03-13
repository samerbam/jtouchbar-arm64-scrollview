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
#import <Cocoa/Cocoa.h>
#import "JavaTouchBarButton.h"
#import "JNIContext.h"
#import "JTouchBarUtils.h"

@implementation JavaTouchBarButton {}

- (NSView*)createOrUpdateView:(NSView *)view env:(JNIEnv *)env jTouchBarView:(jobject)jTouchBarView{
    NSButton *button = nil;
    if(view == nil || ![view isKindOfClass:[NSButton class]]) {
        button = [NSButton buttonWithTitle:@"" target:self action:@selector(onPressed:)];
    } else {
        button = (NSButton *)(view);
    }

    // update title
    std::string title = JNIContext::CallStringMethod(env, jTouchBarView, "getTitle");
    std::string alternateTitle = JNIContext::CallStringMethod(env, jTouchBarView, "getAlternateTitle");

    color_t color = JNIContext::CallColorMethod(env, jTouchBarView, "getBezelColor");

    image_t image = JNIContext::CallImageMethod(env, jTouchBarView, "getImage");
    image_t alternateImage = JNIContext::CallImageMethod(env, jTouchBarView, "getAlternateImage");

    int imagePosition = JNIContext::CallIntMethod(env, jTouchBarView, "getImagePosition");

    NSImage *nsImage = [JTouchBarUtils getNSImage:image];
    NSImage *nsAlternateImage = [JTouchBarUtils getNSImage:alternateImage];

    bool allowsMixedState = JNIContext::CallBooleanMethod(env, jTouchBarView, "getAllowsMixedState");

    int buttonType = JNIContext::CallIntMethod(env, jTouchBarView, "getButtonType");
    bool enabled = JNIContext::CallBooleanMethod(env, jTouchBarView, "isEnabled");

    dispatch_async(dispatch_get_main_queue(), ^{
        if(!title.empty()) {
            [button setTitle:[NSString stringWithUTF8String:title.c_str()]];
        }

        if(!alternateTitle.empty()) {
            [button setAlternateTitle:[NSString stringWithUTF8String:alternateTitle.c_str()]];
        }

        if(nsImage != nil) {
            [button setImage:nsImage];
            [button setImagePosition:(NSCellImagePosition)imagePosition];
        }

        if(nsAlternateImage != nil) {
            [button setAlternateImage:nsAlternateImage];
            [button setImagePosition:(NSCellImagePosition)imagePosition]; // ensure image position has been set
        }

        [button setBezelColor:[JTouchBarUtils getNSColor:color]];

        [button setButtonType:(NSButtonType)buttonType];
        [button setAllowsMixedState:allowsMixedState];
        [button setEnabled:enabled];
    });

    return button;
}

- (void) onPressed:(NSButton*)button {
    if(_javaRepr == nullptr) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject touchBarview = JNIContext::CallObjectMethod(env, _javaRepr, "getView", "com/thizzer/jtouchbar/item/view/TouchBarView");
    if(touchBarview == nullptr) {
        return;
    }

    jclass buttonCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarButton");
    if(env->IsInstanceOf(touchBarview, buttonCls)) {
        JNIContext::CallVoidMethod(env, touchBarview, "trigger");
    }

    env->DeleteLocalRef(touchBarview);
}
@end