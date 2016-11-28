//
//  LUColoringBorderView.h
//  Pods
//
//  Created by lunner on 8/7/16.
//
//

#import <UIKit/UIKit.h>

@interface LUColoringBorderView : UIView

@property (nonatomic, strong) NSArray<NSNumber *> *widths;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic) NSTimeInterval duration;

@end
