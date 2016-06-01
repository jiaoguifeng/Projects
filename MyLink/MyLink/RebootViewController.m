//
//  RebootViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "RebootViewController.h"

@interface RebootViewController ()
{
    DataContainer *container;
    
    UILabel *sysShutdownLabel;
    UIButton *sysShutdownButton;
    
    UILabel *sysRebootLabel;
    UIButton *sysRebootButton;
}
@end

@implementation RebootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"rebootStr",NULL,@"SystemUIStrings")];
    
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
    NSString *alertStr = @"";
    NSInteger theTag = 0;
    if(sender == sysShutdownButton)
    {
        alertStr = NSLocalizedStringFromTable(@"shutdownDeviceStr",NULL,@"TipStrings");
        theTag = 1;
    }
    else
    {
        alertStr = NSLocalizedStringFromTable(@"rebootDeviceStr",NULL,@"TipStrings");
        theTag = 2;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:alertStr
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                          otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    alert.tag = theTag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSString *actionStr = @"";
        if(alertView.tag == 1)
            actionStr = SYS_Shutdown;
        else if(alertView.tag == 2)
            actionStr = SYS_Reboot;

        NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     Config_System_Reboot,URL_CONFIG_ID,
                                     actionStr,SYS_Param,nil];
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
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:@""];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // Shutdown TitleLabel
    sysShutdownLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"rebootSystemShutdownStr",NULL,@"RebootUIStrings")];
    [container addSubview:sysShutdownLabel];
    
    // Shutdown Button
    sysShutdownButton = [self baseButton:CGRectMake(controlsXDelta, sysShutdownLabel.frame.origin.y + sysShutdownLabel.frame.size.height + controlsYDelta, controlsWidth, 30) title:NSLocalizedStringFromTable(@"turnOffStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [container addSubview:sysShutdownButton];
    
    // Reboot TitleLabel
    sysRebootLabel = [self titleLabel:CGRectMake(controlsXDelta, sysShutdownButton.frame.origin.y + sysShutdownButton.frame.size.height + controlsYDelta*2, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"rebootSystemRebootStr",NULL,@"RebootUIStrings")];
    [container addSubview:sysRebootLabel];
    
    // Reboot Button
    sysRebootButton = [self baseButton:CGRectMake(controlsXDelta, sysRebootLabel.frame.origin.y + sysRebootLabel.frame.size.height + controlsYDelta, controlsWidth, 30) title:NSLocalizedStringFromTable(@"restartStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [container addSubview:sysRebootButton];

    //
    [container setHeight:sysRebootButton.frame.origin.y + sysRebootButton.frame.size.height + controlsYDelta*2];
}

@end
