//
//  TransferViewController.m
//  EasyWIFI
//
//  Created by chen on 7/7/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "TransferViewController.h"
#import "CustomTableViewCell.h"
#import "SDItem.h"
#import "HMSegmentedControl.h"
#import "TransferTask.h"
#import "NetManager.h"
#import "Utility.h"
#import "SinglePhotoViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define TABLE_UPLOAD    0
#define TABLE_DOWNLOAD  1

#define TRANSFER_FODLER @"Caches/TransferTemp"
#define PLIST_DOWNLOAD  @"donwload.plist"
#define PLIST_UPLOAD    @"upload.plist"
#define DOWNLOAD_FOLDER @"downloadTemp"
#define UPLOAD_FOLDER   @"uploadTemp"

@interface TransferViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    HMSegmentedControl *segmentControl;
    
    UITableView *uploadTableView;
    NSMutableArray *uploadDataList;
    
    UITableView *downloadTableView;
    NSMutableArray *downloadDataList;
    
    //
    UIView *topButtonSheet;
    UIButton *cancelButton;
    UILabel *selectCountLabel;
    UIButton *selectAllButton;
    
    UIView *bottomButtonSheet;
    
    BOOL isMultiSelectMode;
    
    //
    SinglePhotoViewController *photoViewController;
    MPMoviePlayerViewController *movie;
}
@end

static TransferViewController *defaultTransferViewController = nil;

@implementation TransferViewController

+ (TransferViewController *)defaultTransferViewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultTransferViewController = [[TransferViewController alloc] init];
    });
    
    return defaultTransferViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = [self.view bounds];  // 320,568
    
    // ----------------------------------------------------------------------------------------
    // setup title bar
    CGRect theImageViewRect = CGRectMake(0, 0, frame.size.width, 60);
    UIImageView *theImageView = [[UIImageView alloc] initWithFrame:theImageViewRect];
    theImageView.image = [UIImage imageNamed:@"ViewTitleImageBG.png"];
    [self.view addSubview:theImageView];
    
    UIButton *textFieldButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 25, 30, 30)];
    [textFieldButton setImage:[UIImage imageNamed:@"TitleBarBackButton.png"] forState:UIControlStateNormal];
    [textFieldButton addTarget:self action:@selector(transferTableCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textFieldButton];

    UILabel *theTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - 200)/2, 25, 200, 30)];
    theTitleLabel.textAlignment = NSTextAlignmentCenter;
    theTitleLabel.textColor = [UIColor whiteColor];
    theTitleLabel.text = NSLocalizedStringFromTable(@"transferTableStr",NULL,@"sdcardStrings");
    theTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:theTitleLabel];
    
    UIButton *multiSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [multiSelectButton setFrame:CGRectMake(frame.size.width - 60, 10, 60, 60)];
    [multiSelectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [multiSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [multiSelectButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [multiSelectButton setTitle:NSLocalizedStringFromTable(@"funcSelectAllStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
    [multiSelectButton addTarget:self action:@selector(multiSelectModeAction:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:multiSelectButton];

    //
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height-60)];
    backImageView.contentMode = UIViewContentModeScaleToFill;
    backImageView.image = [UIImage imageNamed:@"MainViewBG"];
    [self.view addSubview:backImageView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:backImageView.bounds];
    bgView.backgroundColor = [UIColor colorWithRed:157/255.0 green:155/255.0 blue:156/255.0 alpha:0.8];
    [backImageView addSubview:bgView];

    //
    segmentControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, 20)];
    [segmentControl addTarget:self action:@selector(segmentControlChagned:) forControlEvents:UIControlEventValueChanged];
    [segmentControl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [segmentControl setSectionTitles:@[NSLocalizedStringFromTable(@"transferUploadTableStr",NULL,@"sdcardStrings"), NSLocalizedStringFromTable(@"transferDownloadTableStr",NULL,@"sdcardStrings")]];
    [segmentControl setBackgroundColor:[UIColor lightGrayColor]];
    [segmentControl setTextColor:[UIColor darkGrayColor]];
    [segmentControl setSelectedTextColor:[UIColor whiteColor]];
    [segmentControl setSelectionIndicatorColor:[UIColor whiteColor]];
    [segmentControl setSelectionIndicatorMode:HMSelectionIndicatorFillsSegment];
    [segmentControl setSelectionIndicatorHeight:2.0f];
    [self.view addSubview:segmentControl];

    //
    uploadTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, frame.size.width, frame.size.height - 80) style:UITableViewStylePlain];
    uploadTableView.rowHeight = 30.0;
    uploadTableView.backgroundColor = [UIColor clearColor];
    uploadTableView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:uploadTableView];
    [uploadTableView setDataSource:self];
    [uploadTableView setDelegate:self];
    
    downloadTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, frame.size.width, 16*30) style:UITableViewStylePlain];
    downloadTableView.rowHeight = 30.0;
    downloadTableView.backgroundColor = [UIColor clearColor];
    downloadTableView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:downloadTableView];
    [downloadTableView setDataSource:self];
    [downloadTableView setDelegate:self];
    
    [self switchToTableView:TABLE_DOWNLOAD];
    [self loadLastData];
    
    [self initButtonSheet];
    isMultiSelectMode = NO;
    
    [self startAllTask];
}

