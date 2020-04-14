//Hooks are from https://github.com/opa334/Choicy/blob/master/ChoicySB/TweakSB.x
//This code implements new features to https://github.com/lint/PasteAndGo/, so please make sure to go star their repo as well! ;)

#import "Ibiza.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NSString * bundleIdentifier = @"com.amodrono.tweak.ibiza";

static NSDictionary *prefs;
static BOOL previouslyEnabled;
static BOOL enabled;

static int searchEngine;

static void reloadPrefs() {
    if ([NSHomeDirectory()isEqualToString:@"/var/mobile"]) {
        CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) {
            prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

            if (!prefs) {
                prefs = [NSDictionary new];
            }
            CFRelease(keyList);
        }
    } else {
        prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
    }
}

//MARK: Preferences
static void updatePreferences() {
	// Refresh dictionary
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();
	//BOOL shouldRefresh = (([prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : TRUE) == false && enabled != ([prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : TRUE) == false);

    enabled = [prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : TRUE;
	searchEngine = [([prefs objectForKey:@"searchEngine"] ?: @(0)) integerValue];

	previouslyEnabled = enabled;

}

static void sendNotification(NSString * message) {
	if (!isNotDebugMode) {
		UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
		content.title = @"Ibiza debug mode";
		content.body = [NSString stringWithFormat:@"Message says: %@.", message];
		content.badge = 0;

		UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

		UNNotificationRequest *requesta = [UNNotificationRequest requestWithIdentifier:@"com.amodrono.tweak.ibiza.notify" content:content trigger:trigger];

		[UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:requesta withCompletionHandler:nil];
		isNotDebugMode = NO;
	}
} 

%group iOS13Up

%hook SBIconView

%new
-(bool) isBrowser:(NSString *)bundleID { //hardcoded function because I'm tired and lazy
	if ([bundleID isEqualToString:@"com.apple.mobilesafari"]
		|| [bundleID isEqualToString:@"org.mozilla.ios.Firefox"]
		|| [bundleID isEqualToString:@"org.mozilla.ios.Focus"]
		|| [bundleID isEqualToString:@"com.google.chrome.ios"]
		|| [bundleID isEqualToString:@"com.brave.ios.browser"]
		|| [bundleID isEqualToString:@"com.microsoft.msedge"]) {
			return true;
		}

	return false;
}

%new
//Get the URL scheme of any of the supported apps using the bundleID.
-(NSString *) getUrlScheme:(NSString *)bundleID {

	//MARK: Browsers
	if ([bundleID isEqualToString:@"org.mozilla.ios.Firefox"]) {
		return @"firefox://open-url?url=";
	} else if ([bundleID isEqualToString:@"org.mozilla.ios.Focus"]) {
		return @"firefox-focus://open-url?url=";
	} else if ([bundleID isEqualToString:@"com.google.chrome.ios"]) {
		return @"googlechrome://";
	} else if ([bundleID isEqualToString:@"com.brave.ios.browser"]) {
		return @"brave://open-url?url=";
	} else if ([bundleID isEqualToString:@"com.microsoft.msedge"]) {
		return @"microsoft-edge-";
	} 

	//MARK: Reddit and Apollo
	else if ([bundleID isEqualToString:@"com.reddit.Reddit"]) {
		return @"reddit";
	} else if ([bundleID isEqualToString:@"com.christianselig.Apollo"]) {
		return @"apollo";
	}

	//MARK: App Store, Cydia, Sileo, and Zebra
	else if ([bundleID isEqualToString:@"com.apple.AppStore"]) {
		return @"itms-apps://search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?media=software&term=";
	} else if ([bundleID isEqualToString:@"com.saurik.cydia"]) {
		return @"cydia://url/https://cydia.saurik.com/api/share#?source=";
	} else if ([bundleID isEqualToString:@"org.coolstar.sileo"]) {
		return @"sileo://source/";
	} else if ([bundleID isEqualToString:@"xyz.willy.zebra"]) {
		return @"zbra://sources/add/";
	}

	//MARK: Twitter
	else if ([bundleID isEqualToString:@"com.atebits.Tweetie2"]) {
		return @"twitter://user?screen_name=semiak_";
	}

	return @""; //app is not supported. Only case where this is not true is in Safari, which doesnt have any url scheme.
}

-(NSArray *) applicationShortcutItems {

	NSArray * orig = %orig;

	if (enabled) {

		//MARK: App bundle and bundle IDs
		NSString * bundleID;
		NSBundle * tweakBundle = [NSBundle bundleWithPath:@"/Library/Application Support/Ibiza.bundle"];

		if ([self respondsToSelector:@selector(applicationBundleIdentifier)]){
			bundleID = [self applicationBundleIdentifier];
		} else if ([self respondsToSelector:@selector(applicationBundleIdentifierForShortcuts)]){
			bundleID = [self applicationBundleIdentifierForShortcuts];
		}

		if(!bundleID){
			return orig;
		}

		if ([self isBrowser:bundleID]) {
			
			UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard]; 
			NSString *pbStr = [pasteBoard string];
			
			if (pbStr){
				
				NSURL *url = [NSURL URLWithString:[pbStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
				
				if ([[UIApplication sharedApplication] canOpenURL:url]) { //Item copied is a valid URL

					SBSApplicationShortcutItem* pasteAndGoItem = [[%c(SBSApplicationShortcutItem) alloc] init];
					pasteAndGoItem.localizedTitle = [tweakBundle localizedStringForKey:@"PASTEANDGO" value:@"" table:nil];
					pasteAndGoItem.localizedSubtitle = [NSString stringWithFormat: @"Go to: %@", [[[pbStr stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""] mutableCopy]]; //link without http:// and https://

					pasteAndGoItem.type = [NSString stringWithFormat:@"%@.item", bundleIdentifier];

					sendNotification([NSString stringWithFormat:@"%@, %@, %@", bundleID, pbStr, pasteAndGoItem.type]);

					return [orig arrayByAddingObject:pasteAndGoItem];

				} else { //Item copied is not an URL

					SBSApplicationShortcutItem* pasteAndGoItem = [[%c(SBSApplicationShortcutItem) alloc] init];
					pasteAndGoItem.localizedTitle = [tweakBundle localizedStringForKey:@"PASTEANDSEARCH" value:@"" table:nil];
					pasteAndGoItem.localizedSubtitle = [NSString stringWithFormat: @"Search \"%@\"", pbStr];

					pasteAndGoItem.type = [NSString stringWithFormat:@"%@.item", bundleIdentifier];

					sendNotification([NSString stringWithFormat:@"%@, %@, %@", bundleID, pbStr, pasteAndGoItem.type]);

					return [orig arrayByAddingObject:pasteAndGoItem];

				}
			}
		}
	}

	return orig;
}

+(void) activateShortcut:(SBSApplicationShortcutItem*)item withBundleIdentifier:(NSString*)bundleID forIconView:(id)iconView{
	
	if ([[item type] isEqualToString:[NSString stringWithFormat:@"%@.item", bundleIdentifier]]){
		
		UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard]; 
		NSString *pbStr = [pasteBoard string];
		
		if (pbStr) {

			NSString * urlScheme;

			NSURL * finalURL = [NSURL URLWithString:[pbStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

			sendNotification([NSString stringWithFormat:@"%@, %@, %@, %s", urlScheme, pbStr, finalURL, [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:pbStr]] ? "Cake" : "No Cake"]);

			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:pbStr]]) {

				pbStr = [[[pbStr stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""] mutableCopy];

				finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlScheme, [pbStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];

			} else { //item is not an url, so we just need to search it.
				
				if ([bundleID isEqualToString:@"com.google.chrome.ios"]) {

					pbStr = [[[pbStr stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""] mutableCopy];
					finalURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@www.google.com/search?q=%@", urlScheme, [[pbStr stringByReplacingOccurrencesOfString:@" " withString:@"+"] mutableCopy]]]; //convert to google link
				
				} else {
					
					finalURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@https://www.google.com/search?q=%@", urlScheme, [[pbStr stringByReplacingOccurrencesOfString:@" " withString:@"+"] mutableCopy]]]; //convert to google link
				
				}

			}
			
			[[UIApplication sharedApplication] openURL:finalURL];

		}
	}

	%orig;
}

%end

%end


%group iOS12OrDown

%hook SBUIAppIconForceTouchControllerDataProvider

%new
-(bool) isBrowser:(NSString *)bundleID { //hardcoded function because I'm tired and lazy
	if ([bundleID isEqualToString:@"com.apple.mobilesafari"]
		|| [bundleID isEqualToString:@"org.mozilla.ios.Firefox"]
		|| [bundleID isEqualToString:@"org.mozilla.ios.Focus"]
		|| [bundleID isEqualToString:@"com.google.chrome.ios"]
		|| [bundleID isEqualToString:@"com.brave.ios.browser"]
		|| [bundleID isEqualToString:@"com.microsoft.msedge"]) {
			return true;
		}

	return false;
}

-(NSArray *) applicationShortcutItems {
	
	NSArray *orig = %orig;

	//MARK: App bundle and bundle IDs
	NSString * bundleID;
	NSBundle * tweakBundle = [NSBundle bundleWithPath:@"/Library/Application Support/Ibiza.bundle"];

	if (!bundleID){
		return orig;
	}
	
	if ([self isBrowser:bundleID]) {
		
		UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard]; 
		NSString *pbStr = [pasteBoard string];
		
		if (pbStr){
			
			NSURL *url = [NSURL URLWithString:[pbStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			
			if ([[UIApplication sharedApplication] canOpenURL:url]) {
				
				SBSApplicationShortcutItem* pasteAndGoItem = [[%c(SBSApplicationShortcutItem) alloc] init];
				pasteAndGoItem.localizedTitle = [tweakBundle localizedStringForKey:@"PASTEANDGO" value:@"" table:nil];
				pasteAndGoItem.localizedSubtitle = [NSString stringWithFormat: @"Go to: %@", [[[pbStr stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""] mutableCopy]]; //link without http:// and https://

				pasteAndGoItem.type = [NSString stringWithFormat:@"%@.item", bundleIdentifier];

				if (!orig){
					return @[pasteAndGoItem];
				} else {
					return [orig arrayByAddingObject:pasteAndGoItem];
				}

			} else { //Item copied is not an URL

				SBSApplicationShortcutItem* pasteAndGoItem = [[%c(SBSApplicationShortcutItem) alloc] init];
				pasteAndGoItem.localizedTitle = [tweakBundle localizedStringForKey:@"PASTEANDSEARCH" value:@"" table:nil];
				pasteAndGoItem.localizedSubtitle = [NSString stringWithFormat: @"Search \"%@\"", pbStr];

				pasteAndGoItem.type = [NSString stringWithFormat:@"%@.item", bundleIdentifier];

				if (!orig) {
					return @[pasteAndGoItem];
				} else {
					return [orig arrayByAddingObject:pasteAndGoItem];
				}

			}
		}
	}

	return orig;
}

/*
%new
-(bool) isInArray:(NSArray)array item:(NSString)item {
	for (NSString * currentString in array) {

		if ([currentString isEqualToString:item]) {
			return true;
		}
		return false;

	}
*/

%end


%hook SBUIAppIconForceTouchController

-(void) appIconForceTouchShortcutViewController:(id)arg1 activateApplicationShortcutItem:(SBSApplicationShortcutItem*)item {
	
	if ([[item type] isEqualToString:[NSString stringWithFormat:@"%@.item", bundleIdentifier]]){
		
		UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard]; 
		NSString *pbStr = [pasteBoard string];

		NSString * bundleID;

		if (!bundleID) {
			return %orig;
		}
		
		if (pbStr) {

			NSString * urlScheme;

			if ([bundleID isEqualToString:@"org.mozilla.ios.Firefox"]) {
				urlScheme = @"firefox://open-url?url=";
			} else if ([bundleID isEqualToString:@"org.mozilla.ios.Focus"]) {
				urlScheme = @"firefox-focus://open-url?url=";
			} else if ([bundleID isEqualToString:@"com.google.chrome.ios"]) {
				urlScheme = @"googlechrome://";
			} else if ([bundleID isEqualToString:@"com.brave.ios.browser"]) {
				urlScheme = @"brave://open-url?url=";
			} else if ([bundleID isEqualToString:@"com.microsoft.msedge"]) {
				urlScheme = @"microsoft-edge-";
			} else {
				urlScheme = @"";
			}

			NSURL * finalURL = [NSURL URLWithString:[pbStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:pbStr]]) {

				pbStr = [[[pbStr stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""] mutableCopy];
				finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlScheme, [pbStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];

			} else { //item is not an url, so we just need to search it.
				
				if ([bundleID isEqualToString:@"com.google.chrome.ios"]) {
					pbStr = [[[pbStr stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""] mutableCopy];
					finalURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@www.google.com/search?q=%@", urlScheme, [[pbStr stringByReplacingOccurrencesOfString:@" " withString:@"+"] mutableCopy]]]; //convert to google link
				} else {
					finalURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@https://www.google.com/search?q=%@", urlScheme, [[pbStr stringByReplacingOccurrencesOfString:@" " withString:@"+"] mutableCopy]]]; //convert to google link
				}

			}
			
			[[UIApplication sharedApplication] openURL:finalURL];

		}
	}

	%orig;
}

%end

%end

%ctor{

	//MARK: Preferences
	updatePreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePreferences, CFSTR("com.amodrono.tweak.ibiza.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	//Detect iOS version
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")){
		%init(iOS13Up); //
	} else {
		%init(iOS12OrDown);
	}
}
