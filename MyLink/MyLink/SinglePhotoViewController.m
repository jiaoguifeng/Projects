//
//  SinglePhotoViewController.m
//  EasyWIFI
//
//  Created by chen on 5/22/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "SinglePhotoViewController.h"
#import "VIPhotoView.h"

@interface SinglePhotoViewController ()
{
    VIPhotoView *photoView;
}

@end

@implementation SinglePhotoViewController

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
    [textFieldButton setFrame:CGRectMake(5, 10, 50, 60)];
    //[textFieldButton setImage:[UIImage imageNamed:@"titleBarBackButton.png"] forState:UIControlStateNormal];
    [textFieldButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [textFieldButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [textFieldButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [textFieldButton setTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
    [textFieldButton addTarget:self action:@selector(photoViewBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textFieldButton];
    
    /*UILabel *theTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 18, 200, 30)];
    theTitleLabel.textAlignment = NSTextAlignmentCenter;
    theTitleLabel.textColor = [UIColor whiteColor];
    theTitleLabel.text = [imagePath lastPathComponent];
    theTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:theTitleLabel];
    [theTitleLabel release];*/
    
    CGRect photoViewRect = self.view.bounds;
    photoViewRect.origin.y += 60;
    photoViewRect.size.height -= 60;
    
    UIImage *image = [UIImage imageNamed:imagePath];
    photoView = [[VIPhotoView alloc] initWithFrame:photoViewRect andImage:image];
    photoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.view addSubview:photoView];
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

- (void)setImagePath:(NSString *)imgPath
{
    if(imagePath)
        imagePath = nil;
    imagePath = imgPath;
}

- (void)photoViewBackAction:(UIButton *)button
{
    /*if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];*/

    [photoView removeFromSuperview];
    photoView = nil;
    imagePath = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
