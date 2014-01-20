//
//  FirstViewController.m
//  FloorPlay
//
//  Created by Vikas kumar on 16/08/13.
//  Copyright (c) 2013 Vikas kumar. All rights reserved.
//

#import "FirstViewController.h"
#import "Constants.h"
#import "AFHTTPClient.h"
#import "UIViewControllerCategories.h"
#import "AFHTTPRequestOperation.h"
#import "ImagesDataParser.h"
#import "ImagesDataSource.h"

@interface FirstViewController ()

@property (nonatomic) NSInteger processCount;

@property (nonatomic, retain) NSMutableArray *imagesList;

- (IBAction)dateSourceSelected:(id)sender;
- (IBAction)updateTapped:(id)sender;

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![[[FloorPlayServices singleton] preferences] objectForKey:IS_FIRST_TIME_LAUNCH])
    {
        [self downloadImagesListFirstTime];
    }
    else
    {
        [self loadDataFromSavedJson];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dateSourceSelected:(id)sender
{
    _dataFrom = [sender restorationIdentifier];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)updateTapped:(id)sender
{
    [self downloadImagesListFirstTime];
}



-(void)downloadImagesListFirstTime
{
    NSString *url = [NSString stringWithFormat:@"%@getImage.php",SERVER_URL];
    
    
    
    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [Client postPath:@"users/login.json" parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self saveJsonData:responseObject];
         [self loadDataFromSavedJson];
         [self downloadAllImages];
         
     }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [self showAlertWithMessage:[error localizedDescription] andTitle:@"Error"];
                 [self hideLoadingScreen];
             }];
    
    [self showLoadingScreenWithMessage:@"Downloading..."];
 
}

-(void)saveJsonData:(NSData*)data
{
    NSString *documentDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    documentDirPath = [documentDirPath stringByAppendingString:@"/"];
    documentDirPath = [documentDirPath stringByAppendingString:SAVED_JSON_FILE];
    
    [[NSFileManager defaultManager] createFileAtPath:documentDirPath contents:data attributes:nil];
    
    [[[FloorPlayServices singleton] preferences] setObject:@"YES" forKey:IS_FIRST_TIME_LAUNCH];
}

-(void)loadDataFromSavedJson
{
    NSString *documentDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    documentDirPath = [documentDirPath stringByAppendingString:@"/"];
    documentDirPath = [documentDirPath stringByAppendingString:SAVED_JSON_FILE];
    
    NSData *data = [NSData dataWithContentsOfFile:documentDirPath];
    if (data)
        self.imagesList = [[NSMutableArray alloc] initWithArray:[ImagesDataParser parseImagesFromData:data andCacheDataSource:YES]];
}


-(NSArray*)getListOfImagesNotDownloaded
{
    NSMutableArray *imageNames = [[NSMutableArray alloc] init];
    for (ImageData *image in self.imagesList)
    {
        for (NSString *imageName in image.imagesList)
        {
            if(imageName.length > 0)
                [imageNames addObject:imageName];
        }
    }
    
    return  imageNames;
}

-(void)downloadAllImages
{
    NSArray *imagesNameList = [self getListOfImagesNotDownloaded];
    
    NSArray *dirPathSearch = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirPath = [dirPathSearch objectAtIndex:0];
    NSString *dirPath = [docDirPath stringByAppendingPathComponent:@"Images/"];
    
    // if the sub directory does not exist, create it
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dirPath])
    {
        NSLog(@"%@: does not exists...will attempt to create", dirPath);
        
        if (![fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"errormsg:%@", [error description]);
    }
 
    self.processCount = 0;
    
    for (int i = 0; i < imagesNameList.count; i++)
    {
        NSString *urlPath = [[NSString stringWithFormat:@"%@%@", SERVER_URL_FOR_FILE, [imagesNameList objectAtIndex:i]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //        urlPath = [urlPath stringByReplacingOccurrencesOfString:@"jpeg" withString:@"jpg"];
        NSString *filePath = [dirPath stringByAppendingPathComponent:[imagesNameList objectAtIndex:i]];
        
        // download the song file and save them directly to docdir
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             self.processCount++;
             NSLog(@"File :%d Success!", _processCount);
             
             // all the files have been saved, now update the playlist
             if (self.processCount == [imagesNameList count])
             {
                 [self hideLoadingScreen];
                 [[ImagesDataSource singleton] update];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             self.processCount++;
             NSLog(@"ERROR ERROR ERROR:%@ - could not save to path:%@", error, filePath);
             if (self.processCount == [imagesNameList count])
             {
                 [self hideLoadingScreen];
             }
         } ];
        [self showLoadingScreenWithMessage:@"Downloading Images..."];
        [operation start];
        
    }

}

#pragma -mark Orientaion

-(BOOL)shouldAutorotate{
    return  YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return  UIInterfaceOrientationMaskLandscape;
}


@end