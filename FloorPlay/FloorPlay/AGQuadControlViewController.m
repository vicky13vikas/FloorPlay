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

@interface AGQuadControlViewController ()<UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *topLeftControl;
@property (nonatomic, strong) IBOutlet UIView *topRightControl;
@property (nonatomic, strong) IBOutlet UIView *bottomLeftControl;
@property (nonatomic, strong) IBOutlet UIView *bottomRightControl;
@property (nonatomic, strong) IBOutlet UIView *maskView;
@property (nonatomic, strong) IBOutlet UISwitch *switchControl;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (strong, nonatomic) UIImagePickerController *cameraPicker;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


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
    [self performSelector:@selector(loadFreezedImage) withObject:nil afterDelay:0.2];
//  [self performSelector:@selector(createAndApplyQuad) withObject:nil afterDelay:0.2];
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
    
    [[[FloorPlayServices singleton] preferences] setObject:dicToSave forKey:@"FreezedImage"];
    [[[FloorPlayServices singleton] preferences] synchronize];
    
    [[[UIAlertView alloc] initWithTitle:@"Floorplay" message:@"Your transform is saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (IBAction)changeCarpetTapped:(id)sender
{
    
}

- (IBAction)selectBackgroundTapped:(UIButton*)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose existing", nil];
    [actionSheet showFromRect:sender.frame inView:_barView animated:YES];
}

- (IBAction)resetTapped:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Floorplay" message:@"Your transform will be lost" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil] show];
}

-(void)loadFreezedImage
{
    NSMutableDictionary *dicToSave = [[[FloorPlayServices singleton] preferences] objectForKey:@"FreezedImage"];
    
    if(dicToSave)
    {
        NSDictionary *topLeftControl = [dicToSave valueForKey:@"topLeftControl"];
        NSString *topRightControl = [dicToSave valueForKey:@"topRightControl"];
        NSString *bottomLeftControl = [dicToSave valueForKey:@"bottomLeftControl"];
        NSString *bottomRightControl = [dicToSave valueForKey:@"bottomRightControl"];
        
        CGRect topLeftFrame ;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)topLeftControl, &topLeftFrame);
        CGRect topRightFrame ;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)topRightControl, &topRightFrame);
        CGRect bottomLeftFrame ;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)bottomLeftControl, &bottomLeftFrame);
        CGRect bottomRightFrame ;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)bottomRightControl, &bottomRightFrame);
        
        _topLeftControl.frame = topLeftFrame;
        _topRightControl.frame = topRightFrame;
        _bottomLeftControl.frame = bottomLeftFrame;
        _bottomRightControl.frame = bottomRightFrame;
    }
    [self createAndApplyQuad];
}

-(void)resetImage
{
    CGRect topLeftFrame = CGRectMake(38, 83, 46, 46);
    CGRect topRightFrame = CGRectMake(914, 83, 46, 46) ;
    CGRect bottomLeftFrame = CGRectMake(38, 660, 46, 46) ;
    CGRect bottomRightFrame = CGRectMake(914, 660, 46, 46) ;
    _topLeftControl.frame = topLeftFrame;
    _topRightControl.frame = topRightFrame;
    _bottomLeftControl.frame = bottomLeftFrame;
    _bottomRightControl.frame = bottomRightFrame;
    
    [self createAndApplyQuad];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[[FloorPlayServices singleton] preferences] removeObjectForKey:@"FreezedImage"];
            [self resetImage];
            break;
            
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self showCamera];
            break;
        case 1:
            break;
            
        default:
            break;
    }
}

#pragma -mark UIImagePickerController Delegates

- (void)showCamera
{
    if(_cameraPicker == nil)
    {
        _cameraPicker = [[UIImagePickerController alloc] init];
        _cameraPicker.delegate = self;
    }
    
    [_cameraPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:_cameraPicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [_cameraPicker dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *_pickedAvatar;
    
//    if([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
//    {
//        _pickedAvatar = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//    }
//    else
//    {
        _pickedAvatar = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    }
    
    _backgroundImageView.image = _pickedAvatar;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
