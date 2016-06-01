//
//  WiFiDiskViewController.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "WiFiDiskViewController.h"
#import "CustomTableViewCell.h"
#import "SDItem.h"
#import "PopButtonView.h"
#import "KxMenu.h"

#import "IQMediaPickerController.h"
#import "IQFileManager.h"

#import "SinglePhotoViewController.h"
#import "ImageShowViewController.h"
#import "TransferViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef enum
{
    SD_ENABLED,
    SD_DISABLED,
    SD_NOTDETECTED,
    SD_ERROR
}SD_STATUS;

@interface WiFiDiskViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,IQMediaPickerControllerDelegate,UINavigationControllerDelegate>
{
    UIButton *categoryButton;
    UIImageView *arrowImageView;
    PopButtonView *popButtonView;
    
    UILabel *sdInfoField;
    
    UITableView *sdTableView;
    NSMutableArray *fileList;
    NSMutableArray *directoryList;
    BOOL isMultiSelectMode;
    
    NSMutableArray *selectedIndexList;

    int currentCategory;
    SD_STATUS sdStatus;
    
    //
    UIView *topButtonSheet;
    UIButton *cancelButton;
    UILabel *selectCountLabel;
    UIButton *selectAllButton;
    
    UIView *bottomButtonSheet;
    UIButton *downloadButton;
    UIButton *deleteButton;
    UIButton *renameButton;

    //
    MPMoviePlayerViewController *movie;
    SinglePhotoViewController *photoViewController;
    ImageShowViewController *imageShowViewController;
    //TransferViewController *transferViewController;

    // image/video picker
    IQMediaPickerControllerMediaType mediaType;
    NSDictionary *mediaInfo;
    
    IQMediaPickerController *mediaPickerController;
    UIActionSheet *theActionSheet;
}
@end

@implementation WiFiDiskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"wifiDiskStr",NULL,@"SettingMainUIStrings")];
    
    [self initUIControls];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

#pragma mark - Init UI Controls

- (void)initUIControls
{
    NSDictionary *sdInfo = [[NetManager sharedNetManager] querySDStatus];
    if(sdInfo)
    {
        NSString *sdInfoStr = [sdInfo objectForKey:SD_Card_Status];
        if([sdInfoStr isEqualToString:@"s_notdetected"])
        {
            // sd card not insert
            sdStatus = SD_NOTDETECTED;
        }
        else if([sdInfoStr isEqualToString:@"s_disable"])
        {
            // sd card not ready
            sdStatus = SD_DISABLED;
        }
        else if([sdInfoStr isEqualToString:@"s_s_enabled"])
        {
            // sd card is ready
            sdStatus = SD_ENABLED;
        }
        else if([sdInfoStr isEqualToString:@"s_error"])
        {
            // sd card error
            sdStatus = SD_ERROR;
        }
        else
        {
            sdStatus = SD_ERROR;
        }
    }
    
    if(sdStatus != SD_ENABLED)
    {
        sdInfoField = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 20, 18)];
        //sdInfoField.backgroundColor = [UIColor orangeColor];
        sdInfoField.font = [UIFont systemFontOfSize:12];
        sdInfoField.textColor = [UIColor blackColor];
        sdInfoField.textAlignment = NSTextAlignmentCenter;
        [self addSubview:sdInfoField];
    }
    
    if(sdStatus == SD_DISABLED)
    {
        [sdInfoField setText:NSLocalizedStringFromTable(@"sdCardNotReady",NULL,@"sdcardStrings")];
        return;
    }
    else if(sdStatus == SD_NOTDETECTED)
    {
        [sdInfoField setText:NSLocalizedStringFromTable(@"sdCardNo",NULL,@"sdcardStrings")];
        return;
    }
    else if(sdStatus == SD_ERROR)
    {
        [sdInfoField setText:NSLocalizedStringFromTable(@"sdCardError",NULL,@"sdcardStrings")];
        return;
    }

    [self setTitleText:@""];
    
    [self initUIControlsWhenSDEnabled];
    
    [self initFileListData];
}

