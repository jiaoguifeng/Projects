//
//  SDBrowserViewController.m
//  EasyWIFI
//
//  Created by chen on 6/30/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "SDBrowserViewController.h"
#import "CustomTableViewCell.h"
#import "SDItem.h"
#import "IQAlbumAssetsViewController.h"
#import "Utility.h"
#import "NetManager.h"

@interface SDBrowserViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *sdBackButton;
    UILabel *sdPathField;
    UITableView *sdTableView;
    
    NSMutableArray *fileList;
    NSMutableArray *directoryList;
}

@end

@implementation SDBrowserViewController

@synthesize delegate;

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
    theImageView = nil;
    
    UIButton *textFieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [textFieldButton setFrame:CGRectMake(5, 30, 50, 20)];
    [textFieldButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [textFieldButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [textFieldButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [textFieldButton setTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
    [textFieldButton addTarget:self action:@selector(sdBroswserCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textFieldButton];

    UILabel *theTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width)/2 - 60, 25, 120, 30)];
    theTitleLabel.textAlignment = NSTextAlignmentCenter;
    theTitleLabel.textColor = [UIColor whiteColor];
    theTitleLabel.text = NSLocalizedStringFromTable(@"selectFolderStr",NULL,@"sdcardStrings");
    //theTitleLabel.backgroundColor = [UIColor grayColor];
    theTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:theTitleLabel];
    theTitleLabel = nil;

    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 40, 30, 40, 20)];
    [doneButton setTitle:NSLocalizedStringFromTable(@"doneStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    //
    self.view.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height-60)];
    backImageView.contentMode = UIViewContentModeScaleToFill;
    backImageView.image = [UIImage imageNamed:@"MainViewBG"];
    [self.view addSubview:backImageView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:backImageView.bounds];
    bgView.backgroundColor = [UIColor colorWithRed:157/255.0 green:155/255.0 blue:156/255.0 alpha:0.8];
    [backImageView addSubview:bgView];

    //
    /*sdBackButton = [[UIButton alloc] initWithFrame:CGRectMake(7, 70, 18, 12)];
    [sdBackButton setImage:[UIImage imageNamed:@"sd_back.png"] forState:UIControlStateNormal];
    [sdBackButton addTarget:self action:@selector(sdDirectoryBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sdBackButton];*/
    
    sdBackButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 66, 40, 20)];
    [sdBackButton setTitle:NSLocalizedStringFromTable(@"backStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
    sdBackButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [sdBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sdBackButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [sdBackButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:234/255.0 green:66/255.0 blue:62/255.0 alpha:1] size:sdBackButton.frame.size] forState:UIControlStateNormal];
    [sdBackButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:199/255.0 green:10/255.0 blue:20/255.0 alpha:1] size:sdBackButton.frame.size] forState:UIControlStateHighlighted];
    [sdBackButton addTarget:self action:@selector(sdDirectoryBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sdBackButton];
    
    sdPathField = [[UILabel alloc] initWithFrame:CGRectMake(15, 90, frame.size.width - 15, 10)];
    sdPathField.font = [UIFont systemFontOfSize:9];
    //sdPathField.backgroundColor = [UIColor orangeColor];
    sdPathField.textColor = [UIColor whiteColor];
    sdPathField.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:sdPathField];
    
    /*UIButton *newFolderButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 22, 70, 12, 12)];
    [newFolderButton setImage:[UIImage imageNamed:@"addIcon.png"] forState:UIControlStateNormal];
    [newFolderButton addTarget:self action:@selector(newFolderAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newFolderButton];*/
    
    UIButton *newFolderButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 10 - 80, 66, 80, 20)];
    [newFolderButton setTitle:NSLocalizedStringFromTable(@"createStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
    newFolderButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [newFolderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [newFolderButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [newFolderButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:234/255.0 green:66/255.0 blue:62/255.0 alpha:1] size:newFolderButton.frame.size] forState:UIControlStateNormal];
    [newFolderButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:199/255.0 green:10/255.0 blue:20/255.0 alpha:1] size:newFolderButton.frame.size] forState:UIControlStateHighlighted];
    [newFolderButton addTarget:self action:@selector(newFolderAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newFolderButton];

    //
    CGRect theRect = CGRectMake(0, 100, frame.size.width, frame.size.height - 100);
    sdTableView = [[UITableView alloc] initWithFrame:theRect style:UITableViewStylePlain];
    sdTableView.backgroundColor = [UIColor clearColor];
    sdTableView.separatorColor = [UIColor darkGrayColor];
    sdTableView.rowHeight = 30.0;
    [self.view addSubview:sdTableView];
    [sdTableView setDataSource:self];
    [sdTableView setDelegate:self];

    //
    fileList = [[NSMutableArray alloc] initWithCapacity:0];
    
    directoryList = [[NSMutableArray alloc] initWithCapacity:0];
    [directoryList addObject:@"/"];
    [sdPathField setText:[directoryList objectAtIndex:0]];
    
    [self initFileList];
    [self sortFileList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sdBroswserCancelAction:(id)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction:(id)sender
{
    [delegate setUploadPath:[self currentDirectory]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sdDirectoryBackAction:(UIButton *)button
{
    [self gotoFolder:nil];
}

- (void)newFolderAction:(id)sender
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10001) // new folder
    {
        if(buttonIndex == 1)
        {
            NSString *folderName = [alertView textFieldAtIndex:0].text;
            if(folderName && [folderName length] > 0)
            {
                NSString *curDirectory = [self currentDirectory];
                NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:folderName,@"folderName",curDirectory,@"currentDir",nil];
                [[Utility defaultUtility] hudShowWithTitle:@""];
                [[NetManager sharedNetManager] createNewFolder:tempDict andBlock:^(id data, id error) {
                    [[Utility defaultUtility] hudClose];
                    
                    if(data)
                    {
                        [self gotoFolder:folderName];
                    }
                    else
                    {
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
}

#pragma mark ---

- (void)initFileList
{
    [fileList removeAllObjects];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] queryFileList:[self currentDirectory] andBlock:^(id data, id error) {
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
                    if([[tempDict objectForKey:@"type"] isEqualToString:@"folder"])
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
            }
            
            [sdTableView reloadData];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

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

- (void)gotoFolder:(NSString *)folderName
{
    if(folderName)
    {
        [directoryList addObject:folderName];
    }
    else
    {
        if([directoryList count] > 1)
            [directoryList removeLastObject];
    }
    
    [self initFileList];
    [self sortFileList];
    
    [sdPathField setText:[self currentDirectory]];
    [sdTableView reloadData];
}

- (NSString *)currentDirectory
{
    NSMutableString *theDirectory = [NSMutableString stringWithString:[directoryList objectAtIndex:0]];
    for(int i = 1; i < [directoryList count]; i++)
    {
        if(i == 1)
            [theDirectory appendFormat:@"%@",[directoryList objectAtIndex:i]];
        else
            [theDirectory appendFormat:@"/%@",[directoryList objectAtIndex:i]];
    }

    return theDirectory;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ----- Table view data source ---

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return fileList.count;
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
    
    [theCell setMultiSelectMode:NO];
    theCell.iconView.image = [UIImage imageNamed:@"icon_list_folder.png"];
    theCell.titleLabel.textColor = [UIColor blackColor];
    theCell.tipsTitleLabel.text = tempItem.itemTimeDisplay;
    theCell.titleLabel.text = tempItem.itemName;
    theCell.tag = indexPath.row;
    
    return theCell;
}

#pragma mark ----- Table view delegate ---

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SDItem *selectedItem = [fileList objectAtIndex:indexPath.row];
    if([selectedItem.itemType isEqualToString:@"folder"])
    {
        [self gotoFolder:selectedItem.itemName];
    }
}

@end
