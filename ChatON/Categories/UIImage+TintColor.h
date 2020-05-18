//
//  UIImage+TintColor.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved
//

#import <UIKit/UIKit.h>

@interface UIImage (TintColor)

- (UIImage *)tintImageWithColor:(UIColor *)maskColor;
- (UIImage *)tintImageWithColor:(UIColor *)maskColor resizableImageWithCapInsets:(UIEdgeInsets)capInsets NS_AVAILABLE_IOS(5_0);

@end