- (void)transferTableCancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)multiSelectModeAction:(id)sender
{
    [self buttonSheetShow:!isMultiSelectMode];
}

- (void)segmentControlChagned:(HMSegmentedControl *)segmentedControl
{
    NSInteger theSelIndex = segmentedControl.selectedIndex;
    if(theSelIndex == 0)
    {
        [uploadTableView setHidden:NO];
        [downloadTableView setHidden:YES];
        [uploadTableView reloadData];
    }
    else
    {
        [uploadTableView setHidden:YES];
        [downloadTableView setHidden:NO];
        [downloadTableView reloadData];
   }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---

- (void)startAllTask
{
    [NSThread detachNewThreadSelector:@selector(startTask:) toTarget:self withObject:nil];
}

- (void)startTask:(id)sender
{
    @autoreleasepool {
        while(YES)
        {
            NSLog(@"TransferViewController task executing ......");
            [self popDownloadTask];
            [self popUploadTask];
            
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}

- (void)popDownloadTask
{
    TransferTask *tempTask = nil;
    
    for(int i = 0; i < [downloadDataList count]; i++)
    {
        tempTask = [downloadDataList objectAtIndex:i];
        
        if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == YES)
            break;
        else if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == NO && tempTask.isTaskPaused == YES)
            break;
        else if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == NO)
        {
            [tempTask startDownload];
            break;
        }
        else if(tempTask.isCompleted == YES)
            continue;
    }
}

- (void)popUploadTask
{
    TransferTask *tempTask = nil;
    
    for(int i = 0; i < [uploadDataList count]; i++)
    {
        tempTask = [uploadDataList objectAtIndex:i];
        
        if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == YES)
            break;
        else if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == NO && tempTask.isTaskPaused == YES)
            break;
        else if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == NO)
        {
            [tempTask startUpload];
            break;
        }
        else if(tempTask.isCompleted == YES)
            continue;
    }
}

#pragma mark ---

