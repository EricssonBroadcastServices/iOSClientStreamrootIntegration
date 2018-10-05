# Known Limitations

### `StreamrootSDK.framework`
Streamroot SDK comes with a few [known limitations](https://support.streamroot.io/hc/en-us/articles/115004620414-Apple-Compatibilities). Please advice the Streamroot documentation for up to date information.

Version `3.3.0`
* Absolute URLs in playlists are not supported. The SDK will fallback to the default CDN delivery.
* The framework doesn’t support bitcode currently.

* `Reported`: 2.0.93


### `EMP-11863`
*Carthage*, using `xcodebuild` and `Xcode10`s new build system, fails to resolve and link the correct dependencies when `ExposurePlayback` is included as a dependency.

* `Reported`: 2.0.93
* `Workaround`: Use the old (legacy) build system. See `File -> Workspace Settings... -> Build Settings` in Xcode.
