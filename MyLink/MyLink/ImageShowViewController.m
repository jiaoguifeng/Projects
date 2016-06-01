//
//  ImageShowViewController.m
//  EasyWIFI
//
//  Created by chen on 5/26/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "ImageShowViewController.h"
#import "CollectionViewCell.h"
#import "PhotoBroswerVC.h"
#import "SDItem.h"
#import "NetManager.h"
#import "Utility.h"

// [NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
// image caches path : /Caches/com.longcheer.SDWebImageCache.default

@interface ImageShowViewController ()
{
    UICollectionView *imageCollectionView;
    BOOL toExitThumbnailCreateThread;
    
    NSMutableArray *imageList;
}

@end

@implementation ImageShowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*// test start
    // test for created thumbnail size (test.jpg --> test-thumb.jpg, 8MB --> 10K)
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Caches/imageTemp/test.jpg",documentsPath];
    NSString *thumbImgPath = [NSString stringWithFormat:@"%@/Caches/imageTemp/test-thumb.jpg",documentsPath];
    
    UIImage *testImage = [UIImage imageNamed:@"test.jpg"];
    NSData *imgData = UIImageJPEGRepresentation(testImage, 1.0);
    [imgData writeToFile:imgPath atomically:YES];
    
    UIImage *thumbnailImage = [self thumbnailWithImage:testImage];
    NSData *thumbImgData = UIImageJPEGRepresentation(thumbnailImage, 1.0);
    [thumbImgData writeToFile:thumbImgPath atomically:YES];
    // test end*/
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = [self.view bounds];  // 320,568
    
    // ----------------------------------------------------------------------------------------
    // setup title bar
    CGRect theImageViewRect = CGRectMake(0, 0, frame.size.width, 60);
    UIImageView *theImageView = [[UIImageView alloc] initWithFrame:theImageViewRect];
    theImageView.image = [UIImage imageNamed:@"ViewTitleImageBG.png"];
    [self.view addSubview:theImageView];
    [theImageView release];
    
    UIButton *textFieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [textFieldButton setFrame:CGRectMake(5, 10, 50, 60)];
    //[textFieldButton setImage:[UIImage imageNamed:@"titleBarBackButton.png"] forState:UIControlStateNormal];
    [textFieldButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [textFieldButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [textFieldButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [textFieldButton setTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
    [textFieldButton addTarget:self action:@selector(photoViewBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textFieldButton];
    
    UILabel *theTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - 200)/2, 18, 200, 30)];
    theTitleLabel.textAlignment = NSTextAlignmentCenter;
    theTitleLabel.textColor = [UIColor whiteColor];
    theTitleLabel.text = NSLocalizedStringFromTable(@"categoryImageStr",NULL,@"sdcardStrings");
    theTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:theTitleLabel];
    [theTitleLabel release];

    //
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    imageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height - 60) collectionViewLayout:flowLayout];
    imageCollectionView.backgroundColor = [UIColor darkGrayColor];//[UIColor colorWithWhite:0 alpha:0.8];
    
    //设置代理
    imageCollectionView.delegate = self;
    imageCollectionView.dataSource = self;
    
    //注册cell和ReusableView（相当于头部）
    [imageCollectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [imageCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

    [self.view addSubview:imageCollectionView];
}

- (void)photoViewBackAction:(UIButton *)button
{
    //NSIndexPath *theIndexPath = [NSIndexPath indexPathForRow:27 inSection:0];;
    //[imageCollectionView scrollToItemAtIndexPath:theIndexPath atScrollPosition:0 animated:YES];
    //return;
    
    toExitThumbnailCreateThread = YES;
    
    if(imageCollectionView)
    {
        [imageCollectionView removeFromSuperview];
        [imageCollectionView release];
    }
    
    NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *cachesFolderPath = [NSString stringWithFormat:@"%@/Caches/com.tricheer.SDWebImageCache.default",libraryPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:cachesFolderPath])
        [[NSFileManager defaultManager] removeItemAtPath:cachesFolderPath error:NULL];

    [self dismissViewControllerAnimated:YES completion:nil];    
}