- (void)initButtonSheet
{
    CGRect frame = [self.view bounds];
    
    // --------------------------------------------------------------------------------------------
    // top button sheet
    topButtonSheet = [[UIView alloc] initWithFrame:CGRectMake(0, -70, frame.size.width, 70)];
    //topButtonSheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    topButtonSheet.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
    
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 44, 45, 18)];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [cancelButton addTarget:self action:@selector(buttonSheetCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [topButtonSheet addSubview:cancelButton];
    
    selectCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 44, 200, 20)];
    selectCountLabel.textAlignment = NSTextAlignmentCenter;
    selectCountLabel.textColor = [UIColor whiteColor];
    selectCountLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"funcSelectedStr",NULL,@"sdcardStrings"),0];
    selectCountLabel.font = [UIFont boldSystemFontOfSize:12];
    [topButtonSheet addSubview:selectCountLabel];
    
    selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllButton setFrame:CGRectMake(frame.size.width - 60 - 20,44,70,18)];
    [selectAllButton setBackgroundColor:[UIColor whiteColor]];
    [selectAllButton setTitle:NSLocalizedStringFromTable(@"funcSelectAllStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
    [selectAllButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectAllButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [selectAllButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [selectAllButton addTarget:self action:@selector(selectAllClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topButtonSheet addSubview:selectAllButton];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:topButtonSheet];
    
    // --------------------------------------------------------------------------------------------
    // bottom button sheet
    //buttonSheet = [[LTBounceSheet alloc] initWithHeight:30 bgColor:[UIColor colorWithWhite:0 alpha:0.7]];
    bottomButtonSheet = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 30)];
    //topButtonSheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    bottomButtonSheet.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bottomButtonSheet];
}

- (void)buttonSheetCancelAction:(id)sender
{
    [self buttonSheetShow:NO];
}

- (void)selectAllClicked:(id)sender
{
}

#pragma mark ---

- (void)buttonSheetShow:(BOOL)toShow
{
    isMultiSelectMode = toShow;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect topButtonSheetFrame = topButtonSheet.frame;
    if(toShow)
        topButtonSheetFrame.origin.y = 0;
    else
        topButtonSheetFrame.origin.y = -70;
    [topButtonSheet setFrame:topButtonSheetFrame];
    
    [UIView commitAnimations];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect bottomButtonSheetFrame = bottomButtonSheet.frame;
    if(toShow)
        bottomButtonSheetFrame.origin.y -= 30;
    else
        bottomButtonSheetFrame.origin.y += 30;
    [bottomButtonSheet setFrame:bottomButtonSheetFrame];
    
    [UIView commitAnimations];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ---

- (void)switchToTableView:(int)viewMode
{
    if(viewMode == TABLE_DOWNLOAD)
    {
        [segmentControl setSelectedIndex:1];
        [uploadTableView setHidden:YES];
        [downloadTableView setHidden:NO];
    }
    else
    {
        [segmentControl setSelectedIndex:0];
        [uploadTableView setHidden:NO];
        [downloadTableView setHidden:YES];
    }
}

- (void)loadLastData
{
    // Prepare plist files
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@",documentsPath,TRANSFER_FODLER];
    if(![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:NULL error:NULL];
        
        NSString *downTemp = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,DOWNLOAD_FOLDER];
        [[NSFileManager defaultManager] createDirectoryAtPath:downTemp withIntermediateDirectories:YES attributes:NULL error:NULL];
        NSString *upTemp = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,UPLOAD_FOLDER];
        [[NSFileManager defaultManager] createDirectoryAtPath:upTemp withIntermediateDirectories:YES attributes:NULL error:NULL];
       
        
        NSMutableArray *emptyList = [NSMutableArray arrayWithCapacity:0];
        [emptyList writeToFile:[NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_DOWNLOAD] atomically:YES];
        [emptyList writeToFile:[NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_UPLOAD] atomically:YES];
    }
    
    NSDictionary *tempItem = nil;
    TransferTask *tempTask = nil;

    // prepare for download list
    if(!downloadDataList)
        downloadDataList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *tempDownloadList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_DOWNLOAD]];
    
    for(int i = 0; i < [tempDownloadList count]; i++)
    {
        tempItem = [tempDownloadList objectAtIndex:i];
        
        tempTask = [[TransferTask alloc] initWithURL:[tempItem objectForKey:@"taskSrcPath"]];
        tempTask.taskType = [tempItem objectForKey:@"taskType"];
        tempTask.taskName = [tempItem objectForKey:@"taskName"];
        tempTask.taskSrcPath = [tempItem objectForKey:@"taskSrcPath"];
        
        //tempTask.taskDscPath = [tempItem objectForKey:@"taskDscPath"];
        NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *tempDownFolder = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,DOWNLOAD_FOLDER];
        tempTask.taskDscPath = [NSString stringWithFormat:@"%@/%@",tempDownFolder,[tempItem objectForKey:@"taskName"]];
        
        tempTask.isCompleted = [[tempItem objectForKey:@"isCompleted"] boolValue];
        tempTask.isTaskProcessing = [[tempItem objectForKey:@"isTaskProcessing"] boolValue];
        tempTask.isTaskPaused = [[tempItem objectForKey:@"isTaskPaused"] boolValue];
        tempTask.bytesTotal = [tempItem objectForKey:@"bytesTotal"];
        [downloadDataList addObject:tempTask];
        [downloadTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:downloadDataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tempTask start];
    }
    
    // prepare for upload list
    if(!uploadDataList)
        uploadDataList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *tempUploadList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_UPLOAD]];
    for(int i = 0; i < [tempUploadList count]; i++)
    {
        tempItem = [tempUploadList objectAtIndex:i];
        
        tempTask = [[TransferTask alloc] initWithURL:[tempItem objectForKey:@"uploadURL"]];
        tempTask.taskName = [tempItem objectForKey:@"taskName"];
        tempTask.taskDscPath = [tempItem objectForKey:@"taskDscPath"];
        
        tempTask.isCompleted = [[tempItem objectForKey:@"isCompleted"] boolValue];
        tempTask.isTaskProcessing = [[tempItem objectForKey:@"isTaskProcessing"] boolValue];
        tempTask.isTaskPaused = [[tempItem objectForKey:@"isTaskPaused"] boolValue];
        tempTask.bytesTotal = [tempItem objectForKey:@"bytesTotal"];
        tempTask.uploadURLString = [NSString stringWithFormat:@"%@%@",BASE_URL_STR,URL_SD_FILE_UPLOAD];
        [uploadDataList addObject:tempTask];
        [uploadTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:uploadDataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tempTask start];
    }
}

