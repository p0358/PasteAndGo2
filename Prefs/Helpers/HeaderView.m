// HeaderView.m

#import "HeaderView.h"
#import "../Settings.h"

@import CoreText;

@implementation HeaderView

- (id)initWithSettings:(NSDictionary *)settings {
	self = [super init];

	if (self) {
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

		self.versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 43, self.bounds.size.width, 50)];
		self.versionLabel.text = settings[@"version"];
		self.versionLabel.font = [UIFont boldSystemFontOfSize:[settings[@"versionLabelFontSize"] floatValue] ?: 25];
		self.versionLabel.textColor = [UIColor grayColor];
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
