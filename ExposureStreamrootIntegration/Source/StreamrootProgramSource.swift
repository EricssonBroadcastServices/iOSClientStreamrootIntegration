//
//  StreamrootProgramSource.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-12.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import ExposurePlayback
import Exposure
import StreamrootSDK

/// Specialized `MediaSource` used for playback of a specific program on a channel using peer-to-peer through `Streamroot`.
///
/// Inherits start time `PlayFrom` behavior from `ProgramSource`
public class StreamrootProgramSource: ProgramSource {
    internal let localManifestUrl: URL
    
    /// Client driving peer-to-peer traffic
    public let dnaClient: DNAClient
    
    /// Creates a new `StreamrootProgramSource`
    ///
    /// - parameter entitlement: `PlaybackEntitlement` used to play the program
    /// - parameter assetId: The id for the program
    /// - parameter channelId: The channel Id on which the program plays
    /// - parameter response: HTTP response received when requesting the entitlement
    public init(entitlement: PlaybackEntitlement, assetId: String, channelId: String, response: HTTPURLResponse? = nil, localManifestUrl: URL, dnaClient: DNAClient) {
        self.localManifestUrl = localManifestUrl
        self.dnaClient = dnaClient
        super.init(entitlement: entitlement, assetId: assetId, channelId: channelId, response: response)
    }
    
    public override var url: URL {
        return localManifestUrl
    }
}

