//
//  DetailViewController.m
//  FloorPlay
//
//  Created by Vikas kumar on 12/08/13.
//  Copyright (c) 2013 Vikas kumar. All rights reserved.
//

#import "DetailViewController.h"
#import "FirstViewController.h"
#import "UIImageCategories.h"
#import "ImagesDataSource.h"
#import "FullScreenViewController.h"
#import "SearchCategoryViewController.h"
#import "SelectedCategoryViewController.h"
#import "MWPhotoBrowser.h"

@interface DetailViewController () <selectCategoryDelegate, UIPopoverControllerDelegate, MWPhotoBrowserDelegate>
{
    BOOL isAppearFirstTime;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *popOverController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *filmStripCollection;

@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
- (IBAction)fullScreentapped:(id)sender;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _firstViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"FirstViewController"];
    _firstViewController.master = (MasterViewController*)[[self.splitViewController.viewControllers objectAtIndex:0] topViewController];
    [self presentViewController:_firstViewController animated:NO completion:nil];
        
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    isAppearFirstTime = YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(isAppearFirstTime)
    {
        isAppearFirstTime = NO;
        self.image = [[[ImagesDataSource singleton] objects] objectAtIndex:0];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"Detail", @"");
    [label sizeToFit];
    
    UIImage *barImage = [UIImage imageWithImage:[UIImage imageNamed:@"Topbar.png"] scaledToSize:CGSizeMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height+5)];
    
    [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
    
    self.imageView.image = [[ImagesDataSource singleton] getImageAtIndex:0 forImage:self.image];
    [self.filmStripCollection reloadData];
    [self.detailTextView setText:self.image.description];
    
//    _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//    _imageView.layer.shadowOffset = CGSizeMake(0, 0);
//    _imageView.layer.shadowOpacity = 1.0;
//    _imageView.layer.shadowRadius = 3.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma -mark UIScrollView delegates

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"Zoom Started");
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    NSLog(@"Zoom Will Begin");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    NSLog(@"Zoom ends");
//    [self.scrollView setZoomScale:8.0];

}

-(void)doubleTapAction:(UIGestureRecognizer*)gesture
{
    if(self.scrollView.zoomScale == 1.0)
    {
        [self.scrollView setZoomScale:2.0];
        
//        CGSize size = self.scrollView.contentSize;
//        CGSize newSize;
//
//        newSize.width = size.width * 2;
//        newSize.height = size.height * 2;

//        self.scrollView.contentSize = newSize;
    }
    else if(self.scrollView.zoomScale == 2.0)
        [self.scrollView setZoomScale:3.0];
    else
        [self.scrollView setZoomScale:4.0];
    
    NSLog(@"Image Frama : %@",NSStringFromCGRect(self.imageView.frame));
    NSLog(@"ContentSize : %@",NSStringFromCGSize(self.scrollView.contentSize));
}

-(void)updateImage
{
    self.imageView.image = [[ImagesDataSource singleton] getImageAtIndex:0 forImage:self.image];
    [self.filmStripCollection reloadData];
    [self.detailTextView setText:self.image.description];
    self.scrollView.zoomScale = 1.0;
}

#pragma -mark UICollectionVew Delegates and datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.image.imagesList.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flimStripCell" forIndexPath:indexPath];
    UIImageView * imageView = (UIImageView*)[cell viewWithTag:444];

    imageView.image = [[ImagesDataSource singleton] getImageAtIndex:indexPath.row forImage:self.image];
    cell.backgroundColor = [UIColor whiteColor];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    self.imageView.image = [[ImagesDataSource singleton] getImageAtIndex:indexPath.row forImage:self.image];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    self.scrollView.zoomScale = 1.0;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if(!self.popOverController)
        return YES;
    else
    {
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"fullscreenViewController"])
    {
        FullScreenViewController   *vc = [segue destinationViewController];
        vc.image = self.imageView.image;
    }
    else if ([[segue identifier] isEqualToString:@"searchViewController"])
    {
        self.popOverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.popOverController.delegate = self;
        UINavigationController *navVC = [segue destinationViewController];
        SearchCategoryViewController   *vc = (SearchCategoryViewController*)[navVC topViewController];
        vc.masterTableViewController = (MasterViewController*)[[self.splitViewController.viewControllers objectAtIndex:0] topViewController];
        vc.detailViewController = self;
    }
}

-(void)selectionDoneInCategory:(CategoryType)category withString:(NSString *)selectedString
{
    [self.popOverController dismissPopoverAnimated:YES];
    self.popOverController = nil;
}

#pragma -mark UIPopOverDelegate

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popOverController = nil;
}

#pragma -mark Orientaion

-(BOOL)shouldAutorotate{
    return  YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return  UIInterfaceOrientationMaskLandscape;
}

- (IBAction)fullScreentapped:(id)sender
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;
    browser.wantsFullScreenLayout = NO;
    browser.zoomPhotosToFill = YES;
    [browser setCurrentPhotoIndex:0];

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _image.imagesList.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _image.imagesList.count)
    {
        MWPhoto *photo = [MWPhoto photoWithImage:[[ImagesDataSource singleton] getImageAtIndex:index forImage:self.image]];
        return photo;   
    }
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %i", index);
}

@end
