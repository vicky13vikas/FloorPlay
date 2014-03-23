//
//  AGQuadControlViewController.m
//  FloorPlay
//
//  Created by Vikas Kumar on 23/03/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "AGQuadControlViewController.h"
#import "AGQuad.h"
//#import "easing.h"
#import "CALayer+AGQuad.h"
#import "UIView+FrameExtra.h"
#import "UIBezierPath+AGQuad.h"

@interface AGQuadControlViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *topLeftControl;
@property (nonatomic, strong) IBOutlet UIView *topRightControl;
@property (nonatomic, strong) IBOutlet UIView *bottomLeftControl;
@property (nonatomic, strong) IBOutlet UIView *bottomRightControl;
@property (nonatomic, strong) IBOutlet UIView *maskView;
@property (nonatomic, strong) IBOutlet UISwitch *switchControl;

@end

@implementation AGQuadControlViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    [self createAndApplyQuad];
}

- (void)createAndApplyQuad
{
    NSLog(@"topLeftControl  -> %@\n topRightControl  -> %@\n bottomRightControl  -> %@\n bottomLeftControl  -> %@\n ", NSStringFromCGPoint(self.topLeftControl.center), NSStringFromCGPoint(self.topRightControl.center), NSStringFromCGPoint(self.bottomRightControl.center), NSStringFromCGPoint(self.bottomLeftControl.center));
    
    AGQuad quad = AGQuadMakeWithCGPoints(self.topLeftControl.center,
                                         self.topRightControl.center,
                                         self.bottomRightControl.center,
                                         self.bottomLeftControl.center);
    
    if(AGQuadIsValid(quad))
    {
        self.imageView.layer.quadrilateral = quad;
    }
    self.maskView.layer.shadowPath = [UIBezierPath bezierPathWithAGQuad:quad].CGPath;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createAndApplyQuad];
}

- (IBAction)panGestureChanged:(UIPanGestureRecognizer *)recognizer
{
    UIImageView *view = (UIImageView *)[recognizer view];
    
    CGPoint translation = [recognizer translationInView:self.view];
    view.centerX += translation.x;
    view.centerY += translation.y;
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    view.highlighted = recognizer.state == UIGestureRecognizerStateChanged;
    
    [self createAndApplyQuad];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
