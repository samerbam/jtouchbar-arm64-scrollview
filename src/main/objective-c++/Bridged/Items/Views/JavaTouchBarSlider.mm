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
#import "JavaTouchBarSlider.h"
#import "JNIContext.h"

DEPRECATED_ATTRIBUTE
@implementation JavaTouchBarSlider {}

- (NSView*)createOrUpdateView:(NSView *)view env:(JNIEnv *)env jTouchBarView:(jobject)jTouchBarView {
    NSSlider *slider = nil;
    if(view == nil || ![view isKindOfClass:[NSSlider class]]) {
        slider = [NSSlider sliderWithTarget:self action:@selector(onSliderAction:)];
    } else {
        slider = (NSSlider *)(view);
    }

    double minValue = JNIContext::CallDoubleMethod(env, jTouchBarView, "getMinValue");
    [slider setMinValue:minValue];

    double maxValue = JNIContext::CallDoubleMethod(env, jTouchBarView, "getMaxValue");
    [slider setMaxValue:maxValue];

    return slider;
}

- (void) onSliderAction:(NSSlider*)slider {
    if(_javaRepr == nullptr) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);
    jobject touchBarView = JNIContext::CallObjectMethod(env, _javaRepr, "getView", "com/thizzer/jtouchbar/item/view/TouchBarView");
    if(touchBarView == nullptr) {
        return;
    }

    jclass sliderCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarSlider");
    if(env->IsInstanceOf(touchBarView, sliderCls)) {
        jobject actionListener = JNIContext::CallObjectMethod(env, touchBarView, "getActionListener", "com/thizzer/jtouchbar/slider/SliderActionListener");
        if(actionListener == nullptr) {
            return;
        }
        JNIContext::CallVoidMethod(env, actionListener, "sliderValueChanged", "Lcom/thizzer/jtouchbar/item/view/TouchBarSlider;D", touchBarView, [slider doubleValue]);
    }
    env->DeleteLocalRef(touchBarView);
}
@end