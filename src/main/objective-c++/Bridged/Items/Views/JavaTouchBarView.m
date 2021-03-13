/*
 * JTouchBar
 *
 * Copyright (c) 2021 thizzer.com
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 *
 * @author  	C. Klein
 */

#import "JavaTouchBarView.h"


@implementation JavaTouchBarView {}

- (NSView *)createOrUpdateView:(NSView *)view env:(JNIEnv *)env jTouchBarView:(jobject)jTouchBarView {
    [NSException raise:NSInternalInconsistencyException format:@"Must use a subclass"];
    return nil;
}

- (void)setJavaRepr:(jobject)javarepr {
    _javaRepr = javarepr;
}

@end