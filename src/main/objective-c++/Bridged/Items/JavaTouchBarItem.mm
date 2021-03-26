/**
 * JTouchBar
 *
 * Copyright (c) 2018 - 2019 thizzer.com
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 *
 * @author  	M. ten Veldhuis
 */
#import "JavaTouchBarItem.h"

#include <string>

#include "JNIContext.h"
#include "JTouchBarUtils.h"

#include "JavaTouchBar.h"

#import "JavaTouchBarButton.h"
#import "JavaTouchBarTextField.h"
#import "JavaTouchBarScrubber.h"
#import "JavaTouchBarSlider.h"
#import "JavaTouchBarSegmentedControl.h"

@interface JavaTouchBarItem() {
    NSString *_identifier;
    NSString *_customizationLabel;
    BOOL _customizationAllowed;

    JavaTouchBarView *_touchBarView;
    NSView *_view;
}

@end

@implementation JavaTouchBarItem

-(void) update {
    [self createOrUpdateView];
}

-(NSTouchBarItem*) getTouchBarItem {
    if(_javaRepr == NULL) {
        return nil;
    }
    
    JNIEnv *env; JNIContext context(&env);
    
    NSString *identifier = [self getIdentifier:env reload:TRUE];
    
    NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
    item.customizationLabel = [self getCustomizationLabel:env reload:TRUE];
    item.view = [self getView];

    return item;
}

-(NSString*) getIdentifier:(JNIEnv*)env reload:(BOOL)reload {
    if(reload) {
        std::string identifier = JNIContext::CallStringMethod(env, _javaRepr, "getIdentifier");
        if(identifier.empty()) {
            _identifier = nil;
        }
        else {
            _identifier = [NSString stringWithUTF8String:identifier.c_str()];
        }
    }
    
    return _identifier;
}

-(NSString*) getIdentifier {
    if(_javaRepr == NULL) {
        return nil;
    }
    
    JNIEnv *env; JNIContext context(&env);
    return [self getIdentifier:env reload:TRUE];
}

-(NSString*) getCustomizationLabel:(JNIEnv*)env reload:(BOOL)reload {
    if(reload) {
        std::string customizationLabel = JNIContext::CallStringMethod(env, _javaRepr, "getCustomizationLabel");
        if(customizationLabel.empty()) {
            _customizationLabel = nil;
        }
        else {
            _customizationLabel = [NSString stringWithUTF8String:customizationLabel.c_str()];
        }
    }
    
    return _customizationLabel;
}

-(NSString*) getCustomizationLabel {
    if(_javaRepr == NULL) {
        return nil;
    }
    
    JNIEnv *env; JNIContext context(&env);
    return [self getCustomizationLabel:env reload:TRUE];
}

-(BOOL) isCustomizationAllowed:(JNIEnv*)env reload:(BOOL)reload {
    if(reload) {
        _customizationAllowed = JNIContext::CallBooleanMethod(env, _javaRepr, "isCustomizationAllowed");
    }
    
    return _customizationAllowed;
}

-(BOOL) isCustomizationAllowed {
    if(_javaRepr == NULL) {
        return FALSE;
    }

    JNIEnv *env; JNIContext context(&env);
    return [self isCustomizationAllowed:env reload:TRUE];
}

-(NSView*) getView {
    if(_javaRepr == NULL) {
        return nil;
    }
    
    [self createOrUpdateView];
    
    return _view;
}

-(void) createOrUpdateView {
    @synchronized(_view) {
        JNIEnv *env; JNIContext context(&env);

        jobject jTouchBarView = JNIContext::CallObjectMethod(env, _javaRepr, "getView", "com/thizzer/jtouchbar/item/view/TouchBarView");
        _view = [self createOrUpdateView:_view jTouchBarView:jTouchBarView];
    }
}

-(NSView*) createOrUpdateView:(NSView*)viewToCreateOrUpdate jTouchBarView:(jobject)jTouchBarView {
    if(jTouchBarView == nullptr) {
        viewToCreateOrUpdate = nil;
        return viewToCreateOrUpdate;
    }
    
    JNIEnv *env; JNIContext context(&env);
    
    jclass buttonCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarButton");
    if(env->IsInstanceOf(jTouchBarView, buttonCls)) {
        if(_touchBarView == nil || ![_touchBarView isKindOfClass:[JavaTouchBarButton class]]) {
            _touchBarView = [[JavaTouchBarButton alloc] init];
            [_touchBarView setJavaRepr:_javaRepr];
        }
    }
    
    jclass textFieldCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarTextField");
    if(env->IsInstanceOf(jTouchBarView, textFieldCls)) {
        if(_touchBarView == nil || ![_touchBarView isKindOfClass:[JavaTouchBarTextField class]]) {
            _touchBarView = [[JavaTouchBarTextField alloc] init];
            [_touchBarView setJavaRepr:_javaRepr];
        }
    }
    
    jclass scrubberCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarScrubber");
    if(env->IsInstanceOf(jTouchBarView, scrubberCls)) {
        if(_touchBarView == nil || ![_touchBarView isKindOfClass:[JavaTouchBarScrubber class]]) {
            _touchBarView = [[JavaTouchBarScrubber alloc] init];
            [_touchBarView setJavaRepr:_javaRepr];
        }
    }
    
    jclass sliderCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarSlider");
    if(env->IsInstanceOf(jTouchBarView, sliderCls)) {
        if(_touchBarView == nil || ![_touchBarView isKindOfClass:[JavaTouchBarSlider class]]) {
            _touchBarView = [[JavaTouchBarSlider alloc] init];
            [_touchBarView setJavaRepr:_javaRepr];
        }
    }

    jclass scCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarSegmentedControl");
    if(env->IsInstanceOf(jTouchBarView, scCls)) {
        if(_touchBarView == nil || ![_touchBarView isKindOfClass:[JavaTouchBarSegmentedControl class]]) {
            _touchBarView = [[JavaTouchBarSegmentedControl alloc] init];
            [_touchBarView setJavaRepr:_javaRepr];
        }
    }

    if(_touchBarView == nil) {
        //TODO: error state
    }
    viewToCreateOrUpdate = [_touchBarView createOrUpdateView:viewToCreateOrUpdate env:env jTouchBarView:jTouchBarView];

    [self setNativeInstancePointer:jTouchBarView toInstance:viewToCreateOrUpdate];
    
    return viewToCreateOrUpdate;
}

-(void) setJavaRepr:(jobject)javaRepr {
    JNIEnv *env; JNIContext context(&env);
    if(_javaRepr != NULL) {
        [self setNativeInstancePointer:_javaRepr toInstance:nil];
        env->DeleteGlobalRef(_javaRepr);
    }
    if(javaRepr != NULL) {
        _javaRepr = env->NewGlobalRef(javaRepr);
        [self setNativeInstancePointer:_javaRepr toInstance:self];
    }
    else {
        _javaRepr = NULL;
    }
    [_touchBarView setJavaRepr:_javaRepr];
}

-(void) setNativeInstancePointer:(jobject)nativeLinkObj toInstance:(id)instance {
    if(nativeLinkObj == NULL) {
        return;
    }
    JNIEnv *env; JNIContext context(&env);
    JNIContext::CallVoidMethod(env, nativeLinkObj, "setNativeInstancePointer", "J", (long) instance);
}

-(void) dealloc {
    [self setJavaRepr:NULL];
}

@end