- (void)initUIControlsWhenSDEnabled
{
    // Add down arrow
    arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 9)/2, 51, 9, 4)];
    arrowImageView.image = [UIImage imageNamed:@"downArrow"];
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    //arrowImageView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:arrowImageView];
    
    // Add filter nav button
    categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [categoryButton setFrame:CGRectMake((self.view.bounds.size.width - 100)/2,25,100,30)];
    //[categoryButton setBackgroundColor:[UIColor orangeColor]];
    [categoryButton setTitle:NSLocalizedStringFromTable(@"categoryAllStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
    [categoryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [categoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [categoryButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [categoryButton addTarget:self action:@selector(categoryClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:categoryButton];
    
    // Add function button
    UIButton *funcButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [funcButton setFrame:CGRectMake(self.view.bounds.size.width - 35,25,30,30)];
    //[funcButton setBackgroundColor:[UIColor orangeColor]];
    //[funcButton setTitle:@"功能" forState:UIControlStateNormal];
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
    sdTableView = [[UITableView alloc] initWithFrame:theRect style:UITableViewStylePlain];
    sdTableView.backgroundColor = [UIColor clearColor];
    sdTableView.separatorColor = [UIColor darkGrayColor];
    sdTableView.rowHeight = 30.0;
    [sdTableView setDataSource:self];
    [sdTableView setDelegate:self];
    [self addSubview:sdTableView];
    
    // init top/bottom button sheet
    [self initButtonSheet];

    //
    selectedIndexList = [[NSMutableArray alloc] initWithCapacity:0];
    
    //
    //if(!transferViewController)
    //    transferViewController = [[TransferViewController alloc] init];
    
    //
    [categoryButton setTitle:NSLocalizedStringFromTable(@"categoryAllStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
    currentCategory = SD_FILE_ALL;
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

    float buttonWidth = (frame.size.width - 10*4)/3;
    float buttonHeight = 26;
    float buttonY = 7;
    
    downloadButton = [self baseButton:CGRectMake(10, buttonY, buttonWidth, buttonHeight) title:NSLocalizedStringFromTable(@"funcDownloadStr",NULL,@"sdcardStrings") action:@selector(buttonSheetAction:)];
    downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [bottomButtonSheet addSubview:downloadButton];

    deleteButton = [self baseButton:CGRectMake(downloadButton.frame.origin.x + buttonWidth + 10, buttonY, buttonWidth, buttonHeight) title:NSLocalizedStringFromTable(@"funcDeleteStr",NULL,@"sdcardStrings") action:@selector(buttonSheetAction:)];
    deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [bottomButtonSheet addSubview:deleteButton];

    renameButton = [self baseButton:CGRectMake(deleteButton.frame.origin.x + buttonWidth + 10, buttonY, buttonWidth, buttonHeight) title:NSLocalizedStringFromTable(@"funcRenameStr",NULL,@"sdcardStrings") action:@selector(buttonSheetAction:)];
    renameButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [bottomButtonSheet addSubview:renameButton];

    [[[UIApplication sharedApplication] keyWindow] addSubview:bottomButtonSheet];
}

#pragma mark - Init sdTableView data

- (void)initFileListData
{
    if(directoryList)
        directoryList = nil;
    directoryList = [[NSMutableArray alloc] initWithCapacity:0];
    [directoryList addObject:@"/"];
    
    if(fileList)
    {
        [fileList removeAllObjects];
        fileList = nil;
    }
    fileList = [[NSMutableArray alloc] init];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] queryFileList:[directoryList objectAtIndex:0] andBlock:^(id data, id error) {
        if(data)
        {
            int i = 0;
            SDItem *tempItem = NULL;
            NSDictionary *tempDict = NULL;
            for(i = 0; i < [data count]; i++)
            {
                tempDict = [data objectAtIndex:i];
                if(tempDict)
                {
                    tempItem = [[SDItem alloc] init];
                    tempItem.isRootItem = YES;
                    tempItem.itemType = [tempDict objectForKey:@"type"];
                    tempItem.itemName = [tempDict objectForKey:@"name"];
                    tempItem.itemPath = [tempDict objectForKey:@"path"];
                    tempItem.itemSize = [tempDict objectForKey:@"size"];
                    tempItem.itemTime = [tempDict objectForKey:@"time"];
                    [tempItem setItemDisplayField];
                    
                    [fileList addObject:tempItem];
                    tempItem = nil;
                }
            }
            
            [self sortFileList];
            [sdTableView reloadData];
        }

        [[Utility defaultUtility] hudClose];
    }];
}

- (void)initFileListDataByType:(NSString *)type
{
    if([type isEqualToString:@"all"])
    {
        [self initFileListData];
        return;
    }
    
    if([type isEqualToString:@"image"])
    {
        [self imageShowDetailView];
        return;
    }
    
    if(directoryList)
        directoryList = nil;
    directoryList = [[NSMutableArray alloc] initWithCapacity:0];
    [directoryList addObject:@"/"];
    
    if(fileList)
    {
        [fileList removeAllObjects];
        fileList = nil;
    }
    fileList = [[NSMutableArray alloc] init];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] queryFileListByType:type andBlock:^(id data, id error) {
        if(data)
        {
            int i = 0;
            SDItem *tempItem = NULL;
            NSDictionary *tempDict = NULL;
            for(i = 0; i < [data count]; i++)
            {
                tempDict = [data objectAtIndex:i];
                if(tempDict)
                {
                    tempItem = [[SDItem alloc] init];
                    tempItem.isRootItem = YES;
                    tempItem.itemType = [tempDict objectForKey:@"type"];
                    tempItem.itemName = [tempDict objectForKey:@"name"];
                    tempItem.itemPath = [tempDict objectForKey:@"path"];
                    tempItem.itemSize = [tempDict objectForKey:@"size"];
                    tempItem.itemTime = [tempDict objectForKey:@"time"];
                    [tempItem setItemDisplayField];
                    
                    [fileList addObject:tempItem];
                    tempItem = nil;
                }
            }
            
            [self sortFileList];
            [sdTableView reloadData];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
    
}

#pragma mark - Sort fileList

- (void)sortFileList
{
    SDItem *tempItem = NULL;
    NSMutableArray *tempFolderList = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *tempFileList = [NSMutableArray arrayWithCapacity:0];
    
    for(int i = 0; i < [fileList count]; i++)
    {
        tempItem = [fileList objectAtIndex:i];
        if([tempItem.itemType isEqualToString:@"folder"])
            [tempFolderList addObject:tempItem];
        else
            [tempFileList addObject:tempItem];
    }
    
    [tempFolderList sortUsingSelector:@selector(compareByName:)];
    [tempFileList sortUsingSelector:@selector(compareByName:)];
    
    [fileList removeAllObjects];
    [fileList addObjectsFromArray:tempFolderList];
    [fileList addObjectsFromArray:tempFileList];
}

#pragma mark - Enter/Exit folder

- (void)enterFolder
{
    if(fileList)
    {
        isMultiSelectMode = NO;
        
        SDItem *tempItem = nil;
        for(int i = 0; i < [fileList count]; i++)
        {
            tempItem = [fileList objectAtIndex:i];
            tempItem.isItemSelected = NO;
        }

        [fileList removeAllObjects];
        [sdTableView reloadData];
        fileList = nil;
    }
    
    fileList = [[NSMutableArray alloc] init];
    
    NSMutableString *theDirectory = [NSMutableString stringWithString:[directoryList objectAtIndex:0]];
    
    int i = 0;
    for(i = 1; i < [directoryList count]; i++)
    {
        if(i == 1)
            [theDirectory appendFormat:@"%@",[directoryList objectAtIndex:i]];
        else
            [theDirectory appendFormat:@"/%@",[directoryList objectAtIndex:i]];
    }
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] queryFileList:theDirectory andBlock:^(id data, id error) {
        if(data)
        {
            int i = 0;
            SDItem *tempItem = NULL;
            NSDictionary *tempDict = NULL;
            for(i = 0; i < [data count]; i++)
            {
                tempDict = [data objectAtIndex:i];
                if(tempDict)
                {
                    tempItem = [[SDItem alloc] init];
                    tempItem.isRootItem = YES;
                    tempItem.itemType = [tempDict objectForKey:@"type"];
                    tempItem.itemName = [tempDict objectForKey:@"name"];
                    tempItem.itemPath = [tempDict objectForKey:@"path"];
                    tempItem.itemSize = [tempDict objectForKey:@"size"];
                    tempItem.itemTime = [tempDict objectForKey:@"time"];
                    [tempItem setItemDisplayField];
                    
                    [fileList addObject:tempItem];
                    tempItem = nil;
                }
            }
            
            [self sortFileList];
            [sdTableView reloadData];
        }
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)exitFolder
{
    if([directoryList count] > 1)
    {
        [directoryList removeLastObject];
        [self enterFolder];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return fileList.count;
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
    
    SDItem *tempItem = [fileList objectAtIndex:indexPath.row];
    
    [theCell setMultiSelectMode:isMultiSelectMode];
    if(!isMultiSelectMode)
        [theCell selectRow:NO];
    else
    {
        [theCell selectRow:tempItem.isItemSelected];
    }
    
    if([tempItem.itemType isEqualToString:@"folder"])
    {
        theCell.iconView.image = [UIImage imageNamed:@"icon_list_folder.png"];
        //theCell.titleLabel.textColor = [UIColor colorWithRed:27.0/255.0 green:128.0/255.0 blue:190.0/255.0 alpha:1.0];
        theCell.tipsTitleLabel.text = tempItem.itemTimeDisplay;
    }
    else
    {
        theCell.iconView.image = [UIImage imageNamed:[[Utility defaultUtility] fileTypeName:tempItem.itemPath.pathExtension]];
        theCell.tipsTitleLabel.text = [NSString stringWithFormat:@"%@   %@",tempItem.itemSizeDisplay,tempItem.itemTimeDisplay];
    }
    
    theCell.titleLabel.text = tempItem.itemName;
    
    theCell.tag = indexPath.row;
    
    return theCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if(row == fileList.count - 1)
        ;//NSLog(@"row: %ld", row);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(isMultiSelectMode)
    {
        //CustomTableViewCell *theCell = (CustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        //[theCell selectRow:![theCell rowSelected]];
        
        SDItem *selectedItem = [fileList objectAtIndex:indexPath.row];
        selectedItem.isItemSelected = !selectedItem.isItemSelected;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setButtonSheetlButtonStatus];
    }
    else
    {
        SDItem *selectedItem = [fileList objectAtIndex:indexPath.row];
        if([selectedItem.itemType isEqualToString:@"folder"])
        {
            [directoryList addObject:selectedItem.itemName];
            [self enterFolder];
        }
        else if([selectedItem.itemType isEqualToString:@"file"])
        {
            //[self downloadImageToSystemAlbum:selectedItem.itemName];
            [self downloadClickedFile:selectedItem.itemPath];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isMultiSelectMode)
        return NO;
    else
        return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedStringFromTable(@"deleteStr",NULL,@"TipStrings");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedStringFromTable(@"deleteFileStr",NULL,@"sdcardStrings")
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

#pragma mark - Back/Category/Function button actions

- (void)onBackButtonClicked:(id)sender
{
    if(directoryList && [directoryList count] > 1)
    {
        [self exitFolder];
    }
    else
        [super onBackButtonClicked:sender];
}

- (void)categoryClicked:(UIButton *)sender
{
    CGPoint point = CGPointMake(sender.frame.origin.x + sender.frame.size.width/2, 60);
    NSArray *titles = @[NSLocalizedStringFromTable(@"categoryAllStr",NULL,@"sdcardStrings"),
                        NSLocalizedStringFromTable(@"categoryImageStr",NULL,@"sdcardStrings"),
                        NSLocalizedStringFromTable(@"categoryAudioStr",NULL,@"sdcardStrings"),
                        NSLocalizedStringFromTable(@"categoryVideoStr",NULL,@"sdcardStrings")];
    NSArray *images = @[@"Category_All.png",@"Category_Image.png",@"Category_Audio.png",@"Category_Video.png"];
    NSArray *tags = @[@"0",@"1",@"2",@"3"];
    
    if(popButtonView)
    {
        popButtonView = nil;
    }
    
    __weak UIButton *tempCategoryButton = categoryButton;
    __weak id weakSelf = self;
    __weak UIImageView *tempArrowImageView = arrowImageView;
    
    arrowImageView.image = [UIImage imageNamed:@"upArrow"];
    popButtonView = [[PopButtonView alloc] initWithPoint:point titles:titles images:images tags:tags];
    popButtonView.selectButtonIndex = ^(NSInteger index){
        NSInteger buttonTag = index;
        //NSLog(@"button index:%d", (int)buttonTag);
        tempArrowImageView.image = [UIImage imageNamed:@"downArrow"];
        
        if(buttonTag == -1)
        {
            return;
        }
        
        NSString *type = @"all";
        if(buttonTag == 0)
        {
            type = @"all";
            currentCategory = SD_FILE_ALL;
            [tempCategoryButton setTitle:NSLocalizedStringFromTable(@"categoryAllStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        }
        else if(buttonTag == 1)
        {
            type = @"image";
            currentCategory = SD_FILE_IMAGE;
            //[tempCategoryButton setTitle:NSLocalizedStringFromTable(@"categoryImageStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        }
        else if(buttonTag == 2)
        {
            type = @"audio";
            currentCategory = SD_FILE_AUDIO;
            [tempCategoryButton setTitle:NSLocalizedStringFromTable(@"categoryAudioStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        }
        else if(buttonTag == 3)
        {
            type = @"video";
            currentCategory = SD_FILE_VIDO;
            [tempCategoryButton setTitle:NSLocalizedStringFromTable(@"categoryVideoStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        }
        else if(buttonTag == 4)
        {
            type = @"document";
            currentCategory = SD_FILE_DOCUMENT;
            [tempCategoryButton setTitle:NSLocalizedStringFromTable(@"categoryDocStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        }
        else if(buttonTag == 5)
        {
            type = @"other";
            currentCategory = SD_FILE_OTHERS;
            [tempCategoryButton setTitle:NSLocalizedStringFromTable(@"categoryOtherStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
        }
        
        [weakSelf initFileListDataByType:type];
    };
    [popButtonView show];
}

- (void)functionClicked:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:NSLocalizedStringFromTable(@"funcUploadStr",NULL,@"sdcardStrings") image:[UIImage imageNamed:@"action_icon"] itemTag:0 target:self action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:NSLocalizedStringFromTable(@"funcUpDownTableStr",NULL,@"sdcardStrings") image:[UIImage imageNamed:@"check_icon"] itemTag:1 target:self action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:NSLocalizedStringFromTable(@"funcNewStr",NULL,@"sdcardStrings") image:[UIImage imageNamed:@"reload"] itemTag:2 target:self action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:NSLocalizedStringFromTable(@"funcSelectStr",NULL,@"sdcardStrings") image:[UIImage imageNamed:@"search_icon"] itemTag:3 target:self action:@selector(pushMenuItem:)],
      ];
    
    [KxMenu showMenuInView:self.view fromRect:sender.frame menuItems:menuItems];
}

- (void)pushMenuItem:(id)sender
{
    //NSLog(@"%d", [sender itemTag]);
    
    if([sender itemTag] == 0)   // upload
    {
        [self mediaPickerAction];
    }
    else if([sender itemTag] == 1)  // transfer table
    {
        [self presentViewController:[TransferViewController defaultTransferViewController] animated:YES completion:nil];
    }
    else if([sender itemTag] == 2)  // new folder
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedStringFromTable(@"inputFolderNameStr",NULL,@"sdcardStrings")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        
        alert.tag = 10001;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
        [alert textFieldAtIndex:0].placeholder = NSLocalizedStringFromTable(@"folderNameStr",NULL,@"sdcardStrings");
        [alert show];
    }
    else if([sender itemTag] == 3)   // select all
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
        
        [sdTableView reloadData];
    }
}

#pragma mark - UIAlertView response function

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag < 10000)   // for one delete
    {
        if(buttonIndex == 1)
        {
            NSNumber *selIndex = [NSNumber numberWithInt:(int)alertView.tag];
            SDItem *delItem = [fileList objectAtIndex:selIndex.integerValue];
            NSString *pathToDelStr = delItem.itemPath;
            
            [[Utility defaultUtility] hudShowWithTitle:@""];
            [[NetManager sharedNetManager] deleteFile:pathToDelStr andBlock:^(id data, id error) {
                [[Utility defaultUtility] hudClose];
                
                if(data)
                {
                    [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"deleteOkStr",NULL,@"TipStrings")];
                }
                else
                {
                    [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"deleteNoStr",NULL,@"TipStrings")];
                }
                
                [fileList removeObjectAtIndex:selIndex.integerValue];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selIndex.integerValue inSection:0];
                [sdTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [sdTableView reloadData];
            }];
        }
    }
    
    if(alertView.tag == 10000) // normal alert
    {
        ;
    }
    
    if(alertView.tag == 10001) // new folder
    {
        if(buttonIndex == 1)
        {
            NSString *folderName = [alertView textFieldAtIndex:0].text;
            if(folderName && [folderName length] > 0)
            {
                int i = 0;
                NSMutableString *theDirectory = [NSMutableString stringWithString:[directoryList objectAtIndex:0]];
                for(i = 1; i < [directoryList count]; i++)
                    [theDirectory appendFormat:@"%@/",[directoryList objectAtIndex:i]];
                
                NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:folderName,@"folderName",theDirectory,@"currentDir",nil];
                
                [[Utility defaultUtility] hudShowWithTitle:@""];
                [[NetManager sharedNetManager] createNewFolder:tempDict andBlock:^(id data, id error) {
                    [[Utility defaultUtility] hudClose];

                    if(data)
                    {
                        [self enterFolder];
                    }
                    else
                    {
                        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"createNoStr",NULL,@"TipStrings")];
                    }
                }];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedStringFromTable(@"fileNameEmptyStr",NULL,@"sdcardStrings")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings")
                                                      otherButtonTitles:nil];
                alert.tag = 10000;
                [alert show];
            }
        }
    }
    
    if(alertView.tag == 10002) // rename file
    {
        if(buttonIndex == 1)
        {
            NSString *fileName = [alertView textFieldAtIndex:0].text;
            if(fileName && [fileName length] > 0)
            {
                SDItem *tempItem = [fileList objectAtIndex:[[selectedIndexList objectAtIndex:0] intValue]];
                NSMutableString *srcPath = [NSMutableString stringWithString:tempItem.itemPath];
                
                NSString *destPath = NULL;
                if([tempItem.itemType isEqualToString:@"file"])
                {
                    destPath = [NSString stringWithFormat:@"%@/%@.%@",[srcPath stringByDeletingLastPathComponent],fileName,[srcPath pathExtension]];
                    if([directoryList count] == 1)
                        destPath = [NSString stringWithFormat:@"%@%@.%@",[srcPath stringByDeletingLastPathComponent],fileName,[srcPath pathExtension]];
                }
                else
                {
                    destPath = [NSString stringWithFormat:@"%@/%@",[srcPath stringByDeletingLastPathComponent],fileName];
                    if([directoryList count] == 1)
                        destPath = [NSString stringWithFormat:@"%@%@",[srcPath stringByDeletingLastPathComponent],fileName];
                }
                
                NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:tempItem.itemPath,@"srcPath",destPath,@"destPath", nil];
                
                [[Utility defaultUtility] hudShowWithTitle:@""];
                [[NetManager sharedNetManager] rename:tempDict andBlock:^(id data, id error) {
                    if(data)
                    {
                        [self buttonSheetShow:NO];
                        [self enterFolder];
                    }
                    
                    [[Utility defaultUtility] hudClose];
                }];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedStringFromTable(@"fileNameEmptyStr",NULL,@"sdcardStrings")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings")
                                                      otherButtonTitles:nil];
                alert.tag = 10000;
                [alert show];
            }
        }
    }
    
    if(alertView.tag == 10003) // delete more files
    {
        if(buttonIndex == 1)
        {
            SDItem *tempItem = NULL;
            NSMutableArray *tempList = [NSMutableArray arrayWithCapacity:0];
            for(int i = 0; i < [selectedIndexList count]; i++)
            {
                tempItem = [fileList objectAtIndex:[[selectedIndexList objectAtIndex:i] intValue]];
                [tempList addObject:tempItem.itemPath];
            }
            
            [[Utility defaultUtility] hudShowWithTitle:@""];
            [[NetManager sharedNetManager] deleteMoreFile:tempList andBlock:^(id data, id error) {
                if(data)
                {
                    [self buttonSheetShow:NO];
                    [self enterFolder];
                }
                
                [[Utility defaultUtility] hudClose];
            }];
        }
    }
}

#pragma mark - Button Sheet Action

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
    CGRect tableRect = sdTableView.frame;
    if(toShow)
        tableRect.size.height -= 40;
    else
        tableRect.size.height += 40;
    sdTableView.frame = tableRect;
    
    //
    [self setButtonSheetlButtonStatus];
}

- (void)buttonSheetAction:(id)sender
{
    if(sender == cancelButton)
    {
        isMultiSelectMode = !isMultiSelectMode;
        [self buttonSheetShow:NO];
        
        SDItem *tempItem = nil;
        for(int i = 0; i < [fileList count]; i++)
        {
            tempItem = [fileList objectAtIndex:i];
            tempItem.isItemSelected = NO;
        }

        [sdTableView reloadData];
        [self setButtonSheetlButtonStatus];
    }
    else if(sender == selectAllButton)
    {
        SDItem *tempItem = nil;
        for(int i = 0; i < [fileList count]; i++)
        {
            tempItem = [fileList objectAtIndex:i];
            
            if([selectAllButton tag] == 1)
                tempItem.isItemSelected = YES;
            else if([selectAllButton tag] == 0)
                tempItem.isItemSelected = NO;
        }
        
        [sdTableView reloadData];
        [self setButtonSheetlButtonStatus];
    }
    else if(sender == downloadButton)
    {
        isMultiSelectMode = NO;
        [self buttonSheetShow:NO];

        SDItem *tempItem = NULL;
        NSMutableArray *tempList = [NSMutableArray arrayWithCapacity:0];
        for(int i = 0; i < [selectedIndexList count]; i++)
        {
            tempItem = [fileList objectAtIndex:[[selectedIndexList objectAtIndex:i] intValue]];
            [tempList addObject:tempItem];
        }
        
        [self presentViewController:[TransferViewController defaultTransferViewController] animated:YES completion:^(void){
            [[TransferViewController defaultTransferViewController] appendDownloadList:tempList];
        }];
        
        [sdTableView reloadData];
        [self setButtonSheetlButtonStatus];
    }
    else if(sender == deleteButton)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedStringFromTable(@"deleteFileStr",NULL,@"TipStrings")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        
        alert.tag = 10003;
        [alert show];
    }
    else if(sender == renameButton)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedStringFromTable(@"inputNewNameStr",NULL,@"sdcardStrings")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        
        alert.tag = 10002;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
        [alert textFieldAtIndex:0].placeholder = NSLocalizedStringFromTable(@"inputNewNamePlaceStr",NULL,@"sdcardStrings");
        [alert show];
    }
}

// Set button sheet button status
- (void)setButtonSheetlButtonStatus
{
    [selectedIndexList removeAllObjects];
    
    SDItem *tempItem = NULL;
    
    long theCount = [sdTableView numberOfRowsInSection:0];
    for(int i = 0; i < [fileList count]; i++)
    {
        tempItem = [fileList objectAtIndex:i];
        if(tempItem.isItemSelected)
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
    
    BOOL hasFolder = NO;
    for(int i = 0; i < [selectedIndexList count]; i++)
    {
        int tempIndex = [[selectedIndexList objectAtIndex:i] intValue];
        tempItem = [fileList objectAtIndex:tempIndex];
        if([tempItem.itemType isEqualToString:@"folder"])
        {
            hasFolder = YES;
            break;
        }
    }
    
    if([selectedIndexList count] > 0 && !hasFolder)
        [downloadButton setEnabled:YES];
    else
        [downloadButton setEnabled:NO];
    
    if([selectedIndexList count] > 0)
        [deleteButton setEnabled:YES];
    else
        [deleteButton setEnabled:NO];
    
    if([selectedIndexList count] == 1)
        [renameButton setEnabled:YES];
    else
        [renameButton setEnabled:NO];
    
    selectCountLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"funcSelectedStr",NULL,@"sdcardStrings"),(int)[selectedIndexList count]];
}

#pragma mark - Image/Video picker functions

- (void)mediaPickerAction
{
    if(theActionSheet)
    {
        theActionSheet = nil;
    }
    
    theActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"alertStrings")
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:NSLocalizedStringFromTable(@"categoryImageStr",NULL,@"sdcardStrings"),NSLocalizedStringFromTable(@"categoryVideoStr",NULL,@"sdcardStrings"),nil];
    theActionSheet.tag = 1;
    [theActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType rangeOfString:@"iPad"].length > 0)
    {
        if(mediaPickerController)
        {
            mediaPickerController = nil;
        }
        
        if(actionSheet.tag == 1 && (buttonIndex == 0 || buttonIndex == 1))
        {
            mediaType = buttonIndex;
            
            mediaPickerController = [[IQMediaPickerController alloc] init];
            mediaPickerController.delegate = self;
            [mediaPickerController setMediaType:mediaType];
            mediaPickerController.allowsPickingMultipleItems = YES;
            [self presentViewController:mediaPickerController animated:YES completion:nil];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType rangeOfString:@"iPad"].length > 0)
        return;

    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if(mediaPickerController)
        {
            mediaPickerController = nil;
        }
        
        if (actionSheet.tag == 1)
        {
            mediaType = buttonIndex;
            
            mediaPickerController = [[IQMediaPickerController alloc] init];
            mediaPickerController.delegate = self;
            [mediaPickerController setMediaType:mediaType];
            mediaPickerController.allowsPickingMultipleItems = YES;
            [self presentViewController:mediaPickerController animated:YES completion:nil];
        }
        else if (actionSheet.tag == 2)
        {
        }
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    if(mediaPickerController)
    {
        mediaPickerController = nil;
    }
}

- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    if(mediaInfo)
    {
        mediaInfo = nil;
    }
    
    mediaInfo = [info copy];
    //NSArray *tempList = [mediaInfo allKeys];
    
    NSArray *dataList = nil;
    if(mediaType == IQMediaPickerControllerMediaTypePhotoLibrary)
        dataList = [mediaInfo objectForKey:IQMediaTypeImage];
    else if(mediaType == IQMediaPickerControllerMediaTypeVideoLibrary)
        dataList = [mediaInfo objectForKey:IQMediaTypeVideo];
    else if(mediaType == IQMediaPickerControllerMediaTypeAudioLibrary)
        dataList = [mediaInfo objectForKey:IQMediaTypeAudio];;
    
    NSString *uploadPath = [mediaInfo objectForKey:@"uploadPath"];
    NSMutableArray *uploadDataList = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary *tempDict = nil;
    for(int i = 0; i < [dataList count]; i++)
    {
        tempDict = [dataList objectAtIndex:i];
        if(mediaType == IQMediaPickerControllerMediaTypePhotoLibrary)
        {
            //UIImage *image = [tempDict objectForKey:IQMediaImage];
            //NSURL *imageURL = [tempDict objectForKey:IQMediaAssetURL];
            [uploadDataList addObject:tempDict];
        }
        else if(mediaType == IQMediaPickerControllerMediaTypeVideoLibrary)
        {
            //NSURL *url = [tempDict objectForKey:IQMediaAssetURL];
            [uploadDataList addObject:tempDict];
        }
        else if(mediaType == IQMediaPickerControllerMediaTypeAudioLibrary)
        {
            [uploadDataList addObject:tempDict];
        }
    }
    
    if(uploadDataList.count > 0)
    {
        NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:uploadDataList,@"dataList",uploadPath,@"uploadPath", nil];
        [self performSelectorOnMainThread:@selector(uploadFiles:) withObject:paramDict waitUntilDone:NO];
    }
}

