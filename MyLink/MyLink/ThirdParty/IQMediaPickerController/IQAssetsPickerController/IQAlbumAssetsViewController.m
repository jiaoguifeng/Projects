//
//  IQAlbumAssetsViewController.m
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


#import "IQAlbumAssetsViewController.h"
#import "IQAssetsCell.h"
#import "IQAssetsPickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "IQMediaPickerControllerConstants.h"
#import "SDBrowserViewController.h"
#import "NetManager.h"

@interface IQAlbumAssetsViewController () <UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
    UIBarButtonItem *doneBarButton;
    
    BOOL _isPlayerPlaying;
    UIImage *_selectedImageToShare;
    
    UICollectionView *albumCollectionView;
    UILabel *theTitleLabel;
    UIView *bottomButtonSheet;
    
    UILabel *selectTitleLabel;
    NSMutableString *uploadPath;
    UIProgressView *capacityProgressView;
    UILabel *capacityInfoLabel;
    
    UIButton *sdUploadButton;
}

@property(nonatomic, strong) NSMutableIndexSet *selectedAssets;

@end

@implementation IQAlbumAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if (self.assetController.allowsPickingMultipleItems == YES)
    {
        doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
        self.navigationItem.rightBarButtonItem = doneBarButton;
        doneBarButton.enabled = NO;
    }

    // ----------------------------------------------------------------------------------------
    // setup title bar
    //self.view.backgroundColor = [UIColor blueColor];
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
    
    //CGRect tempRect = self.view.frame;
    bottomButtonSheet = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 60)];
    bottomButtonSheet.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    //[self.view addSubview:bottomButtonSheet];
    [[[UIApplication sharedApplication] keyWindow] addSubview:bottomButtonSheet];
    
    //capacityProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    capacityProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 4, frame.size.width, 20)];
    CGRect pFrame = capacityProgressView.frame;
    capacityProgressView.trackTintColor = [UIColor darkGrayColor];
    capacityProgressView.progressTintColor = [UIColor orangeColor];
    capacityProgressView.progress = 0.5f;
    capacityProgressView.transform = CGAffineTransformMakeScale(1.0f, 5.0f);
    pFrame = capacityProgressView.frame;
    [bottomButtonSheet addSubview:capacityProgressView];

    capacityInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
    capacityInfoLabel.backgroundColor = [UIColor clearColor];
    capacityInfoLabel.textColor = [UIColor whiteColor];
    capacityInfoLabel.font = [UIFont boldSystemFontOfSize:8];
    capacityInfoLabel.textAlignment = NSTextAlignmentCenter;
    [bottomButtonSheet addSubview:capacityInfoLabel];
    
    //selectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, frame.size.width - 20, 10)];
    selectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-200)/2, 15, 200, 10)];
    selectTitleLabel.textColor = [UIColor whiteColor];
    selectTitleLabel.font = [UIFont systemFontOfSize:9];
    selectTitleLabel.text = [NSString stringWithFormat:@"%@(%@)",NSLocalizedStringFromTable(@"selectFolderStr",NULL,@"sdcardStrings"),@"/"];
    selectTitleLabel.textAlignment = NSTextAlignmentCenter;
    [bottomButtonSheet addSubview:selectTitleLabel];
    
    UIButton *sdBrowserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sdBrowserButton.frame = CGRectMake(10, 30, (frame.size.width - 30)/2, 26);
    sdBrowserButton.backgroundColor = [UIColor redColor];
    [sdBrowserButton setTitle:NSLocalizedStringFromTable(@"mySDCardStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
    [sdBrowserButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sdBrowserButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [sdBrowserButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [sdBrowserButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [sdBrowserButton addTarget:self action:@selector(directoryBrowserAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomButtonSheet addSubview:sdBrowserButton];

    sdUploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sdUploadButton.frame = CGRectMake(frame.size.width/2 + 5, 30, (frame.size.width - 30)/2, 26);
    sdUploadButton.backgroundColor = [UIColor redColor];
    [sdUploadButton setTitle:NSLocalizedStringFromTable(@"uploadStr",NULL,@"sdcardStrings") forState:UIControlStateNormal];
    [sdUploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sdUploadButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [sdUploadButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [sdUploadButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [sdUploadButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    sdUploadButton.enabled = NO;
    [bottomButtonSheet addSubview:sdUploadButton];
    //
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumLineSpacing = 5.0f;
    flowLayout.minimumInteritemSpacing = 5.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(5.0f, 2.0f, 5.0f, 2.0f);
    flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);

    albumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height - 60 - 60) collectionViewLayout:flowLayout];
    albumCollectionView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithWhite:0 alpha:0.8];
    
    //
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height-60)];
    backImageView.contentMode = UIViewContentModeScaleToFill;
    backImageView.image = [UIImage imageNamed:@"MainViewBG"];
    //
    UIView *bgView = [[UIView alloc] initWithFrame:backImageView.bounds];
    bgView.backgroundColor = [UIColor colorWithRed:157/255.0 green:155/255.0 blue:156/255.0 alpha:0.8];
    [backImageView addSubview:bgView];
    
    albumCollectionView.backgroundView = backImageView;
    
    albumCollectionView.delegate = self;
    albumCollectionView.dataSource = self;
    [albumCollectionView registerClass:[IQAssetsCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:albumCollectionView];

    theTitleLabel.text = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    _selectedAssets = [[NSMutableIndexSet alloc] init];
    
    if (_pickerType == IQAssetsPickerControllerAssetTypeVideo)
    {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognizer:)];
        [albumCollectionView addGestureRecognizer:longPressGesture];
        longPressGesture.delegate = self;
    }
    
    uploadPath = [NSMutableString stringWithString:@"/"];
}

- (void)setUploadPath:(NSString *)pathStr
{
    [uploadPath setString:pathStr];
    selectTitleLabel.text = [NSString stringWithFormat:@"%@(%@)",NSLocalizedStringFromTable(@"selectFolderStr",NULL,@"sdcardStrings"),uploadPath];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self bottomButtonSheetShow:YES];
}

- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:albumCollectionView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [albumCollectionView indexPathForItemAtPoint:p];
        
        if (indexPath)
        {
            [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
             {
                 if (result)
                 {
                     NSURL *url = [result valueForProperty:ALAssetPropertyAssetURL];
                     
                     if (url)
                     {
                         MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                         [self presentMoviePlayerViewControllerAnimated:controller];
                     }
                 }
             }];
        }
    }
}

