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

public class StreamrootAssetSource: AssetSource {
    internal let localManifestUrl: URL
    public let dnaClient: DNAClient
    
    public init(entitlement: PlaybackEntitlement, assetId: String, response: HTTPURLResponse? = nil, localManifestUrl: URL, dnaClient: DNAClient) {
        self.localManifestUrl = localManifestUrl
        self.dnaClient = dnaClient
        super.init(entitlement: entitlement, assetId: assetId, response: response)
    }
    
    public override var url: URL {
        return localManifestUrl
    }
}