- (void)appendDownloadList:(NSArray *)dataList
{
    [self switchToTableView:TABLE_DOWNLOAD];
    
    SDItem *tempItem = nil;
    TransferTask *tempTask = nil;
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *tempDownFolder = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,DOWNLOAD_FOLDER];
    
    for(int i = 0; i < [dataList count]; i++)
    {
        tempItem = [dataList objectAtIndex:i];
        
        tempTask = [[TransferTask alloc] initWithURL:tempItem.itemPath];
        tempTask.taskType = tempItem.itemType;
        tempTask.taskName = tempItem.itemName;
        NSString *tempSrc = [NSString stringWithFormat:@"%@/share%@",BASE_URL_STR,tempItem.itemPath];;
        tempTask.taskSrcPath = [tempSrc stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        tempTask.taskDscPath = [NSString stringWithFormat:@"%@/%@",tempDownFolder,tempItem.itemName];
        [downloadDataList addObject:tempTask];
        [downloadTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:downloadDataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tempTask start];
    }
    
    [self writeDownloadItems];
    [downloadTableView reloadData];
}

- (void)appendUploadList:(NSArray *)dataList withPath:(NSString *)uploadPath
{
    [self switchToTableView:TABLE_UPLOAD];
    
    TransferTask *uploadTask = nil;
    for(int i = 0; i < [dataList count]; i++)
    {
        NSDictionary *tempDict = [dataList objectAtIndex:i];
        uploadTask = [[TransferTask alloc] initWithURL:[[tempDict objectForKey:@"IQMediaAssetURL"] absoluteString]];
        uploadTask.bytesTotal = [tempDict objectForKey:@"IQMediaItemSize"];
        uploadTask.taskName = [tempDict objectForKey:@"IQMediaItemName"];
        uploadTask.taskDscPath = uploadPath;
        uploadTask.uploadURLString = [NSString stringWithFormat:@"%@%@",BASE_URL_STR,URL_SD_FILE_UPLOAD];
        
        [uploadDataList addObject:uploadTask];
        [uploadTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:uploadDataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self writeUploadItems];
    [uploadTableView reloadData];
}

#pragma mark ----- plist read and write function -----

- (void)writeDownloadItems
{
    NSDictionary *tempItem = nil;
    TransferTask *tempTask = nil;
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];
    
    for(int i = 0; i < [downloadDataList count]; i++)
    {
        tempTask = [downloadDataList objectAtIndex:i];
        tempItem = [NSDictionary dictionaryWithObjectsAndKeys:tempTask.taskType,@"taskType",
                    tempTask.taskName,@"taskName",
                    tempTask.taskSrcPath,@"taskSrcPath",
                    tempTask.taskName,@"taskDscPath",
                    [NSNumber numberWithBool:tempTask.isCompleted],@"isCompleted",
                    [NSNumber numberWithBool:tempTask.isTaskProcessing],@"isTaskProcessing",
                    [NSNumber numberWithBool:tempTask.isTaskPaused],@"isTaskPaused",
                    tempTask.bytesTotal,@"bytesTotal",
                    nil];
        [itemList addObject:tempItem];
    }
    
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *writePath = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_DOWNLOAD];
    [itemList writeToFile:writePath atomically:YES];
}

