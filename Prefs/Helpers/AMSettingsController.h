// SettingsController.h

#import <Preferences/PSListController.h>
#import "HeaderView.h"
#import "NSTask.h"

@interface AMSettingsController : PSListController <UIScrollViewDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, retain) NSMutableDictionary *settings;
@property (nonatomic, retain) NSMutableDictionary *requiredToggles;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) HeaderView *headerView;
@property (nonatomic, retain) UIColor *themeColor;
@property (nonatomic, assign) BOOL navbarThemed;
@property (nonatomic, retain) UIBarButtonItem *respringButton;

- (void)layoutHeader;
- (NSBundle *)resourceBundle;
- (void)respring;
- (void)respringUtil;

@end
