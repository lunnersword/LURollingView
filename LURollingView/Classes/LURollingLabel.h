//
//  LURollingLabel.h
//  CoreAnimationTest
//
//  Created by 永超 沈 on 5/13/16.
//  Copyright © 2016 永超 沈. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LURollingLabelRollMode) {
    LURollingLabelRollModeAlways,
    LURollingLabelRollModeGap,
    LURollingLabelRollModeGapIndividually
};

typedef NS_ENUM(NSInteger, LURollingLabelRollDiretion) {
    LURollingLabelRollDiretionHorizontal,
    LURollingLabelRollDiretionVertical
};

typedef void (^individualViewTapCallback)(NSInteger index, UIView *view);

@interface LURollingLabel : UIView

@property (nonatomic, strong) NSArray<NSString *> *texts;
@property (nonatomic, strong) NSArray<NSAttributedString *> *attributedTexts;
@property (nonatomic, assign) CGFloat rollSpeed; //default is 77;
@property (nonatomic, assign) NSTimeInterval gapInterval; //default is 2s
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) CGFloat innerGap;
@property (nonatomic, assign) NSUInteger repeatCount;
@property (nonatomic, assign) BOOL rollingAnyway;
@property (nonatomic, assign) BOOL respondsToTap;
@property (nonatomic, assign) LURollingLabelRollMode rollMode;
@property (nonatomic, assign) LURollingLabelRollDiretion rollDirection;
@property (nonatomic, copy, nonnull) individualViewTapCallback individualTapBlock;

@property (nonatomic, readonly) BOOL isRolling;

- (id)initWithFrame:(CGRect)frame rollModel:(LURollingLabelRollMode)rollModel direction:(LURollingLabelRollDiretion)direction;

- (void)start;

@end
