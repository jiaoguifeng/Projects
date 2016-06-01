//
//  ViewController.m
//  chaojicaitu
//
//  Created by jiaoguifeng on 8/19/15.
//  Copyright (c) 2015 jiaoguifeng. All rights reserved.
//

#import "ViewController.h"
#import "Questions.h"

@interface ViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *questions;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIButton *cover;

@property (weak, nonatomic) IBOutlet UILabel *lblIndex;
@property (weak, nonatomic) IBOutlet UIButton *btnScore;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnImageIcon;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *tipBtn;

@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;

- (IBAction)nextPicture:(UIButton *)sender;
- (IBAction)bigImage:(UIButton *)sender;
- (IBAction)btnImageIconAction:(UIButton *)sender;
- (IBAction)tipAction:(UIButton *)sender;
@end

@implementation ViewController

#pragma mark - 懒加载数据
- (NSArray *)questions
{
    if (_questions == nil)
    {
        _questions = [Questions questions];
    }
    return _questions;
}

- (UIButton *)cover
{
    if (_cover == nil)
    {
        _cover = [[UIButton alloc] initWithFrame:self.view.frame];
        
        _cover.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        [self.view addSubview:_cover];
        
        _cover.alpha = 0.0;
        
        [_cover addTarget:self action:@selector(bigImage:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    return _cover;
}

#pragma mark - 下一题
- (void)setUpBasicInfo:(Questions*)question
{
    self.lblIndex.text = [NSString stringWithFormat:@"%ld/%ld",(self.index + 1),self.questions.count];
    self.lblTitle.text = question.title;
    
    //UIButton设置图片需要用这个setImage:forState, 与状态有关，所以必须用带状态的函数。
    [self.btnImageIcon setImage:[UIImage imageNamed:question.icon] forState:UIControlStateNormal];//.imageView.image = [UIImage imageNamed:question.icon];
    
    self.nextBtn.enabled = (self.index < self.questions.count - 1);
}

- (void)nextPicture
{
    //index加1
    self.index ++;

    //判断是否到达最后一页
    if (self.index == self.questions.count)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"恭喜通关" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    Questions *question = self.questions[self.index];
    
    //设置基本数据
    [self setUpBasicInfo:question];
    
    [self createAnswerBtn:question];
    
    [self createOptionsBtn:question];
    
}

- (IBAction)nextPicture:(UIButton *)sender
{
    [self nextPicture];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.index = -1;
        //[self nextPicture];
        [self performSelector:@selector(nextPicture) withObject:nil afterDelay:0.2];
    }
}
#pragma mark - 放大缩小
- (IBAction)bigImage:(UIButton *)sender
{
    if (self.cover.alpha == 0)
    {
        //将self.btnImageIcon放在所以subview的最前面
        [self.view bringSubviewToFront:self.btnImageIcon];
        
        CGFloat iconX = 0;
        CGFloat iconW = self.view.frame.size.width;
        CGFloat iconH = iconW;
        CGFloat iconY = (self.view.frame.size.height - iconH) * 0.5;
        
        //执行动画，放大imageIcon，并且设置透明度。
        [UIView animateWithDuration:1.0 animations:^{
            self.btnImageIcon.frame = CGRectMake(iconX, iconY, iconW, iconH);
            self.cover.alpha = 1.0;
        }];
    }
    else
    {
        [UIView animateWithDuration:1.0 animations:^{
            self.btnImageIcon.frame = CGRectMake(75, 95, 225, 225);
            
            //将UIButton的透明度设置为0，就相当于设置setHidden = YES
            self.cover.alpha = 0.0;
            
            
        }];
    }
    
}

- (IBAction)btnImageIconAction:(UIButton *)sender
{
    [self bigImage:nil];
}

#pragma mark - 提示
- (IBAction)tipAction:(UIButton *)sender
{
    //提示减去1000分
    [self changeScores:-1000];
    
    //清除答案按钮上面的所有文字信息
    for (UIButton *btn in self.answerView.subviews)
    {
        [btn setTitle:@"" forState:UIControlStateNormal];
    }
    
    //获取模型数据
    Questions *question = self.questions[self.index];
    
    //获取正确答案的第一个字
    NSString *firstCharcter = [question.answer substringToIndex:1];
    
    //重新显示客户已选择的optionView的按钮的状态
    for (UIButton *optionBtn in self.optionsView.subviews)
    {
        optionBtn.hidden = NO;
    }
    
    
    //判断答案的第一个字和候选按钮的title，如果相等，则执行optionClick：事件
    for (UIButton *btn in self.optionsView.subviews)
    {
        if ([btn.currentTitle isEqualToString:firstCharcter])
        {
            [self optionsClick:btn];
            break;
        }
    }
}

- (void)changeScores:(NSInteger)score
{
    NSInteger currentScores = self.btnScore.titleLabel.text.integerValue;
    
    currentScores = currentScores + score;
    
    NSString *scoresTitle = [NSString stringWithFormat:@"%ld",currentScores];
    
    [self.btnScore setTitle:scoresTitle forState:UIControlStateNormal];
    
    if (currentScores > 0 && (currentScores - 1000) < 0)
    {
        self.tipBtn.enabled = NO;
    }
    else
    {
        self.tipBtn.enabled = YES;
    }

}
#pragma mark - 创建答案按钮

- (void)createAnswerBtn:(Questions *)question
{
    //移除上次创建的所有subView
    for (UIView *view in self.answerView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSInteger answerBtnCount = [question.answer length];
    
    CGFloat btnW = 35;
    CGFloat btnH = 35;
    CGFloat margin = 10;
    CGFloat btnY = (self.answerView.frame.size.height - btnH) * 0.5;
 
    for (int i = 0; i < answerBtnCount; i++)
    {
        CGFloat btnX = (self.answerView.frame.size.width - btnW *answerBtnCount - margin * (answerBtnCount - 1)) * 0.5 + i * (btnW + margin);
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.answerView addSubview:btn];
        
        [btn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)answerClick:(UIButton*)button
{
    //清除文字
    [button setTitle:@"" forState:UIControlStateNormal];
    
    //显示在optionView中tag值一样的button按钮
    for (UIButton *option in self.optionsView.subviews)
    {
        if (option.tag == button.tag)
        {
            option.hidden = NO;
            break;
        }
    }
    
    //从答案正确或错误的文字颜色恢复到正常状态的颜色。
    [self setAnswerBtnColor:[UIColor blackColor]];
    
    //恢复self.optionView与用户的交互
    [self.optionsView setUserInteractionEnabled:YES];
}

#pragma mark - 创建答案按钮
- (void)createOptionsBtn:(Questions *)question
{
    [self.optionsView setUserInteractionEnabled:YES];
    
    NSInteger optionsCount = question.options.count;
    
    if (self.optionsView.subviews.count != optionsCount)
    {
        CGFloat btnW = 35;
        CGFloat btnH = 35;
        CGFloat margin = 10;
        int column = 7;
        //最初始的y坐标
        CGFloat y = 0;
        //最初始的x坐标
        CGFloat x = (self.view.frame.size.width - column * btnW - (column - 1) *margin) * 0.5;
        
        for (int i = 0; i < optionsCount; i++)
        {
            UIButton *btn = [[UIButton alloc] init];
            
            CGFloat btnX = x + (btnW + margin) * (i % column);
            CGFloat btnY = y + (btnH + margin) * (i / column);
            
            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
            
            [self.optionsView addSubview:btn];
            
            //设置标题和标题颜色
            [btn setTitle:question.options[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            //设置一个标记，方便后续操作
            btn.tag = i;
            
            [btn addTarget:self action:@selector(optionsClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    //如果21各按钮已经存在，则只修改其标题即可，提高效率。
    int i = 0;
    for (UIButton *btn in self.optionsView.subviews)
    {
        [btn setTitle:question.options[i] forState:UIControlStateNormal];
        btn.hidden = NO;
        i++;
    }
}

- (void)optionsClick:(UIButton *)button
{
    button.hidden = YES;
    
    for (UIButton *answer in self.answerView.subviews)
    {
        //NSString *title = [answer titleForState:UIControlStateNormal];
        //一下两种方式都可以，主要要点是获取特定状态下的title
        
        //if (answer.currentTitle.length == 0)
        if ([answer titleForState:UIControlStateNormal].length == 0)
        {
            //设置button的title一定要用带状态的方法。
            [answer setTitle:button.currentTitle forState:UIControlStateNormal];
            answer.tag = button.tag;
            break;
        }
    }
    
    
    //判断答案按钮是否已经填满
    BOOL isFull = YES;
    NSMutableString *userAnswer = [NSMutableString string];
    for (UIButton *btn in self.answerView.subviews)
    {
        if (btn.currentTitle.length == 0)
        {
            isFull = NO;
            break;
        }
        else
        {
            //拼接用户选择的答案
            [userAnswer appendString:btn.currentTitle];
        }
    }
    
    //如果答案按钮都有文字，则让用户禁止继续按键，同时判断答案是否正确。
    if (isFull)
    {
        //禁止用户与View交互
        [self.optionsView setUserInteractionEnabled:NO];
        
        //判断答案的正确性
        Questions *model = self.questions[self.index];
        
        if ([userAnswer isEqualToString:model.answer])
        {
            [self setAnswerBtnColor:[UIColor blueColor]];
            [self changeScores:100];
            [self performSelector:@selector(nextPicture) withObject:nil afterDelay:0.5];
        }
        else
        {
            [self setAnswerBtnColor:[UIColor blueColor]];
        }
        
    }
}

- (void)setAnswerBtnColor:(UIColor *)color
{
    for (UIButton *btn in self.answerView.subviews)
    {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}
#pragma mark - 系统方法
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     //初始化图片
    self.index = -1;
    [self nextPicture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