- (NSDictionary *)downloadListItemAtIndex:(int)index
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_DOWNLOAD];
    NSMutableArray *tempList = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:tempPath]];
    
    return [tempList objectAtIndex:index];
}

- (void)updateDownloadItem:(NSUInteger)index withObject:(NSDictionary *)object
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *writePath = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_DOWNLOAD];
    NSMutableArray *writeList = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:writePath]];

    NSMutableDictionary *tempDict = [writeList objectAtIndex:index];
    [tempDict setObject:[object objectForKey:@"isCompleted"] forKey:@"isCompleted"];
    [tempDict setObject:[object objectForKey:@"isTaskProcessing"] forKey:@"isTaskProcessing"];
    [tempDict setObject:[object objectForKey:@"isTaskPaused"] forKey:@"isTaskPaused"];
    [tempDict setObject:[object objectForKey:@"bytesTotal"] forKey:@"bytesTotal"];
    
    [writeList replaceObjectAtIndex:index withObject:tempDict];
    [writeList writeToFile:writePath atomically:YES];
}

- (void)writeUploadItems
{
    NSDictionary *tempItem = nil;
    TransferTask *tempTask = nil;
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];
    
    for(int i = 0; i < [uploadDataList count]; i++)
    {
        tempTask = [uploadDataList objectAtIndex:i];
        
        tempItem = [NSDictionary dictionaryWithObjectsAndKeys:
                    tempTask.uploadURL.absoluteString,@"uploadURL",
                    tempTask.taskName,@"taskName",
                    tempTask.taskDscPath,@"taskDscPath",
                    tempTask.taskName,@"taskDscPath",
                    [NSNumber numberWithBool:tempTask.isCompleted],@"isCompleted",
                    [NSNumber numberWithBool:tempTask.isTaskProcessing],@"isTaskProcessing",
                    [NSNumber numberWithBool:tempTask.isTaskPaused],@"isTaskPaused",
                    tempTask.bytesTotal,@"bytesTotal",
                    nil];
        [itemList addObject:tempItem];
    }
    
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *writePath = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_UPLOAD];
    [itemList writeToFile:writePath atomically:YES];
}

- (void)updateUploadItem:(NSUInteger)index withObject:(NSDictionary *)object
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *writePath = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,PLIST_UPLOAD];
    NSMutableArray *writeList = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:writePath]];
    
    NSMutableDictionary *tempDict = [writeList objectAtIndex:index];
    [tempDict setObject:[object objectForKey:@"isCompleted"] forKey:@"isCompleted"];
    [tempDict setObject:[object objectForKey:@"isTaskProcessing"] forKey:@"isTaskProcessing"];
    [tempDict setObject:[object objectForKey:@"isTaskPaused"] forKey:@"isTaskPaused"];
    [tempDict setObject:[object objectForKey:@"bytesTotal"] forKey:@"bytesTotal"];
    
    [writeList replaceObjectAtIndex:index withObject:tempDict];
    [writeList writeToFile:writePath atomically:YES];
}

