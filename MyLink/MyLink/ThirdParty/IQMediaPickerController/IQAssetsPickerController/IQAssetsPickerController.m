//
//  IQAssetsPickerController.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-14 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "IQAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IQAssetsAlbumViewCell.h"

@interface IQAssetsPickerController ()
{
    UIBarButtonItem *cancelBarButton;
    
    UILabel *theTitleLabel;
    UITableView *pickerTableView;
}

@property(nonatomic, strong) ALAssetsLibrary *assetLibrary;

@end

@implementation IQAssetsPickerController
{
    NSMutableArray *_assetGroups;
}

#pragma - mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	/*[self.navigationItem setTitle:@"Loading..."];
    self.tableView.rowHeight = 80;
    [self.tableView registerClass:[IQAssetsAlbumViewCell class] forCellReuseIdentifier:NSStringFromClass([IQAssetsAlbumViewCell class])];
    
    cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
	[self.navigationItem setRightBarButtonItem:cancelBarButton];*/
    
    _assetGroups = [[NSMutableArray alloc] init];
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // ----------------------------------------------------------------------------------------
    // setup title bar
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = [self.view bounds];  // 320,568
    CGRect theImageViewRect = CGRectMake(0, 0, frame.size.width, 60);
    UIImageView *theImageView = [[UIImageView alloc] initWithFrame:theImageViewRect];
    theImageView.image = [UIImage imageNamed:@"ViewTitleImageBG.png"];
    [self.view addSubview:theImageView];
    
    UIButton *textFieldButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 25, 30, 30)];
    [textFieldButton setImage:[UIImage imageNamed:@"TitleBarBackButton"] forState:UIControlStateNormal];
    [textFieldButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textFieldButton];
    
    theTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-200)/2, 25, 200, 30)];
    theTitleLabel.textAlignment = NSTextAlignmentCenter;
    theTitleLabel.textColor = [UIColor whiteColor];
    theTitleLabel.text = NSLocalizedStringFromTable(@"loadingStr",NULL,@"sdcardStrings");
    theTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:theTitleLabel];
    
    // add table view
    CGRect theRect = CGRectMake(0, 60, frame.size.width, frame.size.height - 60);
    pickerTableView = [[UITableView alloc] initWithFrame:theRect style:UITableViewStylePlain];
    pickerTableView.backgroundColor = [UIColor clearColor];
    
    //
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:theRect];
    backImageView.contentMode = UIViewContentModeScaleToFill;
    backImageView.image = [UIImage imageNamed:@"MainViewBG"];
    //
    UIView *bgView = [[UIView alloc] initWithFrame:backImageView.bounds];
    bgView.backgroundColor = [UIColor colorWithRed:157/255.0 green:155/255.0 blue:156/255.0 alpha:0.8];
    [backImageView addSubview:bgView];

    pickerTableView.separatorColor = [UIColor darkGrayColor];
    pickerTableView.backgroundView = backImageView;
    
    pickerTableView.rowHeight = 80.0;
    [pickerTableView registerClass:[IQAssetsAlbumViewCell class] forCellReuseIdentifier:NSStringFromClass([IQAssetsAlbumViewCell class])];
    [self.view addSubview:pickerTableView];
    [pickerTableView setDataSource:self];
    [pickerTableView setDelegate:self];


    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^{
                       // Group enumerator Block
                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                       {
                           if (group == nil)
                           {
                               return;
                           }
                           
                           NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                           NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                           if (self.pickerType == IQAssetsPickerControllerAssetTypePhoto)
                           {
                               [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                           }
                           else if (self.pickerType == IQAssetsPickerControllerAssetTypeVideo)
                           {
                               [group setAssetsFilter:[ALAssetsFilter allVideos]];
                           }
                           
                           if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                               [_assetGroups insertObject:group atIndex:0];
                           }
                           else {
                               if (group.numberOfAssets != 0) {
                                   [_assetGroups addObject:group];
                               }
                           }

                           //[self.tableView reloadData];
                           //[self.navigationItem setTitle:@"Albums"];
                           [pickerTableView reloadData];
                           [theTitleLabel setText:@"Albums"];

                       };
        
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                           [alert show];
                       };
        
                       [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
                   });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)cancelAction:(UIBarButtonItem*)item
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
    {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_assetGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IQAssetsAlbumViewCell class]) forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.backgroundColor = [UIColor clearColor];

    ALAssetsGroup *group = (ALAssetsGroup*)[_assetGroups objectAtIndex:indexPath.row];

    [cell.imageViewAlbum setImage:[UIImage imageWithCGImage:[group posterImage]]];
    cell.labelTitle.text = [group valueForProperty:ALAssetsGroupPropertyName];

    NSUInteger photos = 0;
    NSUInteger videos = 0;
    
    if (self.pickerType == IQAssetsPickerControllerAssetTypePhoto)
    {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        photos = [group numberOfAssets];
    }
    else if (self.pickerType == IQAssetsPickerControllerAssetTypeVideo)
    {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        videos = [group numberOfAssets];
    }
    else
    {
        {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            photos = [group numberOfAssets];
        }

        {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            videos = [group numberOfAssets];
        }
    }
    
    
    NSMutableString *stringSubtitle = [[NSMutableString alloc] init];
    
    if (photos > 0)
    {
        [stringSubtitle appendFormat:@"%lu %@",(unsigned long)photos, photos>1?@"Photos":@"Photo"];
        
        if (videos > 0)
        {
            [stringSubtitle appendFormat:@", %lu %@",(unsigned long)videos, videos>1?@"Videos":@"Video"];
        }
    }
    else if (videos > 0)
    {
        [stringSubtitle appendFormat:@"%lu %@",(unsigned long)videos, videos>1?@"Videos":@"Video"];
    }
    else
    {
        if (self.pickerType == IQAssetsPickerControllerAssetTypePhoto)
        {
            [stringSubtitle appendString:@"No photos"];
        }
        else if (self.pickerType == IQAssetsPickerControllerAssetTypeVideo)
        {
            [stringSubtitle appendString:@"No videos"];
        }
    }
    
    cell.labelSubTitle.text = stringSubtitle;
    
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //IQAlbumAssetsViewController *assetsVC = [[IQAlbumAssetsViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    IQAlbumAssetsViewController *assetsVC = [[IQAlbumAssetsViewController alloc] init];
    assetsVC.pickerType = self.pickerType;
    assetsVC.assetsGroup = [_assetGroups objectAtIndex:indexPath.row];
    assetsVC.assetController = self;
    [self.navigationController pushViewController:assetsVC animated:YES];
    
    [pickerTableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
