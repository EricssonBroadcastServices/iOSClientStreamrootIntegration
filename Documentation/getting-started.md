# Getting Started

Red Bee Managed OTT offers a seamless integration with `Streamroot`s peer-to-peer streaming solution.

## Playback

Media sourcing is handled by creating `StreamrootPlayable`s for the specific assets. Beyond specifying an _assetId_ each source object requires a `DNADelegate`. This delegate needs access to the `Player` object since it will feed the `StreamrootSDK` information regarding the playback state.

```Swift
class PlayerViewController: UIViewController: DNAClientDelegate {
    var player: Player<HLSNative<ExposureContext>>!
    func playbackTime() -> Double {
        return Double(player.playheadPosition / 1000)
    }

    func loadedTimeRanges() -> [NSValue] {
        return player.bufferedRanges.map{ NSValue(timeRange: $0) }
    }

    func updatePeakBitRate(_ bitRate: Double) {
        player.tech.preferredMaxBitrate = Int64(bitRate)
    }
}
```

Client applications can then create `StreamrootPlayable`s for the requested asset type.

```Swift
let vod = StreamrootPlayable(assetId: "redBeeAssetId", dnaDelegate: delegate)

let program = StreamrootPlayable(programId: "redBeeProgramId", channelId: "redBeeChannelId", dnaDelegate: delegate)

let liveChannel = StreamrootPlayable(channelId: "redBeeLiveChannelId", dnaDelegate: delegate)
```

`StreamrootSDK` related configuration should be done before playback is started. For more information see [Streamroot Support](https://support.streamroot.io/).

* `latency(_ latency: Int)`: The difference between current playback time and the live edge
* `property(_ property: String)`: Used to fine-tune various parameters across all your integrations. For more information about it, please refer to this [documentation](https://support.streamroot.io/hc/en-us/articles/360001091914).
* `backendHost(_ backendHost: URL)`: Used to change the place of the Streamroot backend.

```Swift
liveChannel
    .latency(30)
    .property("someProperty")
    .backendHost(myBackendUrlHost)
```

Start playback by feeding `Player<HLSNative<ExposureContext>>` the newly created `StreamrootPlayable`. Please see [Getting Started](https://github.com/EricssonBroadcastServices/iOSClientPlayer/blob/master/Documentation/getting-started.md), [Integrating a Simple Exposure Based Player](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/Documentation/simple-player.md) and [Live and Catchup Playback](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/Documentation/live-and-catchup-playback.md) for in-depth documentation regarding configuration and playback.

```Swift
player.startPlayback(playable: liveChannel)
```

Once playback ends, either by error, completion or termination, it is recommended to stop the `StreamrootSDK`.

```Swift
class PlayerViewController: UIViewController: DNAClientDelegate {
    var player: Player<HLSNative<ExposureContext>>!
    var currentSource: StreamrootSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        player
            .onPlaybackCreated{ [weak self] player, source in
                if let source = source as? StreamrootSource {
                    self?.currentSource = source
                }
            }
            .onError{ [weak self] player, source, error in
                self?.showMessage(title: "\(error.code): " + error.message, message: error.info ?? "")
                (source as? StreamrootSource)?.dnaClient.stop()
            }
            .onPlaybackCompleted{ player, source in
                (source as? StreamrootSource)?.dnaClient.stop()
            }
            .onPlaybackAborted { player, source in
                (source as? StreamrootSource)?.dnaClient.stop()
            }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        currentSource?.dnaClient.stop()
    }
}
```

## Configuring the Reference Applications

The project contains 2 reference implementations, one for tvOS and one for iOS. with separate `Info.plist`s. Client application developers should configure the following properties:

#### Streamroot configuration

`yourStreamrootKey` refers to the key that you will find in the Account section of the Streamroot Dashboard.

```
<key>Streamroot</key>
<dict>
    <key>Key</key>
    <string>yourStreamrootKey</string>
</dict>
```

#### Exposure configuration

Exposure requires a correct environment to be set up before streaming can occur.

* `BaseUrl` refers to the Exposure environment's base url.
* `BusinessUnit` refers to the business unit
* `Customer` refers to the customer unit

Optionally, client developers may specify a `SessionToken` which has been generated in advance. Leaving this field empty will prompt users to log in before playback can start. 

```
<key>Exposure</key>
<dict>
    <key>BaseUrl</key>
    <string>exposureUrl</string>
    <key>BusinessUnit</key>
    <string>businessUnit</string>
    <key>Customer</key>
    <string>customer</string>
    <key>SessionToken</key>
    <string>optionalSessionToken</string>
</dict>
```

