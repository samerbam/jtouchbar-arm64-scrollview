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
#import "JavaGroupTouchBarItem.h"

#include <string>

#import "JNIContext.h"
#import "JTouchBarUtils.h"

#import "JavaTouchBar.h"

@interface JavaGroupTouchBarItem() {
    NSGroupTouchBarItem *_touchBarItem;
    
    JavaTouchBar *_jTouchBar;
    NSTouchBar *_groupTouchBar;
}

@end

@implementation JavaGroupTouchBarItem

-(NSTouchBarItem*) getTouchBarItem {
    if(self.javaRepr == NULL) {
        return nil;
    }
    
    if(_touchBarItem == nil) {
        JNIEnv *env; JNIContext context(&env);
        
        NSString *identifier = [super getIdentifier:env reload:TRUE];
        
        jobject groupTouchBar = JNIContext::CallObjectMethod(env, self.javaRepr, "getGroupTouchBar", "com/thizzer/jtouchbar/JTouchBar");
        
        _jTouchBar = [[JavaTouchBar alloc] init];
        [_jTouchBar setJavaRepr:groupTouchBar];
        
        _touchBarItem = [[NSGroupTouchBarItem alloc] initWithIdentifier:identifier];
        [_touchBarItem setGroupTouchBar:[_jTouchBar createNSTouchBar]];
        [[_touchBarItem groupTouchBar] setDelegate:self];

        env->DeleteLocalRef(groupTouchBar);
    }
    
    return _touchBarItem;
}

-(NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier {
    return [JTouchBarUtils touchBar:touchBar makeItemForIdentifier:identifier usingJavaTouchBar:_jTouchBar];
}

@end
