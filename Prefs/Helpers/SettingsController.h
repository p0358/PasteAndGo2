// SettingsController.h

#import <Preferences/PSListController.h>
#import <UserNotifications/UserNotifications.h>
#import "HeaderView.h"

@interface SPSettingsController : PSListController <UIScrollViewDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, retain) NSMutableDictionary *settings;
@property (nonatomic, retain) NSMutableDictionary *requiredToggles;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) HeaderView *headerView;
@property (nonatomic, retain) UIColor *themeColor;
@property (nonatomic, assign) BOOL navbarThemed;

- (void)layoutHeader;
- (NSBundle *)resourceBundle;

@end
