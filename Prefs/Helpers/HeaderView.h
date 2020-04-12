// HeaderView.h

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface HeaderView : UIView

@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UILabel *versionLabel;

@property (nonatomic, assign) CGFloat elasticHeight;

- (id)initWithSettings:(NSDictionary *)settings;
- (CGFloat)contentHeightForWidth:(CGFloat)width;

@end
