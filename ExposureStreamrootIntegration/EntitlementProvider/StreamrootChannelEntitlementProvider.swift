//
//  StreamrootChannelEntitlementProvider.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-12.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import Exposure

/// Provider for channel based entitlements from Exposure
internal protocol StreamrootChannelEntitlementProvider {
    func requestEntitlement(channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void)
}