- (void)directoryBrowserAction:(id)sender
{
    SDBrowserViewController *sdBrowserController = [[SDBrowserViewController alloc] init];
    sdBrowserController.delegate = self;
    [self.navigationController pushViewController:sdBrowserController animated:YES];
    [self bottomButtonSheetShow:NO];
}

- (void)cancelAction:(UIBarButtonItem*)item
{
    [self.navigationController popViewControllerAnimated:YES];
    [self bottomButtonSheetShow:NO];
}

- (void)doneAction:(UIBarButtonItem *)sender
{
    NSMutableArray *selectedVideo = [[NSMutableArray alloc] init];
    NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
    
    [self.assetsGroup enumerateAssetsAtIndexes:self.selectedAssets options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result)
        {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
            {
                /*NSURL *tempURL = [[result defaultRepresentation] url];
                ALAssetsLibrary *theLibrary = [[ALAssetsLibrary alloc] init];
                [theLibrary assetForURL:tempURL resultBlock:^(ALAsset *asset) {
                    CGImageRef imageRef = [[asset defaultRepresentation] fullResolutionImage];
                    if(imageRef)
                    {
                        UIImage *theImage = [UIImage imageWithCGImage:imageRef];
                    }
                } failureBlock:^(NSError *error) {
                }];*/
                
                //
                /*CGImageRef imageRef = [[result defaultRepresentation] fullResolutionImage];
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:image,IQMediaImage, nil];
                [selectedImages addObject:dict];*/

                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[result defaultRepresentation] url],IQMediaAssetURL,
                                      [[result defaultRepresentation] filename],@"IQMediaItemName",
                                      [NSByteCountFormatter stringFromByteCount:[[result defaultRepresentation] size] countStyle:NSByteCountFormatterCountStyleFile],@"IQMediaItemSize",nil];
                [selectedImages addObject:dict];
            }
            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
            {
                //ALAssetRepresentation *representation = [result defaultRepresentation];
                //NSURL *url = [representation url];
                //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:url,IQMediaAssetURL, nil];
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[result defaultRepresentation] url],IQMediaAssetURL,
                                      [[result defaultRepresentation] filename],@"IQMediaItemName",
                                      [NSByteCountFormatter stringFromByteCount:[[result defaultRepresentation] size] countStyle:NSByteCountFormatterCountStyleFile],@"IQMediaItemSize",nil];
                [selectedVideo addObject:dict];
            }
        }
    }];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if([selectedImages count])
        [dict setObject:selectedImages forKey:IQMediaTypeImage];
    
    if([selectedVideo count])
        [dict setObject:selectedVideo forKey:IQMediaTypeVideo];
    
    if(uploadPath)
        [dict setObject:uploadPath forKey:@"uploadPath"];
    
    if ([self.assetController.delegate respondsToSelector:@selector(assetsPickerController:didFinishMediaWithInfo:)])
    {
        [self.assetController.delegate assetsPickerController:self.assetController didFinishMediaWithInfo:dict];
    }
    
    [self.assetController dismissViewControllerAnimated:YES completion:nil];
    
    [self bottomButtonSheetShow:NO];
}

