// IBSettingsController.m

#import "IBSettingsController.h"

@implementation IBSettingsController

- (void)viewDidLoad {
	[super viewDidLoad];

	//mmm I wonder what does this do???
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(definitelyNotARickRoll:)];

	// Pikachu image
	self.pikaView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headerView.bounds.size.height - 20, self.headerView.bounds.size.width - 120, 35, 35)];
	self.pikaView.image = [UIImage imageWithContentsOfFile:[[self resourceBundle] pathForResource:@"mario-mushroom" ofType:@"png"]];
	self.pikaView.userInteractionEnabled = YES;

	[self.pikaView addGestureRecognizer:tap];
	[self.headerView addSubview:self.pikaView];

	// Setup notifications
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;

	// Not sure if this is needed, but better leave it to be safe.
	[[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
	}];
}

- (void)layoutHeader {
	[super layoutHeader];
	self.pikaView.frame = CGRectMake(310, self.headerView.bounds.size.height - 25, 35, 35);
}

// "Hack" to allow notifications in the foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
	completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/amodrono"] options:@{} completionHandler:nil];
}

- (void)definitelyNotARickRoll:(UITapGestureRecognizer *)recognizer {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.youtube.com/watch?v=dQw4w9WgXcQ"] options:@{} completionHandler:nil];
}

- (NSBundle *)resourceBundle {
	return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/IbizaPrefs.bundle"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	if (@available(iOS 13.0, *)) {
		if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
			return UIStatusBarStyleDarkContent;
		} else {
			return UIStatusBarStyleLightContent;
		}
	}
	return UIStatusBarStyleLightContent;
}

@end
