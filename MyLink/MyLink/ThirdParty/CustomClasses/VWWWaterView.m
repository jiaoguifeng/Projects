//
//  VWWWaterView.m
//  Water Waves
//


#import "VWWWaterView.h"

@interface VWWWaterView ()
{
    UIColor *_currentWaterColor;
    
    float _currentLinePointY;
    
    float a;
    float b;
    
    BOOL jia;
    
    BOOL needFillColor;
}
@end


@implementation VWWWaterView

@synthesize delegate,isNeedAnimation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        a = 1.5;
        b = 0;
        jia = NO;
        needFillColor = NO;
        isNeedAnimation = NO;
        
        //_currentWaterColor = [UIColor colorWithRed:86/255.0f green:202/255.0f blue:139/255.0f alpha:0.5];
        _currentWaterColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2];
        _currentLinePointY = frame.size.height/2 + 5;
        
        [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.bounds.size.width*0.5;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleTap];
        
        /*UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + (self.bounds.size.width - 100)/2,
                                                                       self.bounds.origin.y + (self.bounds.size.height - 20)/2,
                                                                       100, 20)];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.text = @"00:00:00";
        [self addSubview:infoLabel];*/
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesBegan...");
    needFillColor = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesMoved...");
    needFillColor = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesEnded...");
    needFillColor = NO;
}

- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesCancelled...");
    needFillColor = NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    //NSLog(@"Clicked...");
    [delegate waterViewClicked];
}

- (void)animateWave
{
    if (jia) {
        a += 0.01;
    }else{
        a -= 0.01;
    }
    
    
    if (a<=1) {
        jia = YES;
    }
    
    if (a>=1.5) {
        jia = NO;
    }
    
    
    b+=0.1;
    
    if(!isNeedAnimation)
    {
        a= 0;
        b= 0;
    }
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(isNeedAnimation)
        _currentWaterColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    else
        _currentWaterColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_currentWaterColor CGColor]);
    
    float y=_currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    for(float x=0;x<=rect.size.width;x++){
        y= a * sin( x/180*M_PI + 4*b/M_PI ) * 5 + _currentLinePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, _currentLinePointY);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);

    UIBezierPath *path1 = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    path1.lineWidth = 10;
    [_currentWaterColor set];
    [path1 stroke];
    
    UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    path2.lineWidth = 5;
    [[UIColor whiteColor] set];
    [path2 stroke];

    if(needFillColor)
    {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3].CGColor);
        CGContextAddArc(context, rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2, rect.size.width/2- 5, 0, 2 * M_PI, 1);
        CGContextFillPath(context);
    }
    
}


@end
