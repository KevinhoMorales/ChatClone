//
//  LocationPinView.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Pin origin center.
 *
 *  @note Use this to shift pin view on X point.
 */
extern const CGFloat QMLocationPinViewOriginPinCenter;

@interface LocationPinView : UIView

/**
 *  Whether pin is rised or not.
 *
 *  @note Setting this property to a positive value will perform pin set with no animation.
 */
@property (assign, nonatomic) BOOL pinRaised;

/**
 *  Set pin rised.
 *
 *  @param pinRaised whether pin should be rised or not
 *  @param animated  whether rise should be performed with animation
 */
- (void)setPinRaised:(BOOL)pinRaised animated:(BOOL)animated;

@end
