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

typedef void (^individualViewTapCallback)(NSInteger index, UIView *_Nonnull view);
typedef UILabel * _Nonnull (^customIndividualViewInitCallback)(NSInteger index, NSString * _Nullable text, NSAttributedString * _Nullable attributedText);

@interface LURollingLabel : UIView

@property (nonatomic, strong, nullable) NSArray<NSString *> *texts;
@property (nonatomic, strong, nullable) NSArray<NSAttributedString *> *attributedTexts;
@property (nonatomic) CGFloat rollSpeed; //default is 77;
@property (nonatomic) NSTimeInterval gapInterval; //default is 2s
@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic) CGFloat innerGap;
@property (nonatomic) NSUInteger repeatCount;
@property (nonatomic) BOOL rollingAnyway;
@property (nonatomic) BOOL respondsToTap;
@property (nonatomic) LURollingLabelRollMode rollMode;
@property (nonatomic) LURollingLabelRollDiretion rollDirection;
@property (nonatomic, copy, nullable) individualViewTapCallback individualTapBlock;
@property (nonatomic, copy, nullable) customIndividualViewInitCallback individualViewInitialBlock;
@property (nonatomic, readonly, nullable) Class individualViewCustomClass;

@property (nonatomic, readonly) BOOL isRolling;

- (_Nullable id)initWithFrame:(CGRect)frame rollModel:(LURollingLabelRollMode)rollModel direction:(LURollingLabelRollDiretion)direction customClass:(Class _Nullable)customClass;

- (void)start;

@end