#pragma mark ---

- (void)initImageList:(NSArray *)theImageList
{
    if(imageList)
    {
        [imageList removeAllObjects];
        [imageList release];
    }
    
    imageList = [[NSMutableArray alloc] initWithCapacity:0];
    [imageList setArray:theImageList];
    
    // for test
    //NSIndexSet *theIndex = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 51)];
    //[imageList removeObjectsAtIndexes:theIndex];
    
    toExitThumbnailCreateThread = NO;
    //[NSThread detachNewThreadSelector:@selector(downloadThumbnailImage:) toTarget:self withObject:NULL];
    
    
    // 串行队列。
    // 只有一个线程，加入到队列中的操作按照添加的顺序依次执行。
    // 使用串行队列首先创建一个串行队列，然后调用异步调用方法，在此方法中传入串行队列和线程操作即可自动执行。
    // 下列图片加载过程会按照顺序加载，因为当前队列中只有一个线程。
    
    dispatch_queue_t serialQueue = dispatch_queue_create("myThreadQueue1", DISPATCH_QUEUE_SERIAL);
    for(int i = 0; i < [imageList count]; i++)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // 异步执行队列任务
        dispatch_async(serialQueue,^{
            SDItem *tempItem = [imageList objectAtIndex:i];
            UIImage *tempImage1 = [[NetManager sharedNetManager] downloadThumbnailImage:tempItem.itemPath];
            //UIImage *tempImage1 = [[LctNetController defaultLctNetController] downloadThumbnailImage:tempItem.itemPath];
            //UIImage *tempImage1 = [UIImage imageNamed:@"test.jpg"];
            UIImage *tempImage = [self thumbnailWithImage:tempImage1];
            
            tempItem.thumbnailImage = tempImage;
            
            // 更新UI，此处调用了GCD主线程队列方法
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(toExitThumbnailCreateThread)
                {
                    dispatch_suspend(serialQueue);
                    return;
                }

                NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                if(tempIndexPath)
                {
                    NSArray *indexArray = [NSArray arrayWithObjects:tempIndexPath, nil];
                    [imageCollectionView reloadItemsAtIndexPaths:indexArray];
                }
            });
        });
        
        [pool release];
    }
    dispatch_release(serialQueue);
    
    // 并行队列。
    // 有多个线程，操作进来之后，它会将这些队列安排在可用的处理器上，同时保证先进来的任务优先处理。
    
    /*dispatch_queue_t globalQueue = dispatch_queue_create("myConcurrentThreadQueue1", DISPATCH_QUEUE_CONCURRENT);
    //dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for(int i = 0; i < [imageList count]; i++)
    {
        // 异步执行队列任务
        dispatch_async(globalQueue,^{
            
            if(toExitThumbnailCreateThread)
                return;
            
            SDItem *tempItem = [imageList objectAtIndex:i];
            //UIImage *tempImage = [[LctNetController defaultLctNetController] downloadThumbnailImage:tempItem.itemPath];
            UIImage *tempImage = [[LctNetController defaultLctNetController] downloadThumbnailImage:@"/4311.jpg"];
            tempItem.thumbnailImage = tempImage;
            // 更新UI，此处调用了GCD住线程队列方法
            // 在主线程中更新UI
            //dispatch_sync(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(toExitThumbnailCreateThread)
                {
                    dispatch_suspend(globalQueue);
                    return;
                }
                
                NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray *indexArray = [NSArray arrayWithObjects:tempIndexPath, nil];
                [imageCollectionView reloadItemsAtIndexPaths:indexArray];
            });
        });
    }
    dispatch_release(globalQueue);*/
    
    // GCD串行队列中的任务被安排到一个单一的线程中执行（不是主线程），可以方便的控制执行顺序。
    // GCD并行队列中的任务被安排到在多个线程中执行（前提是使用异步方法），顺序控制相对复杂，但是效率更高。
    //
    // GCD中的一个操作是多线程执行还是单线程执行，取决于当前队列的类型和执行方法，只有队列类型为并行队列并且使用异步调用方法时，才能在多个线程中执行，
    //（如果队列类型是并行队列并且使用同步调用方法时，则会在主线程中执行）。
}

