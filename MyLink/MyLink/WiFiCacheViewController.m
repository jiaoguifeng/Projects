//
//  WiFiCacheViewController.m
//  MyLink
//
//  Created by chen on 16/2/18.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "WiFiCacheViewController.h"
#import "KxMenu.h"
#import "CustomTableViewCell.h"
#import "Utility.h"
#import "SinglePhotoViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface WiFiCacheViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *cacheTableView;
    NSMutableArray *cacheFileList;
    NSMutableArray *selectedIndexList;
    
    BOOL isMultiSelectMode;
    
    //
    UIView *topButtonSheet;
    UIButton *cancelButton;
    UILabel *selectCountLabel;
    UIButton *selectAllButton;
    
    UIView *bottomButtonSheet;
    UIButton *uploadButton;
    UIButton *deleteButton;
    
    //
    SinglePhotoViewController *photoViewController;
    MPMoviePlayerViewController *movie;
    
    //
    BOOL isNeedExitThread;
}
@end

@implementation WiFiCacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"wifiCacheStr",NULL,@"SettingMainUIStrings")];
    
    [self initData];
    
    [self initUIControls];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    isNeedExitThread = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    isNeedExitThread = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return cacheFileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0;
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
    
    NSDictionary *theDict = [cacheFileList objectAtIndex:indexPath.row];

    [theCell setMultiSelectMode:isMultiSelectMode];
    if(!isMultiSelectMode)
        [theCell selectRow:NO];
    else
    {
        [theCell selectRow:[[theDict objectForKey:@"isSelected"] boolValue]];
    }
    
    theCell.iconView.image = [UIImage imageNamed:[[Utility defaultUtility] fileTypeName:[[theDict objectForKey:@"fileName"] pathExtension]]];
    theCell.titleLabel.text = [theDict objectForKey:@"fileName"];
    theCell.tipsTitleLabel.text = [theDict objectForKey:@"fileSize"];
    
    return theCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *selectedItem = [cacheFileList objectAtIndex:indexPath.row];
    if(isMultiSelectMode)
    {
        BOOL status = [[selectedItem objectForKey:@"isSelected"] boolValue];
        [selectedItem setObject:[NSNumber numberWithBool:!status] forKey:@"isSelected"];
        [cacheFileList replaceObjectAtIndex:indexPath.row withObject:selectedItem];
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setButtonSheetlButtonStatus];
    }
    else
    {
        // open selected file
        NSString *fileCahcePath = [NSString stringWithFormat:@"%@%@",[[Utility defaultUtility] wifiPhotosPath],[selectedItem objectForKey:@"fileName"]];
        SD_FILE_TYPE theFileType = [[Utility defaultUtility] fileType:[fileCahcePath pathExtension]];
        if(theFileType == SD_FILE_IMAGE)
            [self playSingleImageFile:fileCahcePath];
        else if(theFileType == SD_FILE_VIDO)
            [self playVideoFile:fileCahcePath];
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

#pragma mark - Function button action

- (void)functionClicked:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:NSLocalizedStringFromTable(@"funcSelectStr",NULL,@"sdcardStrings") image:[UIImage imageNamed:@"search_icon"] itemTag:0 target:self action:@selector(pushMenuItem:)],
      ];
    
    [KxMenu showMenuInView:self.view fromRect:sender.frame menuItems:menuItems];
}

- (void)pushMenuItem:(id)sender
{
    //NSLog(@"%d", [sender itemTag]);
    
    if([sender itemTag] == 0)   // select all
    {
        isMultiSelectMode = !isMultiSelectMode;
        if(isMultiSelectMode)
        {
            [self buttonSheetShow:YES];
        }
        else
        {
            [self buttonSheetShow:NO];
        }
        
        [cacheTableView reloadData];
    }
}

#pragma mark - Button sheet action

- (void)buttonSheetShow:(BOOL)toShow
{
    // top
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect topButtonSheetFrame = topButtonSheet.frame;
    if(toShow)
        topButtonSheetFrame.origin.y = 0;
    else
        topButtonSheetFrame.origin.y = -60;
    [topButtonSheet setFrame:topButtonSheetFrame];
    
    [UIView commitAnimations];
    
    // bottom
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect bottomButtonSheetFrame = bottomButtonSheet.frame;
    if(toShow)
        bottomButtonSheetFrame.origin.y = self.view.bounds.size.height - 40;
    else
        bottomButtonSheetFrame.origin.y = self.view.bounds.size.height;
    [bottomButtonSheet setFrame:bottomButtonSheetFrame];
    
    [UIView commitAnimations];
    
    //
    CGRect tableRect = cacheTableView.frame;
    if(toShow)
        tableRect.size.height -= 40;
    else
        tableRect.size.height += 40;
    cacheTableView.frame = tableRect;
    
    //
    [self setButtonSheetlButtonStatus];
}