- (void)uploadFiles:(id)sender
{
    NSDictionary *paramDict = sender;
    [self presentViewController:[TransferViewController defaultTransferViewController] animated:YES completion:^(void){
        [[TransferViewController defaultTransferViewController] appendUploadList:[paramDict objectForKey:@"dataList"] withPath:[paramDict objectForKey:@"uploadPath"]];
    }];
}

#pragma mark - Download and Open file

- (void)downloadClickedFile:(NSString *)filePath
{
    NSString *fileTypeFolderName = NULL;
    SD_FILE_TYPE theFileType = [[Utility defaultUtility] fileType:[filePath pathExtension]];
    if(theFileType == SD_FILE_IMAGE)
        fileTypeFolderName = @"imageTemp";
    else if(theFileType == SD_FILE_AUDIO)
        fileTypeFolderName = @"audioTemp";
    else if(theFileType == SD_FILE_VIDO)
        fileTypeFolderName = @"videoTemp";
    else if(theFileType == SD_FILE_DOCUMENT)
        fileTypeFolderName = @"documentTemp";
    else if(theFileType == SD_FILE_OTHERS)
        fileTypeFolderName = @"othersTemp";
    
    // if fileTypeFolder is not exist, create it
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [NSString stringWithFormat:@"%@/Caches/%@",documentsPath,fileTypeFolderName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:NULL error:NULL];
    
    NSMutableString *fileDestPath = [NSMutableString stringWithFormat:@"%@/Caches/%@/%@",documentsPath,fileTypeFolderName,[filePath lastPathComponent]];
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               filePath,@"srcPath",
                               fileDestPath,@"destPath",
                               [NSNumber numberWithInt:theFileType],@"fileType",nil];

    [[NetManager sharedNetManager] downloadFile:filePath toPath:fileDestPath andBlock:^(id data, NSError *error) {
        if(data)
        {
            SD_FILE_TYPE theFileType = [[paramDict objectForKey:@"fileType"] intValue];
            if(theFileType == SD_FILE_IMAGE)
                [self playSingleImageFile:[paramDict objectForKey:@"destPath"]];
            else if(theFileType == SD_FILE_AUDIO)
                [self playAudioFile:[paramDict objectForKey:@"destPath"]];
            else if(theFileType == SD_FILE_VIDO)
                [self playVideoFile:[paramDict objectForKey:@"destPath"]];
            else if(theFileType == SD_FILE_DOCUMENT)
            {
                if([[NSFileManager defaultManager] fileExistsAtPath:[paramDict objectForKey:@"destPath"]])
                    [[NSFileManager defaultManager] removeItemAtPath:[paramDict objectForKey:@"destPath"] error:NULL];
            }
            else if(theFileType == SD_FILE_OTHERS)
            {
                if([[NSFileManager defaultManager] fileExistsAtPath:[paramDict objectForKey:@"destPath"]])
                    [[NSFileManager defaultManager] removeItemAtPath:[paramDict objectForKey:@"destPath"] error:NULL];
            }
        }
        else
        {
            [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"processingFailStr",NULL,@"TipStrings")];
        }
    }];
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

