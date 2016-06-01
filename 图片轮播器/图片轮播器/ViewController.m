//
//  ViewController.m
//  图片轮播器
//
//  Created by jiaoguifeng on 8/21/15.
//  Copyright (c) 2015 jiaoguifeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) NSArray *imageNameList;
@property(weak, nonatomic) IBOutlet UIPageControl *pageControl;

//自动图片轮播
@property(nonatomic, strong) NSTimer *animationTimer;

- (IBAction)turnPage:(UIPageControl *)sender;
@end

@implementation ViewController

#pragma mark - 懒加载
- (NSArray *)imageNameList
{
    if (_imageNameList == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"imageNameList" ofType:@"plist"];
        
        NSArray *list = [NSArray arrayWithContentsOfFile:path];
        
        _imageNameList = list;
    }
    
    return _imageNameList;
}

#pragma mark - 系统方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for (int i = 0; i < self.imageNameList.count; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        CGFloat picX = self.view.frame.size.width * i;
        CGFloat picY = 0;
        CGFloat picW = self.view.frame.size.width;
        CGFloat picH = self.view.frame.size.height;
        
        imageView.image = [UIImage imageNamed:self.imageNameList[i]];
        imageView.frame = CGRectMake(picX, picY, picW, picH);
        
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.imageNameList.count, self.view.frame.size.height);
    
     //self.scrollView有一个非常重要的属性self.scrollView.pagingEnabled = YES,这个设置成YES,才有一页一页翻的效果，否则就像拖拽一样，效果不好。
    
    //设置pageControl的基本属性，如page的个数，pageIndicator的颜色，当前选中pageIndicator
    self.pageControl.numberOfPages = self.imageNameList.count;
    self.pageControl.pageIndicatorTintColor = [UIColor blueColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    
    //初始化显示为第一页，self.pageControl.currentPage = 0,同时把self.scrollView滚动到第一个的位置
    self.pageControl.currentPage = 0;
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animationTimerDidFired:) userInfo:nil repeats:YES];
    self.animationTimer = timer;
    [self.animationTimer fire];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if ([self.animationTimer isValid])
    {
        [self.animationTimer invalidate];
    }
    self.animationTimer = nil;
    
}
#pragma mark - UISrollView Delegate方法

   //这个方法也可以，但是感觉效率会不高
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"%f",self.scrollView.contentOffset.x);
//    int currentPage = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
//    
//    self.pageControl.currentPage = currentPage;
//
//}

  //这个方法也可以，这个效率会高
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%f",self.scrollView.contentOffset.x);
    int currentPage = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    
    self.pageControl.currentPage = currentPage;
    
    
    [self.animationTimer invalidate];
}

#pragma mark - UIPageControl单击事件
- (IBAction)turnPage:(UIPageControl *)sender
{
    NSInteger page = self.pageControl.currentPage;
    
    [self.scrollView scrollRectToVisible:CGRectMake(page * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
}

#pragma mark - 自动轮播实现
- (void)animationTimerDidFired:(NSTimer *)timer
{
    NSLog(@"%f,%f,%f",self.scrollView.contentOffset.x,self.scrollView.contentSize.width,self.scrollView.frame.size.width);
    CGFloat offsetX = 0;
    //这里如果用这个条件self.scrollView.contentOffset.x == self.scrollView.contentSize.width会出现一张空白页，而用self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame)则问题解决，原因暂时不明确，需要好好研究一下
    if (self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame) == self.scrollView.contentSize.width)
    {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y);
    }
    else
    {
        offsetX = self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame);
    }
    
    CGPoint newOffset = CGPointMake(offsetX, self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
    
    
    NSLog(@"%f",self.scrollView.contentOffset.x);
    int currentPage = (int)(newOffset.x / self.scrollView.frame.size.width);
    
    self.pageControl.currentPage = currentPage;

}

@end
