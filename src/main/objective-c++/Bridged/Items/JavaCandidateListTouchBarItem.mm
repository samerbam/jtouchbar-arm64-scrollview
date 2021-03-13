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

#import "JavaCandidateListTouchBarItem.h"
#import "JNIContext.h"

@implementation JavaCandidateListTouchBarItem {
    NSCandidateListTouchBarItem<NSString*> *_touchBarItem;
}

- (NSTouchBarItem *)getTouchBarItem {
    if(self.javaRepr == nil) {
        return nil;
    }

    if(_touchBarItem == nil) {
        JNIEnv *env; JNIContext context(&env);

        NSString *identifier = [super getIdentifier:env reload:true];

        _touchBarItem = [[NSCandidateListTouchBarItem alloc] initWithIdentifier:identifier];

        [self updateOrInitWithEnv:env];

        [_touchBarItem setDelegate:self];
    }

    return _touchBarItem;
}

- (void)update {
    JNIEnv *env; JNIContext context(&env);

    [self updateOrInitWithEnv:env];
}

- (void) updateOrInitWithEnv:(JNIEnv*)env {
    std::string context = JNIContext::CallStringMethod(env, self.javaRepr, "getContext");

    uint32_t rangeStart = static_cast<uint32_t>(JNIContext::CallIntMethod(env, self.javaRepr, "getRangeStart"));
    uint32_t rangeEnd = static_cast<uint32_t>(JNIContext::CallIntMethod(env, self.javaRepr, "getRangeEnd"));

    std::vector<std::string> *list = JNIContext::CallStringListMethod(env, self.javaRepr, "getCandidates");
    NSMutableArray *candidates = [[NSMutableArray alloc] init];
    if(list != nullptr) {
        for (int i = 0; i < list->size(); ++i) {
            [candidates addObject:[NSString stringWithCString:(*list)[i].c_str() encoding:NSUTF8StringEncoding]];
        }
        delete list;
    }

    [_touchBarItem setCandidates:candidates forSelectedRange:NSMakeRange(rangeStart,rangeEnd-rangeStart)
                        inString:[NSString stringWithCString:context.c_str() encoding:NSUTF8StringEncoding]];
}

- (void)candidateListTouchBarItem:(NSCandidateListTouchBarItem *)anItem
   beginSelectingCandidateAtIndex:(NSInteger)index {
    if(self.javaRepr == nil) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject delegate = JNIContext::CallObjectMethod(env, self.javaRepr, "getDelegate",
            "com/thizzer/jtouchbar/item/CandidateListTouchBarItem$CandidateListDelegate");
    if(delegate != nullptr) {
        JNIContext::CallVoidMethod(env, delegate, "beginSelectingCandidate",
                "Lcom/thizzer/jtouchbar/item/CandidateListTouchBarItem;I",self.javaRepr, index);
    }

    env->DeleteLocalRef(delegate);
}

- (void)candidateListTouchBarItem:(NSCandidateListTouchBarItem *)anItem
    changeSelectionFromCandidateAtIndex:(NSInteger)previousIndex toIndex:(NSInteger)index {
    if(self.javaRepr == nil) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject delegate = JNIContext::CallObjectMethod(env, self.javaRepr, "getDelegate",
            "com/thizzer/jtouchbar/item/CandidateListTouchBarItem$CandidateListDelegate");
    if(delegate != nullptr) {
        JNIContext::CallVoidMethod(env, delegate, "changeCandidateSelection",
                "Lcom/thizzer/jtouchbar/item/CandidateListTouchBarItem;II",self.javaRepr, index, previousIndex);
    }

    env->DeleteLocalRef(delegate);
}

- (void)candidateListTouchBarItem:(NSCandidateListTouchBarItem *)anItem
     endSelectingCandidateAtIndex:(NSInteger)index {
    if(self.javaRepr == nil) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject delegate = JNIContext::CallObjectMethod(env, self.javaRepr, "getDelegate",
            "com/thizzer/jtouchbar/item/CandidateListTouchBarItem$CandidateListDelegate");
    if(delegate != nullptr) {
        JNIContext::CallVoidMethod(env, delegate, "endSelectingCandidate",
                "Lcom/thizzer/jtouchbar/item/CandidateListTouchBarItem;I",self.javaRepr, index);
    }

    env->DeleteLocalRef(delegate);
}

- (void)candidateListTouchBarItem:(NSCandidateListTouchBarItem *)anItem
   changedCandidateListVisibility:(BOOL)isVisible {
    if(self.javaRepr == nil) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject delegate = JNIContext::CallObjectMethod(env, self.javaRepr, "getDelegate",
            "com/thizzer/jtouchbar/item/CandidateListTouchBarItem$CandidateListDelegate");
    if(delegate != nullptr) {
        JNIContext::CallVoidMethod(env, delegate, "candidateVisibilityChanged",
                "Lcom/thizzer/jtouchbar/item/CandidateListTouchBarItem;Z",self.javaRepr, isVisible);
    }

    env->DeleteLocalRef(delegate);
}
@end