#pragma mark - Open multiple image files

- (void)imageShowDetailView
{
    NSMutableArray *tempImageList = [NSMutableArray arrayWithCapacity:0];
    
    [[NetManager sharedNetManager] queryFileListByType:@"image" andBlock:^(id data, id error) {
        if(data)
        {
            int i = 0;
            SDItem *tempItem = NULL;
            NSDictionary *tempDict = NULL;
            for(i = 0; i < [data count]; i++)
            {
                if(i > 28)
                    ;//break;
                
                tempDict = [data objectAtIndex:i];
                if(tempDict)
                {
                    tempItem = [[SDItem alloc] init];
                    tempItem.isRootItem = YES;
                    tempItem.itemType = [tempDict objectForKey:@"type"];
                    tempItem.itemName = [tempDict objectForKey:@"name"];
                    tempItem.itemPath = [tempDict objectForKey:@"path"];
                    tempItem.itemSize = [tempDict objectForKey:@"size"];
                    tempItem.itemTime = [tempDict objectForKey:@"time"];
                    [tempItem setItemDisplayField];
                    
                    [tempImageList addObject:tempItem];
                    tempItem = nil;
                }
            }
            
            if(imageShowViewController)
                imageShowViewController = NULL;

            imageShowViewController = [[ImageShowViewController alloc] init];
            [imageShowViewController initImageList:tempImageList];
            [self presentViewController:imageShowViewController animated:YES completion:nil];
        }
    }];
}