- (void)bottomButtonSheetShow:(BOOL)toShow
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect topButtonSheetFrame = bottomButtonSheet.frame;
    if(toShow)
    {
        topButtonSheetFrame.origin.y = self.view.frame.size.height - 60;
        
        NSDictionary *sdInfo = [[NetManager sharedNetManager] querySDInfo];
        if(sdInfo)
            capacityInfoLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"capacityStr",NULL,@"sdcardStrings"),
                                      [sdInfo objectForKey:@"available"],[sdInfo objectForKey:@"size"]];
        else
            capacityInfoLabel.text = @"";
        
        capacityProgressView.progress = 0.0f;
        //capacityProgressView.progress = (1.0 - [[sdInfo objectForKey:@"available"] floatValue]/[[sdInfo objectForKey:@"size"] floatValue])*1.0f;
    }
    else
        topButtonSheetFrame.origin.y = self.view.frame.size.height;
    [bottomButtonSheet setFrame:topButtonSheetFrame];
    
    [UIView commitAnimations];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    __block CGSize thumbnailSize = CGSizeMake(80, 80);

//    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
//     {
//         if (result)
//         {
//             thumbnailSize = [[result defaultRepresentation] dimensions];
//             CGFloat deviceCellSizeConstant = ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize.height;
//             thumbnailSize = CGSizeMake((thumbnailSize.width*deviceCellSizeConstant)/thumbnailSize.height, deviceCellSizeConstant);
//         }
//         else
//         {
//             *stop = YES;
//         }
//     }];

