//
//  MasterViewController.m
//  FloorPlay
//
//  Created by Vikas kumar on 12/08/13.
//  Copyright (c) 2013 Vikas kumar. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "UIImageCategories.h"
#import "ImagesDataSource.h"
#import "MainTableViewCell.h"

@interface MasterViewController () <UISearchBarDelegate>
{
    NSMutableArray *_objects;
    NSArray *imageListToShow;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnShowAll;
- (IBAction)ShowAllTapped:(id)sender;


@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    imageListToShow = [[ImagesDataSource singleton] objects];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"", @"");
    [label sizeToFit];
    
    UIImage *barImage = [UIImage imageWithImage:[UIImage imageNamed:@"Topbar.png"] scaledToSize:CGSizeMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height+5)];
    
    [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide) name:UIKeyboardDidHideNotification object:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [imageListToShow count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];

    ImageData *image = [imageListToShow objectAtIndex:indexPath.row];
    cell.image = image;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell *cell = (MainTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    self.detailViewController.image = cell.image;
    [self.detailViewController updateImage];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ImageData *image = [imageListToShow objectAtIndex:indexPath.row];
        
        DetailViewController *vc = [segue destinationViewController];
        vc.image = image;
    }
}

-(void)selectionDoneInCategory:(CategoryType)category withString:(NSString *)selectedString
{
    imageListToShow = [[ImagesDataSource singleton] getImagesInCategory:category withValue:selectedString];
    [self.tableView reloadData];
    [[self.navigationItem rightBarButtonItem] setEnabled:YES];
}

#pragma -mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    if([self.searchBar.text isEqualToString:@""])
    {
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""])
    {
        [self ShowAllTapped:nil];
    }
    else
    {
        imageListToShow = [[ImagesDataSource singleton] searchImagesWithDetail:searchText];
        [self.tableView reloadData];
        [[self.navigationItem rightBarButtonItem] setEnabled:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setText:nil];
    self.searchBar.showsCancelButton = NO;
    [self ShowAllTapped:nil];
}

-(void)KeyboardWillHide
{
    {
        for (UIView *view in self.searchBar.subviews)
        {
            for (id subview in view.subviews)
            {
                if ( [subview isKindOfClass:[UIButton class]] )
                {
                    [subview setEnabled:YES];
                    return;
                }
            }
        }
    }
}

#pragma -mark Orientaion

-(BOOL)shouldAutorotate{
    return  YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return  UIInterfaceOrientationMaskLandscape;
}

- (IBAction)ShowAllTapped:(id)sender {
    imageListToShow = [[ImagesDataSource singleton] objects];
    [self.tableView reloadData];
    [[self.navigationItem rightBarButtonItem] setEnabled:NO];
    [self.searchBar resignFirstResponder];
    [self.searchBar setText:nil];
}
@end