- (void)downloadThumbnailImage:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    for(int i = 0; i < [imageList count]; i++)
    {
        if(toExitThumbnailCreateThread)
            break;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        SDItem *tempItem = [imageList objectAtIndex:i];
        UIImage *tempImage = [[NetManager sharedNetManager] downloadThumbnailImage:tempItem.itemPath];
        //UIImage *tempImage = [[LctNetController defaultLctNetController] downloadThumbnailImage:tempItem.itemPath];
        //UIImage *tempImage = [[LctNetController defaultLctNetController] downloadThumbnailImage:@"/Screen Shot.png"]; // 57.2KB
        //UIImage *tempImage = [[LctNetController defaultLctNetController] downloadThumbnailImage:@"/acc1.png"]; // 377KB
        //UIImage *tempImage = [[LctNetController defaultLctNetController] downloadThumbnailImage:@"/IMG_0038.JPG"]; // 1.15MB
        if(tempImage)
        {
            if(toExitThumbnailCreateThread)
                break;

            tempItem.thumbnailImage = tempImage;
            [self performSelectorOnMainThread:@selector(refreshThumbnailImage:) withObject:[NSNumber numberWithInt:i] waitUntilDone:YES];
        }
        else
            ;
        
        [NSThread sleepForTimeInterval:0.1];
        [pool release];
    }
    
    [NSThread exit];
    [pool release];
}

- (void)refreshThumbnailImage:(id)sender
{
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:[sender intValue] inSection:0];
    NSArray *indexArray = [NSArray arrayWithObjects:tempIndexPath, nil];
    [imageCollectionView reloadItemsAtIndexPaths:indexArray];
}

#pragma mark --- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [imageList count];
}

//定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    if (!cell)
    {
        NSLog(@"无法创建CollectionViewCell时打印，自定义的cell就不可能进来了。");
    }
    
    SDItem *tempItem = [imageList objectAtIndex:indexPath.row];
    UIImage *tempImage = tempItem.thumbnailImage;
    if(tempImage)
        cell.imgView.image = tempImage;
        //cell.imgView.image = [UIImage imageNamed:@"mainUI.png"];
    else
        cell.imgView.image = NULL;//[UIImage imageNamed:@"mainbg.png"];
    //cell.text.text = [NSString stringWithFormat:@"Cell %ld",indexPath.row];
    
    return cell;
}
/*
//头部显示的内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                            UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
    
    [headerView addSubview:_headerView];//头部广告栏
    return headerView;
}
*/
#pragma mark --- UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat theWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake((theWidth - 7.0)/4.0,(theWidth - 7.0)/4.0);
}

//定义每个UICollectionView 的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1,1,0,1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark --- UICollectionViewDelegate

//UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor redColor];
    NSLog(@"选择%ld",(long)indexPath.row);
    [self networkImageShow:indexPath.row];
}

//返回这个UICollectionView是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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

#pragma mark ---

