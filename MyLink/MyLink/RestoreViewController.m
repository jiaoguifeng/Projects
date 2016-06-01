//
//  RestoreViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "RestoreViewController.h"

@interface RestoreViewController ()
{
    DataContainer *container;
    
    UILabel *resetFactoryLabel;
    UIButton *resetButton;
}
@end

@implementation RestoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"restoreStr",NULL,@"SystemUIStrings")];
    
    [self setupUIControls];
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

#pragma mark - Button Actions

- (void)buttonAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedStringFromTable(@"restoreDeviceStr",NULL,@"TipStrings")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                          otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     Config_System_Restore,URL_CONFIG_ID,
                                     nil];
        [[Utility defaultUtility] hudShowWithTitle:@""];
        [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
            if(data)
            {
            }
            
            [[Utility defaultUtility] hudClose];
        }];
    }
}

#pragma mark - Init UI Controls

- (void)setupUIControls
{
    CGRect sFrame = self.view.bounds;
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:NSLocalizedStringFromTable(@"restoreDefaultResetStr",NULL,@"RestoreDefaultsUIStrings")];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // Reset to factory default settings TitleLabel
    resetFactoryLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"restoreDefaultResetFactoryStr",NULL,@"RestoreDefaultsUIStrings")];
    [container addSubview:resetFactoryLabel];
    
    // Reset to factory default settings Button
    resetButton = [self baseButton:CGRectMake(controlsXDelta, resetFactoryLabel.frame.origin.y + resetFactoryLabel.frame.size.height + controlsYDelta, controlsWidth, 30) title:NSLocalizedStringFromTable(@"resetStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [container addSubview:resetButton];
    
    //
    [container setHeight:resetButton.frame.origin.y + resetButton.frame.size.height + controlsYDelta*2];
}

@end
