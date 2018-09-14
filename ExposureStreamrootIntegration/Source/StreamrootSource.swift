//
//  StreamrootSource.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-13.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import Player
import StreamrootSDK

public protocol StreamrootSource: MediaSource {
    /// Client driving peer-to-peer traffic
    var dnaClient: DNAClient { get }
}