// Set button sheet button status
- (void)setButtonSheetlButtonStatus
{
    [selectedIndexList removeAllObjects];
    
    NSDictionary *tempItem = NULL;
    
    long theCount = [cacheTableView numberOfRowsInSection:0];
    for(int i = 0; i < [cacheFileList count]; i++)
    {
        tempItem = [cacheFileList objectAtIndex:i];
        if([[tempItem objectForKey:@"isSelected"] boolValue])
        {
            [selectedIndexList addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    if([selectedIndexList count] > 0 && ([selectedIndexList count] == theCount))
    {
        [selectAllButton setTitle:NSLocalizedStringFromTable(@"funcUnselectAllStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        [selectAllButton setTag:0];
    }
    else
    {
        [selectAllButton setTitle:NSLocalizedStringFromTable(@"funcSelectAllStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        [selectAllButton setTag:1];
    }
    
    
    if([selectedIndexList count] > 0)
    {
        [uploadButton setEnabled:YES];
        [deleteButton setEnabled:YES];
    }
    else
    {
        [uploadButton setEnabled:NO];
        [deleteButton setEnabled:NO];
    }
    
    selectCountLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"funcSelectedStr",NULL,@"sdcardStrings"),(int)[selectedIndexList count]];
}

- (void)buttonSheetAction:(id)sender
{
    if(sender == cancelButton)
    {
        isMultiSelectMode = !isMultiSelectMode;
        [self buttonSheetShow:NO];
        
        NSMutableDictionary *tempItem = nil;
        for(int i = 0; i < [cacheFileList count]; i++)
        {
            tempItem = [NSMutableDictionary dictionaryWithDictionary:[cacheFileList objectAtIndex:i]];
            [tempItem setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
            [cacheFileList replaceObjectAtIndex:i withObject:tempItem];
        }
        
        [cacheTableView reloadData];
        [self setButtonSheetlButtonStatus];
    }
    else if(sender == selectAllButton)
    {
        NSMutableDictionary *tempItem = nil;
        for(int i = 0; i < [cacheFileList count]; i++)
        {
            tempItem = [NSMutableDictionary dictionaryWithDictionary:[cacheFileList objectAtIndex:i]];
            
            if([selectAllButton tag] == 1)
                [tempItem setObject:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
            else if([selectAllButton tag] == 0)
                [tempItem setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
            
            [cacheFileList replaceObjectAtIndex:i withObject:tempItem];
        }
        
        [cacheTableView reloadData];
        [self setButtonSheetlButtonStatus];
    }
    else if(sender == deleteButton)
    {
        NSMutableDictionary *tempItem = nil;
        for(NSInteger i = [cacheFileList count]-1; i >= 0; i--)
        {
            tempItem = [cacheFileList objectAtIndex:i];
            if([[tempItem objectForKey:@"isSelected"] boolValue])
            {
                NSString *tempFilePath = [NSString stringWithFormat:@"%@%@",[[Utility defaultUtility] wifiPhotosPath],[tempItem objectForKey:@"fileName"]];
                if([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath])
                    [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
                [cacheFileList removeObjectAtIndex:i];
            }
        }

        [self writeNewCacheList];
        [selectedIndexList removeAllObjects];
        
        isMultiSelectMode = !isMultiSelectMode;
        [self buttonSheetShow:NO];
        [cacheTableView reloadData];
    }
    else if(sender == uploadButton)
    {
        [NSThread detachNewThreadSelector:@selector(uploadToWifiDisk:) toTarget:self withObject:nil];
    }
}

- (void)writeNewCacheList
{
    NSMutableDictionary *tempDict = nil;
    for(int i = 0; i < [cacheFileList count]; i++)
    {
        tempDict = [NSMutableDictionary dictionaryWithDictionary:[cacheFileList objectAtIndex:i]];
        [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
        [cacheFileList replaceObjectAtIndex:i withObject:tempDict];
    }
    
    [[Utility defaultUtility] setWifiPhotosList:cacheFileList];
}

- (void)uploadToWifiDisk:(id)sender
{
    @autoreleasepool{
        NSInteger theIndex = cacheFileList.count-1;
        
        while(theIndex >= 0)
        {
            if(isNeedExitThread)
                break;
            
            NSDictionary *tempDict = [cacheFileList objectAtIndex:theIndex];
            BOOL isSelected = [[tempDict objectForKey:@"isSelected"] boolValue];
            BOOL isProcessing = [[tempDict objectForKey:@"isProcessing"] boolValue];
            BOOL isUploadFinished = [[tempDict objectForKey:@"isUploadFinished"] boolValue];
            
            if(isSelected == YES && isUploadFinished == NO && isProcessing == NO)
            {
                [self uploadCurrentFile:theIndex];
                
                [NSThread sleepForTimeInterval:1.0];
                continue;
            }
            else if(isSelected == YES && isUploadFinished == NO && isProcessing == YES)
            {
                [NSThread sleepForTimeInterval:1.0];
                continue;
            }
            else if(isSelected == YES && isUploadFinished == YES)
            {
                // theIndex of file upload finished, continue upload next
            }
            
            theIndex--;
            [NSThread sleepForTimeInterval:1.0];
        }
        
        [self performSelectorOnMainThread:@selector(refreshUIStatus) withObject:nil waitUntilDone:YES];
    }
}

- (void)refreshUIStatus
{
    NSDictionary *tempDict = nil;
    for(NSInteger i = cacheFileList.count-1; i >= 0; i--)
    {
        tempDict = [cacheFileList objectAtIndex:i];
        BOOL isSelected = [[tempDict objectForKey:@"isSelected"] boolValue];
        BOOL isProcessing = [[tempDict objectForKey:@"isProcessing"] boolValue];
        BOOL isUploadFinished = [[tempDict objectForKey:@"isUploadFinished"] boolValue];
        
        if(isSelected && !isProcessing && isUploadFinished)
        {
            NSString *tempFilePath = [NSString stringWithFormat:@"%@%@",[[Utility defaultUtility] wifiPhotosPath],[tempDict objectForKey:@"fileName"]];
            if([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath])
                [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];

            [cacheFileList removeObjectAtIndex:i];
        }
    }
    
    [self writeNewCacheList];
    [selectedIndexList removeAllObjects];
    
    isMultiSelectMode = !isMultiSelectMode;
    [self buttonSheetShow:NO];
    [cacheTableView reloadData];
}

- (void)uploadCurrentFile:(NSInteger)fileIndex
{
    NSMutableDictionary *selectedDict = [NSMutableDictionary dictionaryWithDictionary:[cacheFileList objectAtIndex:fileIndex]];
    [selectedDict setObject:[NSNumber numberWithBool:YES] forKey:@"isProcessing"];
    [cacheFileList replaceObjectAtIndex:fileIndex withObject:selectedDict];
    
    NSString *srcFilePath = [NSString stringWithFormat:@"%@%@",[[Utility defaultUtility] wifiPhotosPath],[selectedDict objectForKey:@"fileName"]];
    NSDictionary *sdInfo = [[NetManager sharedNetManager] querySDStatus];
    if(sdInfo)
    {
        NSString *sdInfoStr = [sdInfo objectForKey:SD_Card_Status];
        if([sdInfoStr isEqualToString:@"s_s_enabled"])
        {
            // Upload image to WiFi disk when sd card is avaiable
            NSString *folderName = @"WIFIPhotos";
            NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:folderName,@"folderName",@"/",@"currentDir",nil];
            [[NetManager sharedNetManager] createNewFolder:tempDict andBlock:^(id data, id error) {
                if(data)
                {
                    [[NetManager sharedNetManager] uploadImageToDisk:folderName srcFilePath:srcFilePath andBlock:^(id data, NSError *error) {
                        if(data)
                        {
                            NSString *tipsStr = [NSString stringWithFormat:@"%@ %@",srcFilePath.lastPathComponent,NSLocalizedStringFromTable(@"wifiPhotoUploadSuccess",NULL,@"TipStrings")];
                            [[Utility defaultUtility] showHudTipStr:tipsStr];
                            
                            // upload success
                            [selectedDict setObject:[NSNumber numberWithBool:NO] forKey:@"isProcessing"];
                            [selectedDict setObject:[NSNumber numberWithBool:YES] forKey:@"isUploadFinished"];
                            [cacheFileList replaceObjectAtIndex:fileIndex withObject:selectedDict];
                        }
                    }];
                }
            }];
        }
    }
}

#pragma mark - Init Data

- (void)initData
{
    isMultiSelectMode = NO;
    
    if(selectedIndexList)
        selectedIndexList = nil;
    selectedIndexList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(cacheFileList)
        cacheFileList = nil;
    cacheFileList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *dataList = [[Utility defaultUtility] wifiPhotosList];
    if(dataList)
        [cacheFileList setArray:dataList];
}

#pragma mark - Init UI Controls

- (void)initUIControls
{
    // Add function button
    UIButton *funcButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [funcButton setFrame:CGRectMake(self.view.bounds.size.width - 35,25,30,30)];
    [funcButton setImage:[UIImage imageNamed:@"function_button.png"] forState:UIControlStateNormal];
    [funcButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [funcButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [funcButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [funcButton addTarget:self action:@selector(functionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:funcButton];
    
    // Add table view
    float theContentHeight = [self contentHeight] - 1;
    [self setContentHeight:theContentHeight];
    
    CGRect theRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 60);
    cacheTableView = [[UITableView alloc] initWithFrame:theRect style:UITableViewStylePlain];
    cacheTableView.backgroundColor = [UIColor clearColor];
    cacheTableView.separatorColor = [UIColor darkGrayColor];
    cacheTableView.rowHeight = 30.0;
    [cacheTableView setDataSource:self];
    [cacheTableView setDelegate:self];
    [self addSubview:cacheTableView];
    
    // init top/bottom button sheet
    [self initButtonSheet];
}

- (void)initButtonSheet
{
    CGRect frame = self.view.bounds;
    
    // --------------------------------------------------------------------------------------------
    // top button sheet
    topButtonSheet = [[UIView alloc] initWithFrame:CGRectMake(0, -60, frame.size.width, 60)];
    topButtonSheet.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    
    cancelButton = [self baseButton:CGRectMake(10, 30, 50, 20) title:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings") action:@selector(buttonSheetAction:)];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [cancelButton setBackgroundImage:nil forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [topButtonSheet addSubview:cancelButton];
    
    selectCountLabel = [self titleLabel:CGRectMake((frame.size.width - 200)/2, 30, 200, 20) withTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"funcSelectedStr",NULL,@"sdcardStrings"),0]];
    selectCountLabel.textAlignment = NSTextAlignmentCenter;
    selectCountLabel.textColor = [UIColor whiteColor];
    selectCountLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [topButtonSheet addSubview:selectCountLabel];
    
    selectAllButton = [self baseButton:CGRectMake(frame.size.width - 95,30,85,20) title:NSLocalizedStringFromTable(@"funcSelectAllStr",NULL,@"sdcardStrings") action:@selector(buttonSheetAction:)];
    selectAllButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    selectAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [selectAllButton setBackgroundImage:nil forState:UIControlStateNormal];
    [selectAllButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [selectAllButton setBackgroundColor:[UIColor clearColor]];
    [selectAllButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [topButtonSheet addSubview:selectAllButton];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:topButtonSheet];
    
    // --------------------------------------------------------------------------------------------
    // bottom button sheet
    bottomButtonSheet = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 40)];
    bottomButtonSheet.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    
    float buttonWidth = (frame.size.width - 10*3)/2;
    float buttonHeight = 26;
    float buttonY = 7;
    
    uploadButton = [self baseButton:CGRectMake(10, buttonY, buttonWidth, buttonHeight) title:NSLocalizedStringFromTable(@"uploadStr",NULL,@"sdcardStrings") action:@selector(buttonSheetAction:)];
    uploadButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [bottomButtonSheet addSubview:uploadButton];
    
    deleteButton = [self baseButton:CGRectMake(uploadButton.frame.origin.x + buttonWidth + 10, buttonY, buttonWidth, buttonHeight) title:NSLocalizedStringFromTable(@"funcDeleteStr",NULL,@"sdcardStrings") action:@selector(buttonSheetAction:)];
    deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [bottomButtonSheet addSubview:deleteButton];

    [[[UIApplication sharedApplication] keyWindow] addSubview:bottomButtonSheet];
}

@end
