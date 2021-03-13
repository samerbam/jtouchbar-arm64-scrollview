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

#import "JavaStepperTouchBarItem.h"
#import "JNIContext.h"

@implementation JavaStepperTouchBarItem {
    NSTouchBarItem *_touchBarItem;
}

- (NSTouchBarItem*)getTouchBarItem{
    if(self.javaRepr == nil) {
        return nil;
    }

    if(_touchBarItem == nil) {
        JNIEnv *env; JNIContext context(&env);

        NSString *identifier = [self getIdentifier:env reload:true];

        if(@available(macOS 10.15, *)) {
            NSStepperTouchBarItem *item = [[NSStepperTouchBarItem alloc] initWithIdentifier:identifier];

            [item setTarget:self];
            [item setAction:@selector(stepperDidMove:)];

            _touchBarItem = item;

            [self updateOrInitWithEnv:env];

        } else {
            NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];

            NSStepper *stepper = [[NSStepper alloc] init];

            [stepper setTarget:self];
            [stepper setAction:@selector(stepperDidMove:)];

            [item setView:stepper];
        }
    }

    return _touchBarItem;
}

- (void)update {
    JNIEnv *env; JNIContext context(&env);

    [self updateOrInitWithEnv:env];
}

- (void) updateOrInitWithEnv:(JNIEnv*)env {
    double minValue = JNIContext::CallDoubleMethod(env, self.javaRepr, "getMinValue");
    double maxValue = JNIContext::CallDoubleMethod(env, self.javaRepr, "getMaxValue");

    double increment = JNIContext::CallDoubleMethod(env, self.javaRepr, "getIncrement");

    if(@available(macOS 10.15, *)) {
        if([_touchBarItem isKindOfClass:[NSStepperTouchBarItem class]]) {
            NSStepperTouchBarItem *item = static_cast<NSStepperTouchBarItem *>(_touchBarItem);

            [item setMinValue:minValue];
            [item setMaxValue:maxValue];

            [item setIncrement:increment];
        }
    } else {
        if([_touchBarItem isKindOfClass:[NSCustomTouchBarItem class]]) {
            NSCustomTouchBarItem *item = static_cast<NSCustomTouchBarItem *>(_touchBarItem);
            NSStepper *stepper = [item view];

            [stepper setMinValue:minValue];
            [stepper setMaxValue:maxValue];

            [stepper setIncrement:increment];
        }
    }
}

- (void) stepperDidMove:(id)stepper {
    if(self.javaRepr == nullptr) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject actionListener = JNIContext::CallObjectMethod(env, self.javaRepr, "getAction",
            "com/thizzer/jtouchbar/item/StepperTouchBarItem$StepperActionListener");

    if(actionListener != nullptr) {
        if(@available(macOS 10.15, *)) {
            if([_touchBarItem isKindOfClass:[NSStepperTouchBarItem class]]) {
                NSStepperTouchBarItem *item = static_cast<NSStepperTouchBarItem *>(_touchBarItem);

                JNIContext::CallVoidMethod(env, actionListener, "onStepperChanged",
                        "Lcom/thizzer/jtouchbar/item/StepperTouchBarItem;D", self.javaRepr,[item value]);
            }
        } else {
            if([_touchBarItem isKindOfClass:[NSCustomTouchBarItem class]]) {
                NSCustomTouchBarItem *item = static_cast<NSCustomTouchBarItem *>(_touchBarItem);

                JNIContext::CallVoidMethod(env, actionListener, "onStepperChanged",
                        "Lcom/thizzer/jtouchbar/item/StepperTouchBarItem;D", self.javaRepr,
                        [static_cast<NSControl *>([item view]) doubleValue]);
            }
        }
    }

    env->DeleteLocalRef(actionListener);
}
@end