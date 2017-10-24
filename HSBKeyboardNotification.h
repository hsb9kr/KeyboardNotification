//
//  HSBKeyboardFrame.h
//  HSBKeyboardFrameObjc
//
//  Created by hsb9kr on 2017. 10. 24..
//  Copyright © 2017년 hsb9kr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSBKeyboardNotificationDelegate;

@interface HSBKeyboardNotification : NSObject
@property(weak, nonatomic) id<HSBKeyboardNotificationDelegate> delegate;
+ (instancetype)sharedInstance;
@end

@protocol HSBKeyboardNotificationDelegate <NSObject>
- (void)hsbKeyboardNotificationShow:(CGSize)keyboardSize;
- (void)hsbKeyboardNotificationHide:(CGSize)keyboardSize;
- (void)hsbKeyboardNotificationChange:(CGSize)keyboardSize;

@end
