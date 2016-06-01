//
//  VWWWaterView.h
//  Water Waves
//


#import <UIKit/UIKit.h>

@protocol VWWWaterViewDelegate

- (void)waterViewClicked;

@end

@interface VWWWaterView : UIView
{
}

@property (nonatomic, weak) id<VWWWaterViewDelegate> delegate;
@property (nonatomic, assign) BOOL isNeedAnimation;

@end
