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

#import "JavaTouchBarScrubber.h"

#import "JNIContext.h"
#import "JTouchBarUtils.h"


@implementation JavaTouchBarScrubber {}

- (NSView*)createOrUpdateView:(NSView *)view env:(JNIEnv *)env jTouchBarView:(jobject)jTouchBarView {
    NSScrubber *scrubber;
    if(view == nil || ![view isKindOfClass:[NSScrubber class]]) {
        scrubber = [[NSScrubber alloc] init];
    } else {
        scrubber = static_cast<NSScrubber*>(view);
    }

    scrubber.delegate = self;
    scrubber.dataSource = self;

    int mode = JNIContext::CallIntMethod(env, jTouchBarView, "getMode"); // NSScrubberModeFree/NSScrubberModeFixed
    scrubber.mode = (NSScrubberMode)mode;
    scrubber.showsArrowButtons = JNIContext::CallBooleanMethod(env, jTouchBarView, "getShowsArrowButtons");

    color_t color = JNIContext::CallColorMethod(env, jTouchBarView, "getBackgroundColor");
    dispatch_async(dispatch_get_main_queue(), ^{
        [scrubber setBackgroundColor:[JTouchBarUtils getNSColor:color]];
    });

    int overlayStyle = JNIContext::CallIntMethod(env, jTouchBarView, "getSelectionOverlayStyle");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(overlayStyle == 1) {
            [scrubber setSelectionOverlayStyle:[NSScrubberSelectionStyle outlineOverlayStyle]];
        }
        else if(overlayStyle == 2) {
            [scrubber setSelectionOverlayStyle:[NSScrubberSelectionStyle roundedBackgroundStyle]];
        }
    });

    int backgroundStyle = JNIContext::CallIntMethod(env, jTouchBarView, "getSelectionOverlayStyle");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(backgroundStyle == 1) {
            [scrubber setSelectionBackgroundStyle:[NSScrubberSelectionStyle outlineOverlayStyle]];
        }
        else if(backgroundStyle == 2) {
            [scrubber setSelectionBackgroundStyle:[NSScrubberSelectionStyle roundedBackgroundStyle]];
        }
    });

    return scrubber;
}

- (void)scrubber:(NSScrubber *)scrubber didSelectItemAtIndex:(NSInteger)selectedIndex {
    if(_javaRepr == nullptr) {
        return;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject touchBarView = JNIContext::CallObjectMethod(env, _javaRepr, "getView", "com/thizzer/jtouchbar/item/view/TouchBarView");
    if(touchBarView == nullptr) {
        return;
    }

    jclass scrubberCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarScrubber");
    if(env->IsInstanceOf(touchBarView, scrubberCls)) {
        jobject actionListener = JNIContext::CallObjectMethod(env, touchBarView, "getActionListener", "com/thizzer/jtouchbar/scrubber/ScrubberActionListener");
        if(actionListener == nullptr) {
            return;
        }

        JNIContext::CallVoidMethod(env, actionListener, "didSelectItemAtIndex", "Lcom/thizzer/jtouchbar/item/view/TouchBarScrubber;J", touchBarView, selectedIndex);
    }

    env->DeleteLocalRef(touchBarView);
}

- (NSInteger) numberOfItemsForScrubber:(NSScrubber *)scrubber {
    if(_javaRepr == nullptr) {
        return 0;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject touchBarView = JNIContext::CallObjectMethod(env, _javaRepr, "getView", "com/thizzer/jtouchbar/item/view/TouchBarView");
    if(touchBarView == nullptr) {
        return 0;
    }

    jclass scrubberCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarScrubber");
    if(env->IsInstanceOf(touchBarView, scrubberCls)) {
        jobject dataSource = JNIContext::CallObjectMethod(env, touchBarView, "getDataSource", "com/thizzer/jtouchbar/scrubber/ScrubberDataSource");
        if(dataSource == nullptr) {
            return 0; // TODO delete local ref
        }

        return JNIContext::CallIntMethod(env, dataSource, "getNumberOfItems", "Lcom/thizzer/jtouchbar/item/view/TouchBarScrubber;", touchBarView);
    }

    env->DeleteLocalRef(touchBarView);

    return 0;
}

- (NSScrubberItemView*) scrubber:(NSScrubber *)scrubber viewForItemAtIndex:(NSInteger)index {
    if(_javaRepr == nullptr) {
        return nil;
    }

    JNIEnv *env; JNIContext context(&env);

    jobject touchBarView = JNIContext::CallObjectMethod(env, _javaRepr, "getView", "com/thizzer/jtouchbar/item/view/TouchBarView");
    if(touchBarView == nullptr) {
        return nil;
    }

    jclass scrubberCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/item/view/TouchBarScrubber");
    if(env->IsInstanceOf(touchBarView, scrubberCls)) {
        jobject dataSource = JNIContext::CallObjectMethod(env, touchBarView, "getDataSource", "com/thizzer/jtouchbar/scrubber/ScrubberDataSource");
        if(dataSource == nullptr) {
            return nil; // TODO delete local ref
        }

        jobject javaScrubberView = JNIContext::CallObjectMethod(env, dataSource, "getViewForIndex", "com/thizzer/jtouchbar/scrubber/view/ScrubberView", "Lcom/thizzer/jtouchbar/item/view/TouchBarScrubber;J", touchBarView, index);
        if(javaScrubberView == nullptr) {
            return nil; // TODO delete local ref
        }

        std::string identifier = JNIContext::CallStringMethod(env, javaScrubberView, "getIdentifier");

        jclass textItemViewCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/scrubber/view/ScrubberTextItemView");
        if(env->IsInstanceOf(javaScrubberView, textItemViewCls)) {
            NSScrubberTextItemView *textItemView = [[NSScrubberTextItemView alloc] init];

            std::string stringValue = JNIContext::CallStringMethod(env, javaScrubberView, "getStringValue");
            [textItemView.textField setStringValue:[NSString stringWithUTF8String:stringValue.c_str()]];

            return textItemView; // TODO delete local ref
        }

        jclass imageItemViewCls = JNIContext::GetOrFindClass(env, "com/thizzer/jtouchbar/scrubber/view/ScrubberImageItemView");
        if(env->IsInstanceOf(javaScrubberView, imageItemViewCls)) {
            NSScrubberImageItemView *imageItemView = [[NSScrubberImageItemView alloc] init];

            image_t image = JNIContext::CallImageMethod(env, javaScrubberView, "getImage");
            NSImage *nsImage = [JTouchBarUtils getNSImage:image];
            if(nsImage != nil) {
                [imageItemView setImage:nsImage];
            }

            NSImageAlignment alignment = (NSImageAlignment)JNIContext::CallIntMethod(env, javaScrubberView, "getAlignment");
            [imageItemView setImageAlignment:alignment];

            return imageItemView; // TODO delete local ref
        }
    }

    env->DeleteLocalRef(touchBarView);

    return nil;
}

@end