//    return thumbnailSize;
//}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.assetsGroup.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    IQAssetsCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if (result)
         {
             CGImageRef thumbnail = [result aspectRatioThumbnail];
             UIImage *imageThumbnail = [UIImage imageWithCGImage:thumbnail];
             cell.imageViewAsset.image = imageThumbnail;
             
             if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo && ([result valueForProperty:ALAssetPropertyDuration] != ALErrorInvalidProperty))
             {
                 NSNumber *duration = [result valueForProperty:ALAssetPropertyDuration];
                 NSUInteger seconds = [duration doubleValue];

                 {
                     NSUInteger totalMinutes = seconds/60;
                     NSUInteger totalSeconds = ((NSUInteger)seconds)%60;
                     
                     CGFloat reminder = seconds-(totalMinutes*60)-totalSeconds;
                     
                     totalSeconds+=roundf(reminder);
                     
                     if (totalSeconds>= 60)
                     {
                         totalMinutes++;
                         totalSeconds = 0;
                     }
                     
                     cell.labelDuration.text = [NSString stringWithFormat:@"%ld:%02ld",(long)totalMinutes,(unsigned long)totalSeconds];
                     cell.labelDuration.hidden = NO;
                 }
             }
             else if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto)
             {
                 cell.labelDuration.hidden = YES;
             }
         }
     }];
    
    BOOL selected = [self.selectedAssets containsIndex:indexPath.row];

    cell.checkmarkView.alpha = selected?1.0:0.0;

    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsCell *cell = (IQAssetsCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL previouslyContainsIndex = [self.selectedAssets containsIndex:indexPath.row];
    
    if (previouslyContainsIndex)
    {
        [self.selectedAssets removeIndex:indexPath.row];
    }
    else
    {
        [self.selectedAssets addIndex:indexPath.row];
    }
    
    
    if (self.assetController.allowsPickingMultipleItems == NO)
    {
        NSMutableArray *selectedVideo = [[NSMutableArray alloc] init];
        NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
        
        [self.assetsGroup enumerateAssetsAtIndexes:self.selectedAssets options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result)
            {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
                {
                    CGImageRef imageRef = [[result defaultRepresentation] fullResolutionImage];
                    UIImage *image = [UIImage imageWithCGImage:imageRef];
                    
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:image,IQMediaImage, nil];
                    
                    [selectedImages addObject:dict];
                }
                else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
                {
                    ALAssetRepresentation *representation = [result defaultRepresentation];
                    NSURL *url = [representation url];
                    
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:url,IQMediaAssetURL, nil];
                    
                    [selectedVideo addObject:dict];
                }
            }
        }];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        if ([selectedImages count]) [dict setObject:selectedImages forKey:IQMediaTypeImage];
        if ([selectedVideo count])  [dict setObject:selectedVideo forKey:IQMediaTypeVideo];
        
        if ([self.assetController.delegate respondsToSelector:@selector(assetsPickerController:didFinishMediaWithInfo:)])
        {
            [self.assetController.delegate assetsPickerController:self.assetController didFinishMediaWithInfo:dict];
        }
        
        [self.assetController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            if ([self.selectedAssets count])
            {
                doneBarButton.enabled = YES;
                sdUploadButton.enabled = YES;
                
                if (_pickerType == IQAssetsPickerControllerAssetTypePhoto)
                {
                    //theTitleLabel.text = [NSString stringWithFormat:@"%lu %@ selected",(unsigned long)[self.selectedAssets count],self.selectedAssets.count>1?@"Photos":@"Photo"];
                    theTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"funcSelectedStr",NULL,@"sdcardStrings"),(int)[self.selectedAssets count]];
                }
                else if (_pickerType == IQAssetsPickerControllerAssetTypeVideo)
                {
                    //theTitleLabel.text = [NSString stringWithFormat:@"%lu %@ selected",(unsigned long)[self.selectedAssets count],self.selectedAssets.count>1?@"Videos":@"Video"];
                    theTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"funcSelectedStr",NULL,@"sdcardStrings"),(int)[self.selectedAssets count]];
                }
                else
                {
                    //theTitleLabel.text = [NSString stringWithFormat:@"%lu Media selected",(unsigned long)[self.selectedAssets count]];
                    theTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"funcSelectedStr",NULL,@"sdcardStrings"),(int)[self.selectedAssets count]];

                }
            }
            else
            {
                doneBarButton.enabled = NO;
                theTitleLabel.text = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
                sdUploadButton.enabled = NO;
            }
            
            
            cell.checkmarkView.alpha = previouslyContainsIndex?0.0:1.0;
            
        } completion:NULL];
    }
}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    if ([aNotification.name isEqualToString: MPMoviePlayerPlaybackDidFinishNotification]) {
        NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        
        if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
        {
            MPMoviePlayerController *moviePlayer = [aNotification object];
            
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerPlaybackDidFinishNotification
                                                          object:moviePlayer];
            [self dismissViewControllerAnimated:YES completion:^{  }];
        }
//        self.collectionView.userInteractionEnabled = YES;
        _isPlayerPlaying = NO;
    }
}


@end
