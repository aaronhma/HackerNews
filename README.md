# bark for Hacker News

## About

>[!IMPORTANT]
>"bark" is a tentative name. The software is currently in development and features may break.

The best way to read Hacker News. Usage of the software requires acceptance of the LICENSE.

## Building Locally

0. A Mac running macOS Sonoma or later with Xcode 15 or later is **required**. For iOS 18 features, use macOS Sequoia + Xcode 16.

1. Clone the repo.

2. Confirm that `SwiftSoup` is up-to-date and resolve package dependency issues.

3. Build and enjoy the app!


```
$ sudo pkill usbmuxd
```

## Known Issues

1. "iCloud Sync isn't available for this device." message
2. Text Size & Font doesn't work
3. Suggested Stories, Shared with You, Saved Stories, Upvoted Stories, Blocked Topics, Blocked Users doesn't work
4. Scrolling too fast may cause the app to crash
5. Tapping to open a story, then leaving quickly may cause the story to not be saved in the user's history
6. Search doesn't work
7. Errors crash the app, remove `fatalError`
8. Tapping some `NavigationLink`s doesn't do anything
9. The user can't sign in to their Hacker News account, the button doesn't do anything
