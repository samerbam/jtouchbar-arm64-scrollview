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

#import <Foundation/Foundation.h>
#import <JavaNativeFoundation/JavaNativeFoundation.h>

@class NSView;

@interface JavaTouchBarView: NSObject {
    jobject _javaRepr;
}

- (NSView*) createOrUpdateView:(NSView*)view env:(JNIEnv*)env jTouchBarView:(jobject)jTouchBarView;

- (void) setJavaRepr:(jobject)javarepr;

@end