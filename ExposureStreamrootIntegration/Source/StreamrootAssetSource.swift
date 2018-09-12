//
//  StreamrootAssetSource.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-11.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import ExposurePlayback
import Exposure
import StreamrootSDK

/// Specialized `MediaSource` used for playback of *Vod* assets using peer-to-peer through `Streamroot`.
///
/// Inherits start time `PlayFrom` behavior from `AssetSource`
public class StreamrootAssetSource: AssetSource {
    internal let localManifestUrl: URL
    
    /// Client driving peer-to-peer traffic
    public let dnaClient: DNAClient
    
    /// Creates a new `StreamrootAssetSource`
    ///
    /// - parameter entitlement: `PlaybackEntitlement` used to play the asset
    /// - parameter assetId: The id for the asset
    /// - parameter response: HTTP response received when requesting the entitlement
    public init(entitlement: PlaybackEntitlement, assetId: String, response: HTTPURLResponse? = nil, localManifestUrl: URL, dnaClient: DNAClient) {
        self.localManifestUrl = localManifestUrl
        self.dnaClient = dnaClient
        super.init(entitlement: entitlement, assetId: assetId, response: response)
    }
    
    public override var url: URL {
        return localManifestUrl
    }
}