#pragma mark ----- Table view data source -----

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    /*if(tableView == uploadTableView)
        return uploadDataList.count;
    else
        return downloadDataList.count;*/
    
    if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
        return downloadDataList.count;
    else
        return uploadDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //It's cruical here that this identifier is treeNodeCell and that the cell identifier in the story board is anything else but not treeNodeCell
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    CustomTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        theCell.backgroundColor = [UIColor clearColor];
        [theCell setDelegate:self];
    }
    
    TransferTask *theTask = nil;
    
    if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
        theTask = [downloadDataList objectAtIndex:indexPath.row];
    else
        theTask = [uploadDataList objectAtIndex:indexPath.row];
    
    [theCell setMultiSelectMode:NO];
    theCell.iconView.image = [UIImage imageNamed:[[Utility defaultUtility] fileTypeName:theTask.taskName.lastPathComponent.pathExtension]];
    theCell.titleLabel.text = theTask.taskName;
    
    if(theTask.isCompleted)
    {
        theCell.progress.hidden = YES;
        theCell.customButton.hidden = YES;
        theCell.tipsTitleLabel.textColor = [UIColor blackColor];
        
        if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
            theCell.tipsTitleLabel.text = [NSString stringWithFormat:@"%@(%@)",NSLocalizedStringFromTable(@"transferDownloadFinishStr",NULL,@"sdcardStrings"), theTask.bytesTotal];
        else
            theCell.tipsTitleLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedStringFromTable(@"transferUploadFinishStr",NULL,@"sdcardStrings"),theTask.bytesTotal];
        
        if(theTask.error)
        {
            theCell.tipsTitleLabel.textColor = [UIColor redColor];
            theCell.tipsTitleLabel.text = theTask.error;
        }
    }
    else
    {
        theCell.progress.progress = theTask.progress;
        
        if(theTask.isTaskProcessing)
        {
            theCell.progress.hidden = NO;
            if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
                theCell.tipsTitleLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"transferDownloadingStr",NULL,@"sdcardStrings"), theTask.bytesProgress];
            else
                theCell.tipsTitleLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"transferUploadingStr",NULL,@"sdcardStrings"),theTask.bytesProgress];
        }
        else
        {
            if(theTask.isTaskPaused == NO)
            {
                theCell.progress.hidden = YES;
                if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
                    theCell.tipsTitleLabel.text = NSLocalizedStringFromTable(@"transferWaitStr",NULL,@"sdcardStrings");
                else
                    theCell.tipsTitleLabel.text = NSLocalizedStringFromTable(@"transferWaitStr",NULL,@"sdcardStrings");
            }
            else
            {
                [theCell.customButton setImage:[UIImage imageNamed:@"TransferContinue.png"] forState:UIControlStateNormal];
                if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
                    theCell.tipsTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"transferPauseStr",NULL,@"sdcardStrings")];
                else
                    theCell.tipsTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"transferPauseStr",NULL,@"sdcardStrings")];
                theCell.progress.hidden = YES;
                theCell.customButton.hidden = NO;
            }
        }
        
        [self tryUnboundCell:theCell];
        [self boundCell:theCell forTask:theTask];
    }
    
    theCell.tag = indexPath.row;
    
    return theCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
    {
        NSDictionary *tempDict = [self downloadListItemAtIndex:(int)indexPath.row];
        if(tempDict)
        {
            NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *tempDownFolder = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,DOWNLOAD_FOLDER];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",tempDownFolder,[tempDict objectForKey:@"taskName"]];
            
            SD_FILE_TYPE theFileType = [[Utility defaultUtility] fileType:[filePath pathExtension]];
            if(theFileType == SD_FILE_IMAGE)
                [self playSingleImageFile:filePath];
            else if(theFileType == SD_FILE_AUDIO)
                [self playAudioFile:filePath];
            else if(theFileType == SD_FILE_VIDO)
                [self playVideoFile:filePath];
            else if(theFileType == SD_FILE_DOCUMENT)
            {
            }
            else if(theFileType == SD_FILE_OTHERS)
            {
            }
         }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedStringFromTable(@"deleteStr",NULL,@"ButtonStrings");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedStringFromTable(@"deleteFileStr",NULL,@"ButtonStrings")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        alert.tag = indexPath.row;
        [alert show];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)customButtonActions:(int)tag
{
    if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
    {
        TransferTask *tempTask = [downloadDataList objectAtIndex:tag];
        if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == YES && tempTask.isTaskPaused == NO)
            [tempTask stopDownload];
        else if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == NO && tempTask.isTaskPaused == YES)
            [tempTask startDownload];
    }
    else
    {
        TransferTask *tempTask = [uploadDataList objectAtIndex:tag];
        if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == YES && tempTask.isTaskPaused == NO)
            [tempTask stopUpload];
        else if(tempTask.isCompleted == NO && tempTask.isTaskProcessing == NO && tempTask.isTaskPaused == YES)
            [tempTask startUpload];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag < 10000 && buttonIndex == 1)
    {
        if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
        {
            NSDictionary *tempDict = [self downloadListItemAtIndex:(int)alertView.tag];
            if(tempDict)
            {
                NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *tempDownFolder = [NSString stringWithFormat:@"%@/%@/%@",documentsPath,TRANSFER_FODLER,DOWNLOAD_FOLDER];
                NSString *delFilePath = [NSString stringWithFormat:@"%@/%@",tempDownFolder,[tempDict objectForKey:@"taskName"]];
                [[NSFileManager defaultManager] removeItemAtPath:delFilePath error:NULL];

                [downloadDataList removeObjectAtIndex:alertView.tag];
                [self writeDownloadItems];
                
                NSInteger theIndex = alertView.tag;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:theIndex inSection:0];
                [downloadTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        else
        {
            [uploadDataList removeObjectAtIndex:alertView.tag];
            [self writeUploadItems];
            
            NSInteger theIndex = alertView.tag;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:theIndex inSection:0];
            [uploadTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark ---

- (void)boundCell:(CustomTableViewCell *)cell forTask:(TransferTask *)task
{
    cell.boundData = task;
    [task addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [task addObserver:self forKeyPath:@"isCompleted" options:NSKeyValueObservingOptionNew context:nil];
    [task addObserver:self forKeyPath:@"isTaskPaused" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)tryUnboundCell:(CustomTableViewCell *)cell
{
    if(!cell.boundData)
        return;
    TransferTask *task = cell.boundData;
    [task removeObserver:self forKeyPath:@"isCompleted"];
    [task removeObserver:self forKeyPath:@"progress"];
    [task removeObserver:self forKeyPath:@"isTaskPaused"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"progress"])
    {
        TransferTask *task = (TransferTask *)object;
        CustomTableViewCell *cell = nil;
        if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
        {
            cell = (CustomTableViewCell *)[downloadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[downloadDataList indexOfObject:task] inSection:0]];
            cell.tipsTitleLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"transferDownloadingStr",NULL,@"sdcardStrings"),task.bytesProgress];
        }
        else
        {
            cell = (CustomTableViewCell *)[uploadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[uploadDataList indexOfObject:task] inSection:0]];
            cell.tipsTitleLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"transferUploadingStr",NULL,@"sdcardStrings"),task.bytesProgress];
        }
        cell.progress.progress = task.progress;
        cell.customButton.hidden = NO;
        cell.progress.hidden = NO;
    }
    else if([keyPath isEqualToString:@"isCompleted"])
    {
        TransferTask *task = (TransferTask *)object;
        if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
        {
            [downloadTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[downloadDataList indexOfObject:task] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [uploadTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[uploadDataList indexOfObject:task] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if(task.isCompleted)
        {
            NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"isCompleted",
                                      [NSNumber numberWithBool:NO],@"isTaskProcessing",
                                      [NSNumber numberWithBool:NO],@"isTaskPaused",
                                      task.bytesTotal,@"bytesTotal",nil];
            if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
                [self updateDownloadItem:[downloadDataList indexOfObject:task] withObject:tempDict];
            else
                [self updateUploadItem:[uploadDataList indexOfObject:task] withObject:tempDict];
        }
    }
    else if([keyPath isEqualToString:@"isTaskPaused"])
    {
        TransferTask *task = (TransferTask *)object;
        CustomTableViewCell *cell = nil;
        if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
        {
            cell = (CustomTableViewCell *)[downloadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[downloadDataList indexOfObject:task] inSection:0]];
        }
        else
        {
            cell = (CustomTableViewCell *)[uploadTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[uploadDataList indexOfObject:task] inSection:0]];
        }
        
        NSDictionary *tempDict = nil;
        if(task.isTaskPaused == YES)
        {
            [cell.customButton setImage:[UIImage imageNamed:@"TransferContinue.png"] forState:UIControlStateNormal];
            
            if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
                cell.tipsTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"transferPauseStr",NULL,@"sdcardStrings")];
            else
                cell.tipsTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"transferPauseStr",NULL,@"sdcardStrings")];
            cell.progress.hidden = YES;
            
            tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithBool:NO],@"isCompleted",
                        [NSNumber numberWithBool:NO],@"isTaskProcessing",
                        [NSNumber numberWithBool:YES],@"isTaskPaused",
                        task.bytesTotal,@"bytesTotal",nil];
        }
        else
        {
            [cell.customButton setImage:[UIImage imageNamed:@"TransferPause.png"] forState:UIControlStateNormal];
            
            tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithBool:NO],@"isCompleted",
                        [NSNumber numberWithBool:YES],@"isTaskProcessing",
                        [NSNumber numberWithBool:NO],@"isTaskPaused",
                        task.bytesTotal,@"bytesTotal",nil];
        }
        
        if([segmentControl selectedIndex] == TABLE_DOWNLOAD)
            [self updateDownloadItem:[downloadDataList indexOfObject:task] withObject:tempDict];
        else
            [self updateUploadItem:[uploadDataList indexOfObject:task] withObject:tempDict];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Open single image files

