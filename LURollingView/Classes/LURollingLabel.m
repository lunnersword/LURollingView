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
@property (nonatomic, strong) NSMutableArray<UIView *> *labels;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation LURollingLabel (CircleArray)

- (UIView *)getLabel {
    UIView *label = self.labels.firstObject;
    [self.labels removeObjectAtIndex:0];
    [self.labels addObject:label];
    return label;
}

@end

@implementation LURollingLabel


- (id)init {
    return [self initWithFrame:CGRectMake(0, 0, 0, 0)];
}
- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:CGRectMake(0, 0, 0, 0) rollModel:LURollingLabelRollModeAlways direction:LURollingLabelRollDiretionHorizontal customClass:[UILabel class]];
}
- (id)initWithFrame:(CGRect)frame rollModel:(LURollingLabelRollMode)rollModel direction:(LURollingLabelRollDiretion)direction customClass:(__unsafe_unretained Class)customClass {
    self = [super initWithFrame:frame];
    if (self) {
        _rollSpeed = 77;
        _gapInterval = 2.0;
        _innerGap = 20.0;
        _edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _rollMode = rollModel;
        _rollDirection = direction;
        _individualViewCustomClass = customClass;
        self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:self.scrollView];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setFrame:(CGRect)frame {
    CGRect bounds = self.bounds;
    [super setFrame:frame];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (bounds.size.width == frame.size.width && bounds.size.height == frame.size.height) {
        return;
    }
    [self updateContents];
}

// MARK: - Animation start, stop, suspend, resume, isRolling
- (void)start {
    
    if (self.needRolling) {
        self.scrollView.scrollEnabled = NO;
        __weak typeof (self) weakSelf = self;
        [self.labels enumerateObjectsUsingBlock:^(UIView *label, NSUInteger index, BOOL *stop) {
            [label.layer removeAllAnimations];
            [weakSelf addAnimationToLabel:label];
        }];
    }
}





- (void)stop {
    [self.labels enumerateObjectsUsingBlock:^(UIView *label, NSUInteger index, BOOL *stop) {
        [label.layer removeAllAnimations];
    }];
    self.scrollView.scrollEnabled = YES;
}

- (void)suspend {
    [self.labels enumerateObjectsUsingBlock:^(UIView *label, NSUInteger index, BOOL *stop) {
        CFTimeInterval pausedTime = [label.layer convertTime:CACurrentMediaTime() fromLayer:nil];
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
    [self.labels enumerateObjectsUsingBlock:^(UIView *label, NSUInteger index, BOOL *stop) {
        CFTimeInterval pausedTime = [label.layer timeOffset];
        label.layer.speed = 1.0;
        label.layer.timeOffset = 0.0;
        label.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [label.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        label.layer.beginTime = timeSincePause;
    }];
    
}

- (BOOL)isRolling {
    BOOL __block isRolling = NO;
    [self.labels enumerateObjectsUsingBlock:^(UIView *label, NSUInteger index, BOOL *stop) {
        if ([label.layer animationForKey:@"rolling"] && label.layer.speed != 0.0) {
            isRolling = YES;
        }
    }];
    return isRolling;
}

- (BOOL)needRolling {
    if (self.rollingAnyway) {
        return YES;
    }
    if (self.rollDirection == LURollingLabelRollDiretionHorizontal) {
        NSArray<NSValue *> *widths = [self getLabelOriginXsAndWidths];
        if (widths && widths.count > 0) {
            CGPoint point =  [(NSValue *)widths.lastObject CGPointValue];
            CGFloat width = point.x + point.y;
            if (width > self.frame.size.width) {
                for (NSValue *value in widths) {
                    point = [value CGPointValue];
                    if (width - point.y + self.innerGap < self.frame.size.width) {
                        return NO;
                    }
                }
                return YES;
            }
        }
        
    } else {
        NSArray<NSValue *> *heights = [self getLabelOriginYsAndHeights];
        if (heights && heights.count > 0) {
            CGPoint point = [(NSValue *)heights.lastObject CGPointValue];
            CGFloat height = point.x + point.y;
            if (height > self.frame.size.height) {
                for (NSValue *value in heights) {
                    point = [value CGPointValue];
                    if (height - point.y + self.innerGap < self.frame.size.height) {
                        return NO;
                    }
                }
                return YES;
            }
        }
    }
    return NO;
    
}

// MARK: - Create Animation

- (void)addAnimationToLabel:(UILabel *)label {
    if (self.rollDirection == LURollingLabelRollDiretionHorizontal) {
        if (self.rollMode == LURollingLabelRollModeAlways) {
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
            
            
        } else if (self.rollMode == LURollingLabelRollModeGap) {
            CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            CGFloat prefix = label.frame.origin.x;
            CGFloat width = label.frame.size.width;
            CGPoint lastPoint = [(NSValue *)[self getLabelOriginXsAndWidths].lastObject CGPointValue];
            CGFloat suffix = lastPoint.x + lastPoint.y - prefix - width;
            CGFloat length = prefix + width + suffix + self.innerGap;
            NSTimeInterval moveDuration = length / self.rollSpeed;
            NSTimeInterval startMoveTime = (_gapInterval/(_gapInterval + moveDuration));
            NSTimeInterval blinkTime = startMoveTime + (prefix + width)/ length * moveDuration / (_gapInterval + moveDuration);
            frameAnimation.keyTimes = @[@0.0, @(startMoveTime), @(blinkTime), @(blinkTime), @1.0];
            
            frameAnimation.duration = _gapInterval + moveDuration;
            frameAnimation.values = @[@0.0, @0.0, @(-prefix - width), @(suffix + self.innerGap), @0.0];
            frameAnimation.repeatCount = self.repeatCount == 0 ? NSUIntegerMax : self.repeatCount;
            frameAnimation.calculationMode = kCAAnimationLinear;
            frameAnimation.fillMode = kCAFillModeBackwards;
            [label.layer addAnimation:frameAnimation forKey:@"rolling"];
        } else if (self.rollMode == LURollingLabelRollModeGapIndividually) {
            [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                CAKeyframeAnimation *frameAnimation = [self getAnimationForModel:self.rollMode direction:self.rollDirection];
                [label.layer addAnimation:frameAnimation forKey:@"rolling"];
            } completion:nil];
            
        }
        
    } else if (self.rollDirection == LURollingLabelRollDiretionVertical) {
        switch (self.rollMode) {
            case LURollingLabelRollModeGapIndividually: {
                //                [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                CAKeyframeAnimation *frameAnimation = [self getAnimationForModel:self.rollMode direction:self.rollDirection];
                [label.layer addAnimation:frameAnimation forKey:@"rolling"];
                //                } completion:nil];
                break;
            }
            case LURollingLabelRollModeGap: {
                CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
                CGFloat prefix = label.frame.origin.y;
                CGFloat width = label.frame.size.height;
                CGPoint lastPoint = [(NSValue *)[self getLabelOriginYsAndHeights].lastObject CGPointValue];
                CGFloat suffix = lastPoint.x + lastPoint.y - prefix - width;
                CGFloat length = prefix + width + suffix + self.innerGap;
                NSTimeInterval moveDuration = length / self.rollSpeed;
                NSTimeInterval startMoveTime = (_gapInterval/(_gapInterval + moveDuration));
                NSTimeInterval blinkTime = startMoveTime + (prefix + width)/ length * moveDuration / (_gapInterval + moveDuration);
                frameAnimation.keyTimes = @[@0.0, @(startMoveTime), @(blinkTime), @(blinkTime), @1.0];
                
                frameAnimation.duration = _gapInterval + moveDuration;
                frameAnimation.values = @[@0.0, @0.0, @(-prefix - width), @(suffix + self.innerGap), @0.0];
                frameAnimation.repeatCount = self.repeatCount == 0 ? NSUIntegerMax : self.repeatCount;
                frameAnimation.calculationMode = kCAAnimationLinear;
                frameAnimation.fillMode = kCAFillModeBackwards;
                [label.layer addAnimation:frameAnimation forKey:@"rolling"];
                
                break;
            }
            case LURollingLabelRollModeAlways: {
                CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
                CGFloat prefix = label.frame.origin.y;
                CGFloat height = label.frame.size.height;
                CGPoint lastPoint = [(NSValue *)[self getLabelOriginYsAndHeights].lastObject CGPointValue];
                CGFloat suffix = lastPoint.x + lastPoint.y - prefix - height;
                CGFloat length = prefix + height + suffix + self.innerGap;
                frameAnimation.keyTimes = @[@0.0, @((prefix + height)/ length), @((prefix + height)/ length), @1.0];
                frameAnimation.duration = length / self.rollSpeed;
                frameAnimation.values = @[@0.0, @(-prefix - height), @(suffix + self.innerGap), @0.0];
                frameAnimation.repeatCount = self.repeatCount == 0 ? NSUIntegerMax : self.repeatCount;
                frameAnimation.calculationMode = kCAAnimationLinear;
                frameAnimation.fillMode = kCAFillModeBackwards;
                [label.layer addAnimation:frameAnimation forKey:@"rolling"];
                break;
            }
            default:
                break;
        }
        
    }
    
}

- (CAKeyframeAnimation *)getAnimationForModel:(LURollingLabelRollMode)mode direction:(LURollingLabelRollDiretion)direction {
    CAKeyframeAnimation *frameAnimation = nil;
    if (direction == LURollingLabelRollDiretionHorizontal) {
        switch (mode) {
            case LURollingLabelRollModeGapIndividually: {
                frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
                
                NSArray<NSValue *> *widths = [self getLabelOriginXsAndWidths];
                CGPoint lastPoint = [(NSValue *)widths.lastObject CGPointValue];
                
                CGFloat length = lastPoint.x + lastPoint.y + [self innerGapIndividuallyForView:nil widthOrHeight:lastPoint.y] + self.scrollView.frame.size.width;
                NSTimeInterval moveDuration = length / self.rollSpeed;
                NSTimeInterval totalDuration = moveDuration + self.gapInterval * widths.count;
                NSMutableArray *keyTimes = [NSMutableArray array];
                NSMutableArray *values = [NSMutableArray array];
                CGFloat moved;
                NSTimeInterval timeMoved = 0.0;
                for (int i = 0; i < widths.count; i++) {
                    CGPoint point = [(NSValue *)widths[i] CGPointValue];
                    CGFloat width;
                    
                    CGFloat individualGap = [self innerGapIndividuallyForView:nil widthOrHeight:point.y];
                    if (i == 0) {
                        width = point.x + point.y + individualGap;
                    } else {
                        width = point.y + individualGap;
                    }
                    
                    [keyTimes addObject:@(timeMoved)];
                    [values addObject:@(-moved)];
                    
                    NSTimeInterval gapTime = self.gapInterval/totalDuration;
                    timeMoved += gapTime;
                    [keyTimes addObject:@(timeMoved)];
                    [values addObject:@(-moved)];
                    
                    timeMoved += width/length * moveDuration / totalDuration;
                    [keyTimes addObject:@(timeMoved)];
                    moved += width;
                    [values addObject:@(-moved)];
                }
                if (keyTimes.lastObject) {
                    [keyTimes addObject:@(timeMoved)];
                    [values addObject:@(self.scrollView.frame.size.width)];
                    
                    [keyTimes addObject:@(1.0)];
                    [values addObject:@(0.0)];
                }
                
                
                frameAnimation.keyTimes = keyTimes;
                
                frameAnimation.duration = totalDuration;//_gapInterval + moveDuration;
                frameAnimation.values = values;
                frameAnimation.repeatCount = self.repeatCount == 0 ? NSUIntegerMax : self.repeatCount;
                frameAnimation.calculationMode = kCAAnimationLinear;
                frameAnimation.fillMode = kCAFillModeBackwards;
                
                break;
            }
            default:
                break;
        }
        
    } else if (direction == LURollingLabelRollDiretionVertical) {
        switch (mode) {
            case LURollingLabelRollModeGapIndividually: {
                frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
                
                NSArray<NSValue *> *widths = [self getLabelOriginYsAndHeights];
                CGPoint lastPoint = [(NSValue *)widths.lastObject CGPointValue];
                
                CGFloat length = lastPoint.x + lastPoint.y + [self innerGapIndividuallyForView:nil widthOrHeight:lastPoint.y] + self.scrollView.frame.size.height;
                NSTimeInterval moveDuration = length / self.rollSpeed;
                NSTimeInterval totalDuration = moveDuration + self.gapInterval * widths.count;
                NSMutableArray *keyTimes = [NSMutableArray array];
                NSMutableArray *values = [NSMutableArray array];
                CGFloat moved;
                NSTimeInterval timeMoved = 0.0;
                for (int i = 0; i < widths.count; i++) {
                    CGPoint point = [(NSValue *)widths[i] CGPointValue];
                    CGFloat width;
                    
                    CGFloat individualGap = [self innerGapIndividuallyForView:nil widthOrHeight:point.y];//deltaY > 0 ? deltaY : 0;
                    if (i == 0) {
                        
                        width = point.x + point.y + individualGap;
                    } else {
                        width = point.y + individualGap;
                    }
                    
                    [keyTimes addObject:@(timeMoved)];
                    [values addObject:@(-moved)];
                    
                    NSTimeInterval gapTime = self.gapInterval/totalDuration;
                    timeMoved += gapTime;
                    [keyTimes addObject:@(timeMoved)];
                    [values addObject:@(-moved)];
                    
                    timeMoved += width/length * moveDuration / totalDuration;
                    [keyTimes addObject:@(timeMoved)];
                    moved += width;
                    [values addObject:@(-moved)];
                }
                if (keyTimes.lastObject) {
                    [keyTimes addObject:@(timeMoved)];
                    [values addObject:@(self.scrollView.frame.size.height)];
                    
                    
                    [keyTimes addObject:@(1.0)];
                    [values addObject:@(0.0)];
                }
                
                
                frameAnimation.keyTimes = keyTimes;
                
                frameAnimation.duration = totalDuration;//_gapInterval + moveDuration;
                frameAnimation.values = values;
                frameAnimation.repeatCount = self.repeatCount == 0 ? NSUIntegerMax : self.repeatCount;
                frameAnimation.calculationMode = kCAAnimationLinear;
                frameAnimation.fillMode = kCAFillModeBackwards;
                
                
                break;
            }
            default:
                break;
        }
    }
    return frameAnimation;
}

// MARK: - Get origin.x origin.y width height gaps

- (NSArray<NSValue *> *)getLabelOriginYsAndHeights {
    NSMutableArray *array = [NSMutableArray array];
    [self.labels enumerateObjectsUsingBlock:^(UIView *label, NSUInteger index, BOOL *stop) {
        CGPoint point;
        point.x = label.frame.origin.y;
        point.y = label.frame.size.height;
        NSValue *value = [NSValue valueWithCGPoint:point];
        [array addObject:value];
    }];
    return array.copy;
}


- (NSArray<NSValue *> *)getLabelOriginXsAndWidths {
    NSMutableArray *array = [NSMutableArray array];
    [self.labels enumerateObjectsUsingBlock:^(UIView *label, NSUInteger index, BOOL *stop) {
        CGPoint point;
        point.x = label.frame.origin.x;
        point.y = label.frame.size.width;
        NSValue *value = [NSValue valueWithCGPoint:point];
        [array addObject:value];
    }];
    return array.copy;
}

- (CGFloat)innerGapIndividuallyForView:(UIView *)view widthOrHeight:(CGFloat)widthOrHeight {
    CGFloat innerGap = -1;
    if (self.rollMode == LURollingLabelRollModeGapIndividually) {
        if (self.rollDirection == LURollingLabelRollDiretionHorizontal) {
            CGFloat width = view ? view.frame.size.width : widthOrHeight;
            CGFloat deltaX = self.scrollView.frame.size.width - width;
            innerGap = deltaX > 0 ? deltaX : 0;//self.scrollView.frame.size.width;
        } else if (self.rollDirection == LURollingLabelRollDiretionVertical) {
            CGFloat height = view ? view.frame.size.height : widthOrHeight;
            CGFloat deltaY = self.scrollView.frame.size.height - height;
            innerGap = deltaY > 0 ? deltaY : 0;//self.scrollView.frame.size.height;
        }
    }
    return innerGap;
    
}

- (void)forIndividualViewTapped:(UIGestureRecognizer *)gesture {
    for (UIView *view in self.scrollView.subviews) {
        CALayer *presentationlayer = [view.layer presentationLayer];
        if (CGRectContainsPoint(presentationlayer.frame, [gesture locationInView:self.scrollView])) {
            if (self.individualTapBlock) {
                self.individualTapBlock(view.tag, view);
            }
        }
    }
}

// MARK: - Create individual views

- (void)updateContents {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.labels removeAllObjects];
    if (self.rollDirection == LURollingLabelRollDiretionHorizontal) {
        CGFloat __block offsetx = self.edgeInsets.left;
        if (_attributedTexts && _attributedTexts.count > 0) {
            __weak typeof(self) weakSelf = self;
            [_attributedTexts enumerateObjectsUsingBlock:^(NSAttributedString *_Nonnull text, NSUInteger index, BOOL *stop) {
                UIView *view;
                if (self.individualViewInitialBlock) {
                    view = self.individualViewInitialBlock(index, nil, text);
                    CGRect frame = view.frame;
                    frame.origin = CGPointMake(offsetx, weakSelf.edgeInsets.top);
                    view.frame = frame;

                } else {
                    UILabel *label = [weakSelf getLabelWithText:nil attributedText:text];
                    label.frame = CGRectMake(offsetx, weakSelf.edgeInsets.top, 0, 0);
                    label.tag = index;
                    [label sizeToFit];
                    view = label;
                }
                
                //                [weakSelf addTapGestureToView:label];
                [weakSelf.labels addObject:view];
                [weakSelf.scrollView addSubview:view];
                CGFloat individualInnerGap = [self innerGapIndividuallyForView:view widthOrHeight:0];
                offsetx += (individualInnerGap == -1 ? weakSelf.innerGap : individualInnerGap) + view.bounds.size.width;
            }];
        } else {
            __weak typeof (self) weakSelf = self;
            [_texts enumerateObjectsUsingBlock:^(NSString * _Nonnull text, NSUInteger index, BOOL *stop) {
                UIView *view;
                if (self.individualViewInitialBlock) {
                    view = self.individualViewInitialBlock(index, text, nil);
                    CGRect frame = view.frame;
                    frame.origin = CGPointMake(offsetx, weakSelf.edgeInsets.top);
                    view.frame = frame;
                } else {
                    UILabel *label = [weakSelf getLabelWithText:text attributedText:nil];
                    label.frame = CGRectMake(offsetx, weakSelf.edgeInsets.top, 0, 0);
                    [label sizeToFit];
                    label.tag = index;
                    view = label;
                }
                
                //                [weakSelf addTapGestureToView:label];
                [weakSelf.labels addObject:view];
                [weakSelf.scrollView addSubview:view];
                CGFloat individualInnerGap = [self innerGapIndividuallyForView:view widthOrHeight:0];
                offsetx += (individualInnerGap == -1 ? weakSelf.innerGap : individualInnerGap) + view.bounds.size.width;
            }];
        }
        self.scrollView.contentSize = CGSizeMake(offsetx, self.scrollView.frame.size.height);
    } else if (self.rollDirection == LURollingLabelRollDiretionVertical) {
        CGFloat __block offsetY = self.edgeInsets.top;
        if (_attributedTexts && _attributedTexts.count > 0) {
            __weak typeof(self) weakSelf = self;
            [_attributedTexts enumerateObjectsUsingBlock:^(NSAttributedString *_Nonnull text, NSUInteger index, BOOL *stop) {
                UIView *view;
                if (weakSelf.individualViewInitialBlock) {
                    view = weakSelf.individualViewInitialBlock(index, nil, text);
                    CGRect frame = view.frame;
                    frame.origin = CGPointMake(weakSelf.edgeInsets.left, offsetY);
                    view.frame = frame;
                } else {
                    UILabel *label = [weakSelf getLabelWithText:nil attributedText:text];
                    label.frame = CGRectMake(weakSelf.edgeInsets.left, offsetY, 0, 0);
                    [label sizeToFit];
                    label.tag = index;
                    view = label;
                }
                [weakSelf.labels addObject:view];
                [weakSelf.scrollView addSubview:view];
                CGFloat individualInnerGap = [self innerGapIndividuallyForView:view widthOrHeight:0];
                offsetY += (individualInnerGap == -1 ? weakSelf.innerGap : individualInnerGap) + view.bounds.size.height;
            }];
        } else {
            __weak typeof (self) weakSelf = self;
            [_texts enumerateObjectsUsingBlock:^(NSString * _Nonnull text, NSUInteger index, BOOL *stop) {
                
                UIView *view;
                if (weakSelf.individualViewInitialBlock) {
                    view = weakSelf.individualViewInitialBlock(index, text, nil);
                    CGRect frame = view.frame;
                    frame.origin = CGPointMake(weakSelf.edgeInsets.left, offsetY);
                    view.frame = frame;
                } else {
                    UILabel *label = [weakSelf getLabelWithText:text attributedText:nil];
                    label.frame = CGRectMake(weakSelf.edgeInsets.left, offsetY, 0, 0);
                    [label sizeToFit];
                    label.tag = index;
                    view = label;
                }
                
                [weakSelf.labels addObject:view];
                [weakSelf.scrollView addSubview:view];
                CGFloat individualInnerGap = [self innerGapIndividuallyForView:view widthOrHeight:0];
                offsetY += (individualInnerGap == -1 ? weakSelf.innerGap : individualInnerGap) + view.bounds.size.height;
            }];
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, offsetY);
    }
    
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


// MARK: - Properties

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


- (UIFont *)textFont {
    return [UIFont systemFontOfSize:15];
}


- (void)setTexts:(NSArray<NSString *> *)texts {
    _texts = texts;
    [self updateContents];
}

- (void)setAttributedTexts:(NSArray<NSAttributedString *> *)attributedTexts {
    _attributedTexts = attributedTexts;
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
        if (self.individualTapBlock) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forIndividualViewTapped:)];
            [self addGestureRecognizer:tap];
        } else {
            [self addGestureRecognizer:self.tap];
            [self addGestureRecognizer:self.doubleTap];
        }
    } else {
        [self removeGestureRecognizer:self.tap];
        [self removeGestureRecognizer:self.doubleTap];
    }
}

@end
