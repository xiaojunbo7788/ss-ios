
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXZY_CommonPayAlertView : UIView

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, copy) void(^onClick)(int type);
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) BOOL isShowRecharge;
- (void)showInView:(UIView *)view;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
