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
//    NSLog(@"topLeftControl  -> %@\n topRightControl  -> %@\n bottomRightControl  -> %@\n bottomLeftControl  -> %@\n ", NSStringFromCGPoint(self.topLeftControl.center), NSStringFromCGPoint(self.topRightControl.center), NSStringFromCGPoint(self.bottomRightControl.center), NSStringFromCGPoint(self.bottomLeftControl.center));
    
    AGQuad quad = AGQuadMakeWithCGPoints(self.topLeftControl.center,
                                         self.topRightControl.center,
                                         self.bottomRightControl.center,
                                         self.bottomLeftControl.center);
    
    if(AGQuadIsValid(quad))
    {
        self.imageView.layer.quadrilateral = quad;
    }
//    self.maskView.layer.shadowPath = [UIBezierPath bezierPathWithAGQuad:quad].CGPath;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = _image;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self createAndApplyQuad];
    [self performSelector:@selector(createAndApplyQuad) withObject:nil afterDelay:0.1];
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
- (IBAction)doneTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)freezeTapped:(id)sender
{
    NSMutableDictionary *dicToSave = [[NSMutableDictionary alloc] init];
    
    [dicToSave setObject:CFBridgingRelease(CGRectCreateDictionaryRepresentation(self.topLeftControl.frame)) forKey:@"topLeftControl"];
    [dicToSave setObject:CFBridgingRelease(CGRectCreateDictionaryRepresentation(self.topRightControl.frame)) forKey:@"topRightControl"];
    [dicToSave setObject:CFBridgingRelease(CGRectCreateDictionaryRepresentation(self.bottomLeftControl.frame)) forKey:@"bottomLeftControl"];
    [dicToSave setObject:CFBridgingRelease(CGRectCreateDictionaryRepresentation(self.bottomRightControl.frame)) forKey:@"bottomRightControl"];
    
}

- (IBAction)changeCarpetTapped:(id)sender
{
    
}

- (IBAction)selectBackgroundTapped:(id)sender
{
    
}


@end
