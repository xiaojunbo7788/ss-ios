#import "WXYZ_ShareViewCell.h"

@interface WXYZ_ShareViewCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleView;

@end

@implementation WXYZ_ShareViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    [self addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(5);
    }];
    
    [self addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.iconView.mas_bottom);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(30);
    }];
}

- (void)setSourceArray:(NSArray *)sourceArray
{
    _sourceArray = sourceArray;
    
    self.iconView.image = [UIImage imageNamed:[sourceArray objectOrNilAtIndex:1]];
    self.titleView.text = [sourceArray objectOrNilAtIndex:0];
}

#pragma mark - getter

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.userInteractionEnabled = YES;
    }
    return _iconView;
}

- (UILabel *)titleView
{
    if (!_titleView) {
        _titleView = [[UILabel alloc] init];
        _titleView.backgroundColor = [UIColor whiteColor];
        _titleView.textColor = kGrayTextColor;
        _titleView.font = kFont12;
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.userInteractionEnabled = NO;
    }
    return _titleView;
}

@end