#pragma mark - Open audio files

- (void)playAudioFile:(NSString *)filePath
{
    [self playVideoFile:filePath];
}

#pragma mark - Open video files

- (void)playVideoFile:(NSString *)filePath
{
    //打开本地视频
    //NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //NSString *path = [NSString stringWithFormat:@"%@/TempVideo/test.mp4",documentsPath];
    //NSURL *url = [NSURL fileURLWithPath:path];
    
    //打开本地视频
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    //打开网络视频
    //NSString *path = @"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8";
    //NSString *path = @"http://192.168.0.1/share/testVideo.mp4";
    //NSURL *url = [NSURL URLWithString:path];
    
    //视频播放对象
    if(movie)
        movie = nil;
    
    movie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    movie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    //movie.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    movie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [movie.moviePlayer.view setFrame:self.view.bounds];
    movie.moviePlayer.initialPlaybackTime = -1;
    
    /*movie.view.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
     movie.view.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
     CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
     [movie.view setTransform:transform];*/
    
    //[self.view addSubview:movie.view];
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
    
    // 删除临时视频文件
    NSString *moivePath = [[theMoviePlayer contentURL] path];
    if([[NSFileManager defaultManager] fileExistsAtPath:moivePath])
        [[NSFileManager defaultManager] removeItemAtPath:moivePath error:NULL];
    
    // 移除视频播放View
    //[theMoviePlayer.view removeFromSuperview];
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
