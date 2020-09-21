//
//  ZYShareView.h
//  
//
//  Created by ZZY on 16/3/28.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WXYZ_ShareState) {
    WXYZ_ShareStateQQ = 0,
    WXYZ_ShareStateQQZone = 1,
    WXYZ_ShareStateWeChat = 2,
    WXYZ_ShareStateWeChatTimeLine = 3,
    WXYZ_ShareStateAll = 4
};

typedef NS_ENUM(NSInteger, WXYZ_ShareProductionState) {/**分享作品类型*/
    WXYZ_ShareProductionBook = 1,/**分享书籍*/
    WXYZ_ShareProductionComic = 2,/**分享漫画*/
    WXYZ_ShareProductionAudio = 3,/**分享有声*/
};

typedef void(^ClickHandler)(WXYZ_ShareState shareState);

@interface WXYZ_ShareView : UIView

@property (nonatomic, copy) ClickHandler clickHandler;

/**
 *  显示\隐藏
 */
- (void)show;

- (void)hidden;

@end
