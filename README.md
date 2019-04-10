# CustomBrowserKit

[![CI Status](http://img.shields.io/travis/ky1vstar/CustomBrowserKit.svg?style=flat)](https://travis-ci.org/ky1vstar/CustomBrowserKit)
[![Version](https://img.shields.io/cocoapods/v/CustomBrowserKit.svg?style=flat)](http://cocoapods.org/pods/CustomBrowserKit)
[![License](https://img.shields.io/cocoapods/l/CustomBrowserKit.svg?style=flat)](http://cocoapods.org/pods/CustomBrowserKit)
[![Platform](https://img.shields.io/cocoapods/p/CustomBrowserKit.svg?style=flat)](http://cocoapods.org/pods/CustomBrowserKit)

CustomBrowserKit is a library designed to provide ability to open links in browser besides Safari to your awesome app's users. It is written in Objective-C and extended with Swift.

## Supported browsers

CustomBrowserKit currently supports:

* [Google Chrome](https://itunes.apple.com/app/id535886823)
* [Firefox](https://itunes.apple.com/app/id989804926)
* [Opera Mini](https://itunes.apple.com/app/id363729560)
* [UC Browser](https://itunes.apple.com/app/id1048518592)
* [Puffin Web Browser](https://itunes.apple.com/app/id472937654)
* [Yandex Browser](https://itunes.apple.com/app/id483693909)
* Opening links in `SFSafariViewController` if iOS version is 9.0+
* Safari

## Requirements

* Xcode 8.0+
* iOS 8.0+
* Swift 3.1+

## Installation

CustomBrowserKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CustomBrowserKit'
```

Also, starting with iOS 9.0 you must declare the URL schemes of external apps you want to launch. There are only two available browsers you can use without declaring appropriate URL schemes: `BKBrowserInAppSafari` and `BKBrowserSafari`. So if you want to use another browsers you must add the [LSApplicationQueriesSchemes](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html#//apple_ref/doc/plist/info/LSApplicationQueriesSchemes) key to your app's Info.plist file. You are not required to add all of this schemes below, only those you want to let your users to use. But it is important to add BOTH schemes for browsers which have two of them. For example if you want to use Google Chrome, you have to declare both `googlechrome` and `googlechromes` URL schemes.



| Browser            | URL Schemes                         |
|--------------------|-------------------------------------|
| Google Chrome      | `googlechrome`<br />`googlechromes` |
| Firefox            | `firefox`                           |
| Opera              | `opera`                             |
| UC Browser         | `ucbrowser`                         |
| Puffin Web Browser | `puffin`<br />`puffins`             |
| Yandex Browser     | `yandexbrowser-open-url`            |

## Usage

Make sure to import the framework header: `#import <CustomBrowserKit/CustomBrowserKit.h>` for Objective-C or `import CustomBrowserKit` for Swift.

### Obtaining information about browser
**Objective-C**
```objectivec
BKBrowser browser = BKBrowserFirefox;
NSString *browserName = BKBrowserGetName(browser); // @"Firefox"
UIImage *browserLogo = BKBrowserGetThumbnail(browser); // UIImage of size 100x100
```

**Swift**
```swift
let browser = BKBrowser.firefox
let browserName = browser.name // "Firefox"
let browserLogo = browser.thumbnail // UIImage of size 100x100
```

### Obtaining list of available browsers
**Objective-C**
```objectivec
for (NSNumber *wrappedBrowser in BKManager.availableBrowsers) {
BKBrowser browser = (BKBrowser)wrappedBrowser.intValue;
    NSLog(@"%@ is available", BKBrowserGetName(browser));
}
```

**Swift**
```swift
for browser in BKManager.availableBrowsers {
    print("\(browser.name) is available")
}
```

### Opening links in specific browser
**Objective-C**
```objectivec
NSURL *url = [NSURL URLWithString:@"https://google.com/"];

if ([BKManager openURL:url withBrowser:BKBrowserOpera]) {
    NSLog(@"did open url successfully");
} else {
    NSLog(@"did fail to open url");
}
```

**Swift**
```swift
let url = URL(string: "https://google.com/")!

if BKManager.open(url, with: .opera) {
    print("did open url successfully")
} else {
    print("did fail to open url")
}
```

### Opening links in specific browser with fallback to another browser if needed
**Objective-C**
```objectivec
NSURL *url = [NSURL URLWithString:@"https://google.com/"];

// BKManager will try to open URL in Opera. If Opera Mini turns out to not be installed or available, BKManager will try to open URL in Google Chrome.
if ([BKManager openURL:url withBrowser:BKBrowserOpera fallbackToBrowser:BKBrowserChrome]) {
    NSLog(@"did open url successfully");
} else { // if both Opera Mini and Google Chrome are not available
    NSLog(@"did fail to open url");
}
```

**Swift**
```swift
let url = URL(string: "https://google.com/")!

// BKManager will try to open URL in Opera. If Opera Mini turns out to not be installed or available, BKManager will try to open URL in Google Chrome.
if BKManager.open(url, with: .opera, fallbackTo: .chrome) {
    print("did open url successfully")
} else { // if both Opera Mini and Google Chrome are not available
    print("did fail to open url")
}
```

### Saving `BKBrowser` to `NSUserDefaults`
**Objective-C**
```objectivec
BKBrowser browser = BKBrowserUCBrowser;
NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;

// saving
[userDefaults setObject:BKBrowserGetIdentifier(browser) forKey:@"savedBrowser"];

// restoring
NSString *browserIdentifier = [userDefaults stringForKey:@"savedBrowser"];
BKBrowser savedBrowser;
if (browserIdentifier) {
    savedBrowser = BKBrowserFromIdentifier(browserIdentifier);
} else {
    savedBrowser = BKBrowserInAppSafari;
}
```

**Swift**
```swift
let browser = BKBrowser.ucBrowser
let userDefault = UserDefaults.standard

// saving
userDefault.set(browser.identifier, forKey: "savedBrowser")

// restoring
let savedBrowser: BKBrowser
if let browserIdentifier = userDefault.string(forKey: savedBrowser) {
    savedBrowser = BKBrowser(identifier: browserIdentifier)
} else {
    savedBrowser = .inAppSafari
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. Example project includes both Objective-C and Swift versions.

## License

CustomBrowserKit is available under the MIT license. See the LICENSE file for more info.

