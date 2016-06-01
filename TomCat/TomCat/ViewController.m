//
//  ViewController.m
//  TomCat
//
//  Created by jiaoguifeng on 8/10/15.
//  Copyright (c) 2015 jiaoguifeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

//不想被外界知道的变量设置在私有变量里
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCat;
@property(nonatomic, strong) NSDictionary *picCounts;

//action方法
- (IBAction)milk:(UIButton *)sender;
- (IBAction)cymbal:(UIButton *)sender;
- (IBAction)eat:(UIButton *)sender;
- (IBAction)fart:(UIButton *)sender;
- (IBAction)pie:(UIButton *)sender;
- (IBAction)scratch:(UIButton *)sender;
- (IBAction)knockout:(UIButton *)sender;
- (IBAction)stomach:(UIButton *)sender;
- (IBAction)foot_left:(UIButton *)sender;
- (IBAction)angry:(UIButton *)sender;
- (IBAction)foot_right:(UIButton *)sender;



@end

@implementation ViewController

//改变状态栏状态，在控制器中执行
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


//隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
 //重写arrayCount的get方法，这就是所谓的懒加载(第一次使用的时候才加载)
- (NSDictionary *)picCounts
{
    if (_picCounts == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"tom" ofType:@"plist"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        _picCounts = dict;
    }
    
    return _picCounts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

  //封装重复使用的代码，简化程序
- (void)animationStartName:(NSString *)name
{
    if (self.imageViewCat.isAnimating)
    {
        [self.imageViewCat stopAnimating];
        self.imageViewCat.animationImages = nil;
    }
    
    //获取特定名字的图片组的个数
    NSInteger picCount = [self.picCounts[name] integerValue];
    
    //1.将要显示的图片加载到一个NSAarray中
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < picCount; i++)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%02d",name,i] ofType:@"jpg"];
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [arrayM addObject:image];
    }
    
    //2.将要显示的图片数组赋值给animationImages属性
    self.imageViewCat.animationImages = arrayM;
    
    //3.设置持续时间
    self.imageViewCat.animationDuration = self.imageViewCat.animationImages.count * 0.1;
    
    //4.设置重复次数
    self.imageViewCat.animationRepeatCount = 1;
    
    //5.开始执行动画
    [self.imageViewCat startAnimating];
    
    //6.执行完动画，执行setAnimationImages:属性方法，清理内存
    [self.imageViewCat performSelector:@selector(setAnimationImages:) withObject:nil afterDelay:self.imageViewCat.animationImages.count * 0.1];
}

- (IBAction)milk:(UIButton *)sender
{
    [self animationStartName:@"drink"];
}

- (IBAction)cymbal:(UIButton *)sender
{
    [self animationStartName:@"cymbal"];
}

- (IBAction)eat:(UIButton *)sender
{
    [self animationStartName:@"eat"];
}

- (IBAction)fart:(UIButton *)fart
{
    [self animationStartName:@"drink"];
}

- (IBAction)pie:(UIButton *)sender
{
    [self animationStartName:@"pie"];
}

- (IBAction)scratch:(UIButton *)sender
{
    [self animationStartName:@"scratch"];
}

- (IBAction)knockout:(UIButton *)sender
{
    [self animationStartName:@"knockout"];
}

- (IBAction)stomach:(UIButton *)sender
{
    [self animationStartName:@"stomach"];
}

- (IBAction)foot_left:(UIButton *)sender
{
    [self animationStartName:@"foot_left"];
}

- (IBAction)foot_right:(UIButton *)sender
{
    [self animationStartName:@"foot_right"];
}

- (IBAction)angry:(UIButton *)sender
{
    [self animationStartName:@"angry"];
}


@end
