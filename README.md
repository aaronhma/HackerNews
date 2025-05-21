# bark for Hacker News

## About

> [!WARNING]
> I'm currently updating this repo with a new way of displaying & fetching stories so your phone won't heat up.

> [!IMPORTANT]
> "bark" is a tentative name. The software is currently in development and features may break.

The best way to read Hacker News. Usage of the software requires acceptance of the LICENSE.

## Building Locally

> [!NOTE]
> A Mac running macOS Sequoia with Xcode 16.2 is required.

1. Clone the repo.

2. Ensure all packages are up-to-date and resolve package dependency issues.

3. Build and enjoy the app!

```
$ sudo pkill usbmuxd # may fix USB connection issues
```

## Known Issues

1. "iCloud Sync isn't available for this device." message
2. Suggested Stories, Shared with You, Saved Stories, Upvoted Stories, Blocked Topics, Blocked Users doesn't work
3. Errors crash the app, remove `fatalError`