- (void)playSingleImageFile:(NSString *)filePath
{
    if(photoViewController)
        photoViewController = NULL;
    
    photoViewController = [[SinglePhotoViewController alloc] init];
    [photoViewController setImagePath:filePath];
    [self presentViewController:photoViewController animated:YES completion:nil];
}

#pragma mark - Open audio files

- (void)playAudioFile:(NSString *)filePath
{
    [self playVideoFile:filePath];
}

#pragma mark - Open video files

- (void)playVideoFile:(NSString *)filePath
{
    if(movie)
        movie = nil;
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    movie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    movie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    //movie.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    movie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [movie.moviePlayer.view setFrame:self.view.bounds];
    movie.moviePlayer.initialPlaybackTime = -1;
    
    [self presentMoviePlayerViewControllerAnimated:movie];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CMP_YES",@"currentView", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CMPMoviePlayerViewRotateChanged" object:self userInfo:infoDict];
    // 注册一个播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movie.moviePlayer];
    [movie.moviePlayer prepareToPlay];
    [movie.moviePlayer play];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notify
{
    // 视频播放对象
    MPMoviePlayerController *theMoviePlayer = [notify object];
    
    // 销毁播放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMoviePlayer];
    
    // 移除视频播放View
    [movie dismissMoviePlayerViewControllerAnimated];
    
    // 释放视频对象
    movie = nil;
    
    //
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CMP_NO",@"currentView", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CMPMoviePlayerViewRotateChanged" object:self userInfo:infoDict];
    
    //这句话是防止手动先把设备置为竖屏,导致下面的语句失效.
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
}

@end
