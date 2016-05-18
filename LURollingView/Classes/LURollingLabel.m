//
//  LURollingLabel.m
//  CoreAnimationTest
//
//  Created by 永超 沈 on 5/13/16.
//  Copyright © 2016 永超 沈. All rights reserved.
//

#import "LURollingLabel.h"

@interface LURollingLabel ()

@property (nonatomic, readonly) BOOL needRolling;
@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation LURollingLabel (CircleArray)

- (UILabel *)getLabel {
    UILabel *label = self.labels.firstObject;
    [self.labels removeObjectAtIndex:0];
    [self.labels addObject:label];
    return label;
}

@end

@implementation LURollingLabel

@synthesize textColor = _textColor;
@synthesize textFont = _textFont;

- (id)init {
    return [self initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _rollSpeed = 77;
        _innerGap = 20.0;
        _edgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:self.scrollView];
        [self addGestureRecognizer:self.tap];
        [self addGestureRecognizer:self.doubleTap];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)start {
    
    if (self.needRolling) {
        self.scrollView.scrollEnabled = NO;
        __weak typeof (self) weakSelf = self;
        [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            [label.layer removeAllAnimations];
            [weakSelf addAnimationToLabel:label];
        }];
    }
}





- (void)stop {
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        [label.layer removeAllAnimations];
    }];
    self.scrollView.scrollEnabled = YES;
}

- (void)suspend {
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        CFTimeInterval pausedTime = [label.layer convertTime:CACurrentMediaTime() toLayer:nil];
        label.layer.speed = 0.0;
        label.layer.timeOffset = pausedTime;
//        CGPoint position = ((CALayer *)label.layer.presentationLayer).position;
//        label.layer.position = position;
    }];
    //self.scrollView.scrollEnabled = YES;
}

- (void)startRolling:(UIGestureRecognizer *)swipe {
    [self resume];
}

- (void)resume {
    self.scrollView.scrollEnabled = NO;
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        CFTimeInterval pausedTime = [label.layer timeOffset];
        label.layer.speed = 1.0;
        label.layer.timeOffset = 0.0;
        label.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [label.layer convertTime:CACurrentMediaTime() toLayer:nil] - pausedTime;
        label.layer.beginTime = timeSincePause;
    }];
    
}

- (BOOL)isRolling {
    BOOL __block isRolling = NO;
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        if ([label.layer animationForKey:@"rolling"] && label.layer.speed != 0.0) {
            isRolling = YES;
        }
    }];
    return isRolling;
}

- (void)addAnimationToLabel:(UILabel *)label {
    CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat prefix = label.frame.origin.x;
    CGFloat width = label.frame.size.width;
    CGPoint lastPoint = [(NSValue *)[self getLabelOriginXsAndWidths].lastObject CGPointValue];
    CGFloat suffix = lastPoint.x + lastPoint.y - prefix - width;
    CGFloat length = prefix + width + suffix + self.innerGap;
    frameAnimation.keyTimes = @[@0.0, @((prefix + width)/ length), @((prefix + width)/ length), @1.0];
    frameAnimation.duration = length / self.rollSpeed;
    frameAnimation.values = @[@0.0, @(-prefix - width), @(suffix + self.innerGap), @0.0];
    frameAnimation.repeatCount = self.repeatCount == 0 ? NSUIntegerMax : self.repeatCount;
    frameAnimation.calculationMode = kCAAnimationLinear;
    frameAnimation.fillMode = kCAFillModeBackwards;
    [label.layer addAnimation:frameAnimation forKey:@"rolling"];
    
}

- (BOOL)needRolling {
    NSArray<NSValue *> *widths = [self getLabelOriginXsAndWidths];
    if (widths && widths.count > 0) {
        CGPoint point =  [(NSValue *)widths.lastObject CGPointValue];
        CGFloat width = point.x + point.y;
        if (width > self.frame.size.width) {
            if (self.rollingAnyway) {
                return YES;
            }
            for (NSValue *value in widths) {
                point = [value CGPointValue];
                if (width - point.y + self.innerGap < self.frame.size.width) {
                    return NO;
                }
            }
            return YES;
        }
    }
    return NO;
}


- (NSArray<NSValue *> *)getLabelOriginXsAndWidths {
    NSMutableArray *array = [NSMutableArray array];
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        CGPoint point;
        point.x = label.frame.origin.x;
        point.y = label.frame.size.width;
        NSValue *value = [NSValue valueWithCGPoint:point];
        [array addObject:value];
    }];
    return array.copy;
}

- (void)updateContents {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.labels removeAllObjects];
    CGFloat __block offsetx = 0;
    if (self.attributedTexts && self.attributedTexts.count > 0) {
        __weak typeof(self) weakSelf = self;
        [self.attributedTexts enumerateObjectsUsingBlock:^(NSAttributedString *_Nonnull text, NSUInteger index, BOOL *stop) {
            UILabel *label = [weakSelf getLabelWithText:nil attributedText:text];
            label.frame = CGRectMake(offsetx, weakSelf.edgeInsets.top, 0, 0);
            [label sizeToFit];
            [weakSelf.labels addObject:label];
            [weakSelf.scrollView addSubview:label];
            offsetx += weakSelf.innerGap + label.bounds.size.width;
        }];
    } else {
        __weak typeof (self) weakSelf = self;
        [self.texts enumerateObjectsUsingBlock:^(NSString * _Nonnull text, NSUInteger index, BOOL *stop) {
            UILabel *label = [weakSelf getLabelWithText:text attributedText:nil];
            label.frame = CGRectMake(offsetx, weakSelf.edgeInsets.top, 0, 0);
            [label sizeToFit];
            [weakSelf.labels addObject:label];
            [weakSelf.scrollView addSubview:label];
            offsetx += weakSelf.innerGap + label.bounds.size.width;
        }];
    }
    self.scrollView.contentSize = CGSizeMake(offsetx, self.scrollView.frame.size.height);
        
}

- (UILabel *)getLabelWithText:(NSString *)text attributedText:(NSAttributedString *)attrText {
    UILabel *label = [UILabel new];
    if (attrText) {
        label.attributedText = attrText;

    } else {
        label.text = text;
    }
    label.font = self.textFont;
    label.textColor = self.textColor;
    return label;

}

- (void)updateLabelColors {
    __weak typeof (self) weakSelf = self;
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        label.textColor = weakSelf.textColor;
    }];
}

- (void)updateLabelFonts {
    __weak typeof (self) weakSelf = self;
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        label.font = weakSelf.textFont;
    }];
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)];
    }
    return _tap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startRolling:)];
        _doubleTap.numberOfTapsRequired = 2;

    }
    return _doubleTap;
}

- (UIColor *)textColor {
    return [UIColor blackColor];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self updateLabelColors];
}

- (UIFont *)textFont {
    return [UIFont systemFontOfSize:15];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    [self updateLabelFonts];
}

- (void)setTexts:(NSArray<NSString *> *)texts {
    _texts = texts;
    [self updateContents];
}

- (void)setAttributedTexts:(NSArray<NSAttributedString *> *)attributedTexts {
    [self updateContents];
}

- (NSMutableArray<UILabel *> *)labels {
    if (!_labels) {
        _labels = [NSMutableArray array];
    }
    return _labels;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

- (void)setRespondsToTap:(BOOL)respondsToTap {
    _respondsToTap = respondsToTap;
    if (_respondsToTap) {
        self.userInteractionEnabled = YES;
    } else {
        self.userInteractionEnabled = NO;
    }
}

@end
