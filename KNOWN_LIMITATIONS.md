# Known Limitations

### `StreamrootSDK.framework`
Streamroot SDK comes with a few [known limitations](https://support.streamroot.io/hc/en-us/articles/115004620414-Apple-Compatibilities). Please advice the Streamroot documentation for up to date information.

Version `3.3.0`
* Absolute URLs in playlists are not supported. The SDK will fallback to the default CDN delivery.
* The framework doesn’t support bitcode currently.

* `Reported`: 2.0.92


### `EMP-11751`
Full Support for dependency management using `Carthage` is not available due to a bug in the `GCDWebServer` build definitions.

* `Reported`: 2.0.92
* `Workaround`: Use Cocoapods for managing `StreamroodSDK` dependencies and `Carthage` for *RedBee Media* related modules.
