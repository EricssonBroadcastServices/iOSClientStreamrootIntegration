//
//  StreamrootAssetPlayable.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-11.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import ExposurePlayback
import Exposure
import StreamrootSDK

public struct StreamrootAssetPlayable: Playable {
    public let assetId: String
    public let dnaTrigger: DNATrigger
    
    public init(assetId: String, dnaDelegate: DNAClientDelegate) {
        self.assetId = assetId
        self.dnaTrigger = DNAClient
            .builder()
            .dnaClientDelegate(dnaDelegate)
            .latency(30)
    }
    
    public func prepareSource(environment: Environment, sessionToken: SessionToken, callback: @escaping (ExposureSource?, ExposureError?) -> Void) {
        prepareSourceWithResponse(environment: environment, sessionToken: sessionToken) { source, error, response in
            callback(source, error)
        }
    }
    
    public func prepareSourceWithResponse(environment: Environment, sessionToken: SessionToken, callback: @escaping (ExposureSource?, ExposureError?, HTTPURLResponse?) -> Void) {
        entitlementProvider.requestEntitlement(assetId: assetId, using: sessionToken, in: environment) { entitlement, exposureError, response in
            if let value = entitlement {
                do {
                    let dnaClient = try self.dnaTrigger.contentId(self.assetId).start(value.mediaLocator)
                    guard let localManifestPath = dnaClient.manifestLocalURLPath, let localManifestUrl = URL(string: localManifestPath) else {
                        let dnaError = StreamrootIntegrationError.unableToGenerateLocalManifestUrl(path: dnaClient.manifestLocalURLPath)
                        callback(nil, ExposureError.generalError(error: dnaError), response)
                        return
                    }
                    
//                    let source = StreamrootAssetSource(entitlement: value, assetId: self.assetId, localManifestUrl: localManifestUrl, dnaClient: dnaClient)
//                    source.response = response
//                    callback(source, nil, response)
                }
                catch {
                    callback(nil, ExposureError.generalError(error: error), response)
                }
                
                
            }
            else if let exposureError = exposureError {
                callback(nil,exposureError,response)
            }
        }
    }
    
    
    internal var entitlementProvider: StreamrootAssetEntitlementProvider = ExposureEntitlementProvider()
    
    internal struct ExposureEntitlementProvider: StreamrootAssetEntitlementProvider {
        func requestEntitlement(assetId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) {
            Entitlement(environment: environment,
                        sessionToken: sessionToken)
                .vod(assetId: assetId)
                .request()
                .validate()
                .response{ callback($0.value, $0.error, $0.response) }
        }
    }
}
