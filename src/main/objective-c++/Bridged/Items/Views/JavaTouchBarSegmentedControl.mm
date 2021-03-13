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

#import <AppKit/AppKit.h>
#import <string>
#import "JavaTouchBarSegmentedControl.h"
#import "JNIContext.h"
#import "JTouchBarUtils.h"

@implementation JavaTouchBarSegmentedControl {}

- (NSView*)createOrUpdateView:(NSView *)view env:(JNIEnv *)env jTouchBarView:(jobject)jTouchBarView {
    NSSegmentedControl *sc = nil;
    if(view == nil || ![view isKindOfClass:[NSSegmentedControl class]]) {
        sc = [[NSSegmentedControl alloc] init];
        sc.target = self;
        sc.action = @selector(onControlSelected:);
    } else {
        sc = static_cast<NSSegmentedControl *>(view);
    }

    int count = 0;

    std::vector<std::string> *labels = JNIContext::CallStringListMethod(env, jTouchBarView, "getLabels");
    if(labels != nil) {
        if(labels->size() > count) {
            count = static_cast<int>(labels->size());
            [sc setSegmentCount:count];
        }

        for (int i = 0; i < labels->size(); ++i) {
            [sc setLabel:[NSString stringWithCString:(*labels)[i].c_str() encoding:NSUTF8StringEncoding]forSegment:i];
        }
        delete labels;
    }

    std::vector<image_t> *images = JNIContext::CallImageListMethod(env, jTouchBarView, "getImages");
    if(images != nil) {
        if(images->size() > count) {
            count = static_cast<int>(images->size());
            [sc setSegmentCount:count];
        }
        for (int i = 0; i < images->size(); ++i) {
            [sc setImage:[JTouchBarUtils getNSImage:(*images)[i]] forSegment:i];
        }
        delete images;
    }

    NSSegmentStyle style = static_cast<NSSegmentStyle>(JNIContext::CallIntMethod(env, jTouchBarView, "getStyle"));
    [sc setSegmentStyle:style];

    NSSegmentSwitchTracking tracking = static_cast<NSSegmentSwitchTracking>(JNIContext::CallIntMethod(env, jTouchBarView, "getTracking"));
    [sc setTrackingMode:tracking];

    return sc;
}

- (void) onControlSelected:(NSSegmentedControl*)sc {
    if(_javaRepr == nullptr) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);
    jobject touchBarView = JNIContext::CallObjectMethod(env, _javaRepr, "getView", "com/thizzer/jtouchbar/item/view/TouchBarView");
    if(touchBarView == nullptr) {
        return;
    }

    jclass scCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarSegmentedControl");
    if(env->IsInstanceOf(touchBarView, scCls)) {
        jobject actionListener = JNIContext::CallObjectMethod(env, touchBarView, "getAction", "com/thizzer/jtouchbar/item/view/TouchBarSegmentedControl$SegmentedControlListener");
        if(actionListener == nullptr) {
            return;
        }
        JNIContext::CallVoidMethod(env, actionListener, "onSegmentSelected", "Lcom/thizzer/jtouchbar/item/view/TouchBarSegmentedControl;IZ",
                touchBarView, [sc selectedSegment], [sc isSelectedForSegment:[sc selectedSegment]]);
    }
    env->DeleteLocalRef(touchBarView);
}
@end