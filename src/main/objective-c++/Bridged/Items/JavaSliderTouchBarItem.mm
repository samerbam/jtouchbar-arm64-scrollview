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

#import "JavaSliderTouchBarItem.h"

#import "JNIContext.h"
#import "JTouchBarUtils.h"


@implementation JavaSliderTouchBarItem {
    NSSliderTouchBarItem *_touchBarItem;
}

- (NSTouchBarItem*) getTouchBarItem {
    if(self.javaRepr == nullptr) {
        return nil;
    }

    if(_touchBarItem == nullptr) {
        JNIEnv *env; JNIContext context(&env);

        NSString *identifier = [super getIdentifier:env reload:true];

        _touchBarItem = [[NSSliderTouchBarItem alloc] initWithIdentifier:identifier];

        [self updateOrInitWithEnv:env];

        [_touchBarItem setTarget:self];
        [_touchBarItem setAction:@selector(sliderDidMove:)];
    }

    return _touchBarItem;
}

- (void) update {
    JNIEnv *env; JNIContext context(&env);

    [self updateOrInitWithEnv:env];

    [[_touchBarItem slider] performClick:nil];
}

- (void) updateOrInitWithEnv:(JNIEnv*)env{
    double minValue = JNIContext::CallDoubleMethod(env, self.javaRepr, "getMinValue");
    double maxValue = JNIContext::CallDoubleMethod(env, self.javaRepr, "getMaxValue");

    double increment = JNIContext::CallDoubleMethod(env, self.javaRepr, "getIncrement");

    color_t fillColor_t = JNIContext::CallColorMethod(env, self.javaRepr, "getFillColor");

    NSColor *fillColor = [JTouchBarUtils getNSColor:fillColor_t];

    std::string label = JNIContext::CallStringMethod(env, self.javaRepr, "getLabel");

    image_t minImage_t = JNIContext::CallImageMethod(env, self.javaRepr, "getMinImage");
    image_t maxImage_t = JNIContext::CallImageMethod(env, self.javaRepr, "getMaxImage");

    NSImage *minImage = [JTouchBarUtils getNSImage:minImage_t];
    NSImage *maxImage = [JTouchBarUtils getNSImage:maxImage_t];

    if(label.empty())
        [_touchBarItem setLabel:nil];
    else
        [_touchBarItem setLabel:[NSString stringWithUTF8String:label.c_str()]];

    [[_touchBarItem slider] setMinValue:minValue];
    [[_touchBarItem slider] setMaxValue:maxValue];
    [[_touchBarItem slider] setAltIncrementValue:increment];
    if(minImage != nil)
        [_touchBarItem setMinimumValueAccessory:[NSSliderAccessory accessoryWithImage:minImage]];
    if(maxImage != nil)
        [_touchBarItem setMaximumValueAccessory:[NSSliderAccessory accessoryWithImage:maxImage]];
    if(fillColor_t.alpha > 0 || !fillColor_t.nsColorKey.empty())
        [[_touchBarItem slider] setTrackFillColor:fillColor];
}

- (void) sliderDidMove:(NSSliderTouchBarItem *)slider {
    if(self.javaRepr == nullptr) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject actionListener = JNIContext::CallObjectMethod(env, self.javaRepr, "getActionListener",
            "com/thizzer/jtouchbar/item/SliderTouchBarItem$SliderActionListener");

    if(actionListener != nullptr) {
        JNIContext::CallVoidMethod(env, actionListener, "sliderValueChanged",
                "Lcom/thizzer/jtouchbar/item/SliderTouchBarItem;D", self.javaRepr,[[slider slider]doubleValue]);
    }

    env->DeleteLocalRef(actionListener);
}
@end