//
//  HSBKeyboardFrame.m
//  HSBKeyboardFrameObjc
//
//  Created by hsb9kr on 2017. 10. 24..
//  Copyright © 2017년 hsb9kr. All rights reserved.
//

#import "HSBKeyboardNotification.h"

@interface HSBKeyboardNotification() {
    BOOL _isKeyboardHidden;
    struct {
        unsigned int showFlag   :1;
        unsigned int hideFlag   :1;
        unsigned int changeFlag :1;
    }_delegateFlags;
}
@end

@implementation HSBKeyboardNotification

+ (instancetype)sharedInstance {
    static HSBKeyboardNotification *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HSBKeyboardNotification alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registKeyboardNotification];
        _isKeyboardHidden = YES;
    }
    return self;
}

- (void)dealloc {
    [self removeKeyboardNotification];
}

- (void)setDelegate:(id<HSBKeyboardNotificationDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.showFlag = [_delegate respondsToSelector:@selector(hsbKeyboardNotificationShow:)];
    _delegateFlags.hideFlag = [_delegate respondsToSelector:@selector(hsbKeyboardNotificationHide:)];
    _delegateFlags.changeFlag = [_delegate respondsToSelector:@selector(hsbKeyboardNotificationChange:)];
}

#pragma mark <Private>

- (void)registKeyboardNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeKeyboardNotification {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)willShow:(NSNotification *)notification {
    if (!_isKeyboardHidden) return;
    _isKeyboardHidden = NO;
    [self keyboardSize:notification animations:^(CGSize size) {
        if (_delegateFlags.showFlag) [_delegate hsbKeyboardNotificationShow:size];
    }];
}


- (void)willHide:(NSNotification *)notification {
    if (_isKeyboardHidden) return;
    _isKeyboardHidden = YES;
    [self keyboardSize:notification animations:^(CGSize size) {
        if (_delegateFlags.hideFlag) [_delegate hsbKeyboardNotificationHide:size];
    }];
}

- (void)willChange:(NSNotification *)notification {
    if (_isKeyboardHidden) return;
    CGSize size;
    NSTimeInterval duration;
    UIViewAnimationOptions options;
    [self keyboardSize:notification size:&size duration:&duration options:&options];
    if (_delegateFlags.changeFlag) [_delegate hsbKeyboardNotificationChange:size];
}

- (void)keyboardSize:(NSNotification *)notification size:(CGSize *)size duration:(NSTimeInterval *)duration options:(UIViewAnimationOptions *)options {
    
    NSDictionary *userInfo = notification.userInfo;
    
    /*
     * Get Keyboard Size
     */
    NSValue *keyboardEndValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    *size = keyboardEndValue.CGRectValue.size;
    
    /*
     * Get Keyboard Animation Duration
     */
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    *duration = durationValue.doubleValue;
    
    /*
     * Get Keyboard Animation
     */
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    *options = animationCurve<<16;
    
    NSLog(@"set duration: %f", *duration);
}

- (void)keyboardSize:(NSNotification *)notification animations: (void (^)(CGSize size))animations {
    CGSize size;
    NSTimeInterval duration;
    UIViewAnimationOptions options;
    [self keyboardSize:notification size:&size duration:&duration options:&options];
    
    NSLog(@"duration: %f", duration);
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        if (animations) {
            animations(size);
        }
    } completion:nil];
}



@end
