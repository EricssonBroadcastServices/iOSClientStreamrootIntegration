[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Streamroot Compatible](https://img.shields.io/badge/streamroot-compatible-12a5ed.svg?style=flat)](https://streamroot.io)

# Exposure Streamroot Integration

* [Features](#features)
* [License](https://github.com/EricssonBroadcastServices/iOSClientExposureStreamrootIntegration/blob/master/LICENSE)
* [Requirements](#requirements)
* [Installation](#installation)
* Documentation
    - [Getting Started](https://github.com/EricssonBroadcastServices/iOSClientExposureStreamrootIntegration/getting-started.md)
* [Release Notes](#release-notes)
* [Upgrade Guides](#upgrade-guides)
* [Known Limitations](https://github.com/EricssonBroadcastServices/iOSClientExposureStreamrootIntegration/blob/master/KNOWN_LIMITATIONS.md)

## Features

- [x] Peer-to-Peer streaming

## Requirements

* `iOS` 9.0+
* `tvOS` 10.2+
* `Swift` 4.2+
* `Xcode` 10.0+

* Framework dependencies
    - [`Player`](https://github.com/EricssonBroadcastServices/iOSClientPlayer)
    - [`Exposure`](https://github.com/EricssonBroadcastServices/iOSClientExposure)
    - [`ExposurePlayback`](https://github.com/EricssonBroadcastServices/iOSClientExposure)
    - [`StreamrootSDK`](https://support.streamroot.io/hc/en-us/sections/115000729153-iOS-and-tvOS) version: [`3.4.0`](https://sdk.streamroot.io/ios/3.4.0/StreamrootSDK.framework.zip)
    - [`Sentry`](https://github.com/getsentry/sentry-cocoa)
    - [`Starscream`](https://github.com/daltoniam/Starscream)
    - Exact versions described in [Cartfile](https://github.com/EricssonBroadcastServices/iOSClientExposureStreamrootIntegration/blob/master/Cartfile)

## Installation

### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependency graph without interfering with your `Xcode` project setup. `CI` integration through [fastlane](https://github.com/fastlane/fastlane) is also available.

Install *Carthage* through [Homebrew](https://brew.sh) by performing the following commands:

```sh
$ brew update
$ brew install carthage
```

Once *Carthage* has been installed, you need to create a `Cartfile` which specifies your dependencies. Please consult the [artifacts](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md) documentation for in-depth information about `Cartfile`s and the other artifacts created by *Carthage*.

```sh
github "EricssonBroadcastServices/iOSClientExposureStreamrootIntegration"
```

Running `carthage update` will fetch your dependencies and place them in `/Carthage/Checkouts`. You either build the `.framework`s and drag them in your `Xcode` or attach the fetched projects to your `Xcode workspace`.

Finally, make sure you add the `.framework`s to your targets *General -> Embedded Binaries* section.

## Release Notes
Release specific changes can be found in the [CHANGELOG](https://github.com/EricssonBroadcastServices/iOSClientExposureStreamrootIntegration/blob/master/CHANGELOG.md).

## Upgrade Guides
The procedure to apply when upgrading from one version to another depends on what solution your client application has chosen to integrate `ExposurePlayback`.

Major changes between releases will be documented with special [Upgrade Guides](https://github.com/EricssonBroadcastServices/iOSClientExposureStreamrootIntegration/blob/master/UPGRADE_GUIDE.md).

### Carthage
Updating your dependencies is done by running  `carthage update` with the relevant *options*, such as `--use-submodules`, depending on your project setup. For more information regarding dependency management with `Carthage` please consult their [documentation](https://github.com/Carthage/Carthage/blob/master/README.md) or run `carthage help`.