// 展示网络图片
- (void)networkImageShow:(NSUInteger)index
{
    //__weak typeof(self) weakSelf = self;
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:index photoModelBlock:^NSArray *{
        

        /*
        NSArray *networkImages=@[
                                 @"http://www.netbian.com/d/file/20150519/f2897426d8747f2704f3d1e4c2e33fc2.jpg",
                                 @"http://www.netbian.com/d/file/20130502/701d50ab1c8ca5b5a7515b0098b7c3f3.jpg",
                                 @"http://www.netbian.com/d/file/20110418/48d30d13ae088fd80fde8b4f6f4e73f9.jpg",
                                 @"http://www.netbian.com/d/file/20150318/869f76bbd095942d8ca03ad4ad45fc80.jpg",
                                 @"http://www.netbian.com/d/file/20110424/b69ac12af595efc2473a93bc26c276b2.jpg",
                                 
                                 @"http://www.netbian.com/d/file/20140522/3e939daa0343d438195b710902590ea0.jpg",
                                 
                                 @"http://www.netbian.com/d/file/20141018/7ccbfeb9f47a729ffd6ac45115a647a3.jpg",
                                 
                                 @"http://www.netbian.com/d/file/20140724/fefe4f48b5563da35ff3e5b6aa091af4.jpg",
                                 
                                 @"http://www.netbian.com/d/file/20140529/95e170155a843061397b4bbcb1cefc50.jpg"
                                 ];
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:networkImages.count];
        for (NSUInteger i = 0; i< networkImages.count; i++) {
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            pbModel.title = [NSString stringWithFormat:@"这是标题%@",@(i+1)];
            pbModel.desc = [NSString stringWithFormat:@"我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字%@",@(i+1)];
            pbModel.image_HD_U = networkImages[i];
            
            //源frame
            UIImageView *imageV =(UIImageView *) weakSelf.contentView.subviews[i];
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
        }*/
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:[imageList count]];
        for(int i = 0; i < [imageList count]; i++)
        {
            SDItem *tempItem = [imageList objectAtIndex:i];
            //NSString *tempPrefixPath = [[LctNetController defaultLctNetController] baseUrlPath];
            NSString *tempImageURLPath = [NSString stringWithFormat:@"%@/share%@",BASE_URL_STR,tempItem.itemPath];
            //NSString *tempImageURLPath = [NSString stringWithFormat:@"%@/share/%@",tempPrefixPath,@"IMG_0038.JPG"];
            
            PhotoModel *pbModel = [[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            pbModel.title = @"";
            pbModel.desc = @"";
            pbModel.image_HD_U = [tempImageURLPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            //源frame
            //NSIndexPath *theIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            //CollectionViewCell *tempCell = (CollectionViewCell *)[imageCollectionView cellForItemAtIndexPath:theIndexPath];
            //UIImageView *imageV = (UIImageView *)tempCell.imgView;
            //pbModel.sourceImageView = imageV;
            
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [imageV setImage:tempItem.thumbnailImage];
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
            [pbModel release];
        }
        
        return modelsM;
    }];
}

/*
// 本地图片展示
- (void)localImageShow:(NSUInteger)index
{
    __weak typeof(self) weakSelf=self;
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:index photoModelBlock:^NSArray *{
        
        NSArray *localImages = weakSelf.images;
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
        for (NSUInteger i = 0; i< localImages.count; i++) {
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            pbModel.title = [NSString stringWithFormat:@"这是标题%@",@(i+1)];
            pbModel.desc = [NSString stringWithFormat:@"我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字%@",@(i+1)];
            pbModel.image = localImages[i];
            
            //源frame
            UIImageView *imageV =(UIImageView *) weakSelf.contentView.subviews[i];
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
        }
        
        return modelsM;
    }];
}
*/

#pragma mark ---

- (UIImage *)thumbnailWithImage:(UIImage *)image
{
    UIImage *newImage = nil;
    if(nil == image)
        return nil;
    else
    {
        CGFloat newImageSize = 100.0;
        CGSize newSize = CGSizeMake(newImageSize, newImageSize);
        CGSize oldSize = image.size;
        CGRect rect = CGRectZero;
        if(newSize.width/newSize.height > oldSize.width/oldSize.height)
        {
            rect.size.width = newSize.height * oldSize.width / oldSize.height;
            rect.size.height = newSize.height;
            rect.origin.x = (newSize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else
        {
            rect.size.width = newSize.width;
            rect.size.height = newSize.width * oldSize.height / oldSize.width;
            rect.origin.x = 0;
            rect.origin.y = (newSize.height - rect.size.height)/2;
        }
        
        UIGraphicsBeginImageContext(newSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, newSize.width, newSize.height));
        [image drawInRect:rect];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if(newImage)
        return newImage;
    else
        return image;
}

@end
