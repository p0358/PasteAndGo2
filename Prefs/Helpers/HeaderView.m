// HeaderView.m

#import "HeaderView.h"
#import "../Settings.h"
#import "../../Ibiza.h"

@import CoreText;

@implementation HeaderView

- (id)initWithSettings:(NSDictionary *)settings {
	self = [super init];

	if (self) {
		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enableDebugMode:)]; //allow enabling debug mode
		self.settings = settings;

		self.backgroundColor = settings[@"headerColor"] ?: settings[@"tintColor"];

		self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, self.bounds.size.width, 118)];
		[self addSubview:self.contentView];

		self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.bounds.size.width, 32)];
		self.subtitleLabel.text = settings[@"author"];
		self.subtitleLabel.font = [UIFont boldSystemFontOfSize:[settings[@"subtitleFontSize"] floatValue] ?: 20];
		self.subtitleLabel.textColor = [UIColor colorWithRed: 0.769 green: 0.769 blue: 0.769 alpha: 1.0];
		[self.contentView addSubview:self.subtitleLabel];

		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, self.bounds.size.width, 50)];
		self.titleLabel.text = settings[@"name"];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:[settings[@"titleFontSize"] floatValue] ?: 35];
		self.titleLabel.textColor = [UIColor colorWithRed: 0.769 green: 0.769 blue: 0.769 alpha: 1.0];
		[self.contentView addSubview:self.titleLabel];

		self.versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 43, self.bounds.size.width, 50)];
		self.versionLabel.text = settings[@"version"];
		self.versionLabel.font = [UIFont boldSystemFontOfSize:[settings[@"versionLabelFontSize"] floatValue] ?: 25];
		self.versionLabel.textColor = [UIColor grayColor];
		self.versionLabel.userInteractionEnabled = YES;
		[self.versionLabel addGestureRecognizer:tap];

		[self.contentView addSubview:self.versionLabel];

		if (@available(iOS 13.0, *)) {
			if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
				if (self.settings[@"darkHeaderColor"]) self.backgroundColor = self.settings[@"darkHeaderColor"];
				if (self.settings[@"darkTextColor"]) {
					self.titleLabel.textColor = self.settings[@"darkTextColor"];
					self.subtitleLabel.textColor = [UIColor colorWithRed: 0.565 green: 0.565 blue: 0.565 alpha: 1.0];
				}
			} else {
				self.backgroundColor = self.settings[@"headerColor"] ?: self.settings[@"tintColor"];
				self.titleLabel.textColor = self.settings[@"textColor"] ?: [UIColor whiteColor];
				self.subtitleLabel.textColor = [UIColor colorWithRed: 0.769 green: 0.769 blue: 0.769 alpha: 1.0];
			}
		} else {
			self.backgroundColor = self.settings[@"headerColor"] ?: self.settings[@"tintColor"];
			self.titleLabel.textColor = self.settings[@"textColor"] ?: [UIColor whiteColor];
			self.subtitleLabel.textColor = [UIColor colorWithRed: 0.769 green: 0.769 blue: 0.769 alpha: 1.0];
		}
	}

	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	CGFloat statusBarHeight = 20;
	if (@available(iOS 13.0, *)) {
		statusBarHeight = self.window.windowScene.statusBarManager.statusBarFrame.size.height;
	} else {
		statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
	}

	CGFloat offset = statusBarHeight + [self _viewControllerForAncestor].navigationController.navigationController.navigationBar.frame.size.height;

	self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, (frame.size.height - offset)/2 - self.contentView.frame.size.height/2 + offset - 10, frame.size.width, self.contentView.frame.size.height);

	self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, frame.size.width, self.titleLabel.frame.size.height);

	self.subtitleLabel.frame = CGRectMake(self.subtitleLabel.frame.origin.x, self.subtitleLabel.frame.origin.y, frame.size.width, self.subtitleLabel.frame.size.height);

	self.versionLabel.frame = CGRectMake(self.versionLabel.frame.origin.x, self.versionLabel.frame.origin.y, frame.size.width, self.versionLabel.frame.size.height);
}

- (CGFloat)contentHeightForWidth:(CGFloat)width {
    return 200;
}

// Shamelessly stolen from Skitty's Pokebox. Please support him as well! :)
- (void)enableDebugMode:(UITapGestureRecognizer *)recognizer {

	if (isNotDebugMode) {

		UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
		content.title = @"Ibiza";
		content.body = @"Debug mode disabled!";
		content.badge = 0;

		UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

		UNNotificationRequest *requesta = [UNNotificationRequest requestWithIdentifier:@"com.amodrono.tweak.ibiza.notify" content:content trigger:trigger];

		[UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:requesta withCompletionHandler:nil];
		isNotDebugMode = NO;
	
	} else {

		UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
		content.title = @"Ibiza";
		content.body = @"Enabled debug mode!\nIf you enabled this by accident, you can disable it by tapping the version label again.";
		content.badge = 0;

		UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

		UNNotificationRequest *requesta = [UNNotificationRequest requestWithIdentifier:@"com.amodrono.tweak.ibiza.notify" content:content trigger:trigger];

		[UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:requesta withCompletionHandler:nil];

		isNotDebugMode = YES;
	
	}
	
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	if (@available(iOS 13.0, *)) {
		if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
			if (self.settings[@"darkHeaderColor"]) self.backgroundColor = self.settings[@"darkHeaderColor"];
			if (self.settings[@"darkTextColor"]) {
				self.titleLabel.textColor = self.settings[@"darkTextColor"];
				self.subtitleLabel.textColor = [UIColor colorWithRed: 0.565 green: 0.565 blue: 0.565 alpha: 1.0];
			}
		} else {
			self.backgroundColor = self.settings[@"headerColor"] ?: self.settings[@"tintColor"];
			self.titleLabel.textColor = self.settings[@"textColor"] ?: [UIColor whiteColor];
			self.subtitleLabel.textColor = [UIColor colorWithRed: 0.769 green: 0.769 blue: 0.769 alpha: 1.0];
		}
	} else {
		self.backgroundColor = self.settings[@"headerColor"] ?: self.settings[@"tintColor"];
		self.titleLabel.textColor = self.settings[@"textColor"] ?: [UIColor whiteColor];
		self.subtitleLabel.textColor = [UIColor colorWithRed: 0.769 green: 0.769 blue: 0.769 alpha: 1.0];
	}
}

@end
