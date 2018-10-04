//
//  StreamrootPlayable.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-12.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import ExposurePlayback
import Exposure
import StreamrootSDK

/// Defines a `Playable` which will prepare a *Streamroot* compatible `MediaSource`
public class StreamrootPlayable: Playable {
    /// Returns the unique asset identifier for the media.
    ///
    /// For VoD assets, this will be the assetId.
    ///
    /// For channel assets, this will be the channelId.
    ///
    /// For program assets, this will be the programId.
    public var assetId: String {
        switch media {
        case .asset(id: let id): return id
        case .channel(id: let id): return id
        case .program(id: let id, channelId: _): return id
        }
    }
    
    /// If the playable is of type `Program` or `Channel`, this property returns the `channelId`.
    ///
    /// `nil` otherwise
    public var channelId: String? {
        switch media {
        case .channel(id: let id): return id
        case .program(id: _, channelId: let id): return id
        default: return nil
        }
    }
    
    /// If the playable is of type `Program`, this property returns the `programId`.
    ///
    /// `nil` otherwise
    public var programId: String? {
        switch media {
        case .program(id: let id, channelId: _): return id
        default: return nil
        }
    }
    
    /// Returns the asset type for the playable.
    public var mediaType: String {
        switch media {
        case .asset(id: _): return "ASSET"
        case .channel(id: _): return "CHANNEL"
        case .program(id: _, channelId: _): return "PROGRAM"
        }
    }
    
    /// `DNAClient` build trigger. Use this property to configure the *StreamrootSDK* before the playable is fed to the `Player` object.
    internal var dnaTrigger: DNATrigger
    
    /// Set the latency
    /// - parameter latency: The difference between current playback time and the live edge
    /// - returns: Playable which will configure a *Streamroot* compatible `MediaSource`
    ///
    public func latency(_ latency: Int) -> StreamrootPlayable {
        dnaTrigger = dnaTrigger.latency(latency)
        return self
    }
    
    /// Set the property
    /// - parameter property: Used to fine-tune various parameters across all your integrations.
    /// For more information about it, please refer to this https://support.streamroot.io/hc/en-us/articles/360001091914.
    /// - returns: Playable which will configure a *Streamroot* compatible `MediaSource`
    ///
    public func property(_ property: String) -> StreamrootPlayable {
        dnaTrigger = dnaTrigger.property(property)
        return self
    }
    
    /// Set the backendHost
    /// - parameter backendHost: Used to change the place of the Streamroot backend.
    /// - returns: Playable which will configure a *Streamroot* compatible `MediaSource`
    ///
    public func backendHost(_ backendHost: URL) -> StreamrootPlayable {
        dnaTrigger = dnaTrigger.backendHost(backendHost)
        return self
    }
    
    /// Creates an asset playable used for streaming *VoD* content
    ///
    /// - parameter assetId: The id for the VoD media
    /// - parameter dnaDelegate: Delegate which handles *Streamroot* functionality.
    public init(assetId: String, dnaDelegate: DNAClientDelegate) {
        media = .asset(id: assetId)
        dnaTrigger = DNAClient.builder().dnaClientDelegate(dnaDelegate)
    }

    /// Creates a channel playable used for streaming live content
    ///
    /// - parameter channelId: The id for the live channel media
    /// - parameter dnaDelegate: Delegate which handles *Streamroot* functionality.
    public init(channelId: String, dnaDelegate: DNAClientDelegate) {
        media = .channel(id: channelId)
        dnaTrigger = DNAClient.builder().dnaClientDelegate(dnaDelegate)
    }
    
    /// Creates a program playable used for streaming specific programs on a channel
    ///
    /// - parameter programId: The id for the program
    /// - parameter channelId: The id for the channel
    /// - parameter dnaDelegate: Delegate which handles *Streamroot* functionality.
    public init(programId: String, channelId: String, dnaDelegate: DNAClientDelegate) {
        media = .program(id: programId, channelId: channelId)
        dnaTrigger = DNAClient.builder().dnaClientDelegate(dnaDelegate)
    }
    
    /// Tracks playbale type
    internal let media: Media
    internal enum Media {
        case asset(id: String)
        case channel(id: String)
        case program(id: String, channelId: String)
    }
    
    public func prepareSource(environment: Environment, sessionToken: SessionToken, callback: @escaping (ExposureSource?, ExposureError?) -> Void) {
        prepareSourceWithResponse(environment: environment, sessionToken: sessionToken) { source, error, response in
            callback(source, error)
        }
    }
    
    public func prepareSourceWithResponse(environment: Environment, sessionToken: SessionToken, callback: @escaping (ExposureSource?, ExposureError?, HTTPURLResponse?) -> Void) {
        switch media {
        case .asset(id: let assetId):
            entitlementProvider.requestEntitlement(assetId: assetId, using: sessionToken, in: environment) { entitlement, exposureError, response in
                if let value = entitlement {
                    do {
                        let reEncodedUrl = value.mediaLocator
                        let dnaClient = try self.dnaTrigger.contentId(assetId).start(reEncodedUrl)
                        guard let localManifestPath = dnaClient.manifestLocalURLPath, let localManifestUrl = URL(string: localManifestPath) else {
                            let dnaError = StreamrootIntegrationError.unableToGenerateLocalManifestUrl(path: dnaClient.manifestLocalURLPath)
                            callback(nil, ExposureError.generalError(error: dnaError), response)
                            return
                        }
                        
                        let source = StreamrootAssetSource(entitlement: value, assetId: assetId, response: response, localManifestUrl: localManifestUrl, dnaClient: dnaClient)
                        
                        callback(source, nil, response)
                    }
                    catch {
                        callback(nil, ExposureError.generalError(error: error), response)
                    }
                    
                    
                }
                else if let exposureError = exposureError {
                    callback(nil,exposureError,response)
                }
            }
        case .channel(id: let channelId):
            entitlementProvider.requestEntitlement(channelId: channelId, using: sessionToken, in: environment) { entitlement, exposureError, response in
                if let value = entitlement {
                    do {
                        let reEncodedUrl = value.mediaLocator
                        let dnaClient = try self.dnaTrigger.contentId(channelId).start(reEncodedUrl)
                        guard let localManifestPath = dnaClient.manifestLocalURLPath, let localManifestUrl = URL(string: localManifestPath) else {
                            let dnaError = StreamrootIntegrationError.unableToGenerateLocalManifestUrl(path: dnaClient.manifestLocalURLPath)
                            callback(nil, ExposureError.generalError(error: dnaError), response)
                            return
                        }
                        
                        let source = StreamrootChannelSource(entitlement: value, assetId: channelId, response: response, localManifestUrl: localManifestUrl, dnaClient: dnaClient)
                        
                        callback(source, nil, response)
                    }
                    catch {
                        callback(nil, ExposureError.generalError(error: error), response)
                    }
                    
                    
                }
                else if let exposureError = exposureError {
                    callback(nil,exposureError,response)
                }
            }
        case .program(id: let programId, channelId: let channelId):
            entitlementProvider.requestEntitlement(programId: programId, channelId: channelId, using: sessionToken, in: environment) { entitlement, exposureError, response in
                if let value = entitlement {
                    do {
                        let reEncodedUrl = value.mediaLocator
                        let dnaClient = try self.dnaTrigger.contentId(programId).start(reEncodedUrl)
                        guard let localManifestPath = dnaClient.manifestLocalURLPath, let localManifestUrl = URL(string: localManifestPath) else {
                            let dnaError = StreamrootIntegrationError.unableToGenerateLocalManifestUrl(path: dnaClient.manifestLocalURLPath)
                            callback(nil, ExposureError.generalError(error: dnaError), response)
                            return
                        }
                        
                        let source = StreamrootProgramSource(entitlement: value, assetId: programId, channelId:channelId, response: response, localManifestUrl: localManifestUrl, dnaClient: dnaClient)
                        
                        callback(source, nil, response)
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
        
    }
    
    /// BugFix: StreamrootSDK re-encodes all URL passed with percent encoding. If we pass a previously percent encoded url to the SDK, it will re-encode the url again resulting in double encoding
    private func removePercentEncoding(url: URL) throws -> URL {
        guard let path = url.absoluteString.removingPercentEncoding, let rawUrl = URL(string: path) else {
            throw StreamrootIntegrationError.invalidUrlEncoding(path: url.absoluteString)
        }
        return rawUrl
    }
    
    
    internal typealias StreamrootEntitlementProvider = StreamrootAssetEntitlementProvider & StreamrootChannelEntitlementProvider & StreamrootProgramEntitlementProvider
    internal var entitlementProvider: StreamrootEntitlementProvider = ExposureEntitlementProvider()
    
    internal struct ExposureEntitlementProvider: StreamrootEntitlementProvider {
        internal func requestEntitlement(assetId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) {
            Entitlement(environment: environment,
                        sessionToken: sessionToken)
                .vod(assetId: assetId)
                .request()
                .validate()
                .response{ callback($0.value, $0.error, $0.response) }
        }
        
        internal func requestEntitlement(channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) {
            let entitlement = Entitlement(environment: environment, sessionToken: sessionToken).live(channelId: channelId)
            
            entitlement
                .request()
                .validate()
                .response{
                    if let error = $0.error {
                        // Workaround until EMP-10023 is fixed
                        if case let .exposureResponse(reason: reason) = error, (reason.httpCode == 403 && reason.message == "NO_MEDIA_ON_CHANNEL") {
                            entitlement
                                .use(drm: "UNENCRYPTED")
                                .request()
                                .validate()
                                .response{ callback($0.value, $0.error, $0.response) }
                        }
                        else {
                            callback($0.value, $0.error, $0.response)
                        }
                    }
                    else {
                        callback($0.value, $0.error, $0.response)
                    }
            }
        }
        
        internal func requestEntitlement(programId: String, channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) {
            let entitlement = Entitlement(environment: environment,
                                          sessionToken: sessionToken)
                .program(programId: programId,
                         channelId: channelId)
            
            entitlement
                .request()
                .validate()
                .response{
                    if let error = $0.error {
                        // Workaround until EMP-10023 is fixed
                        if case let .exposureResponse(reason: reason) = error, (reason.httpCode == 403 && reason.message == "NO_MEDIA_FOR_PROGRAM") {
                            entitlement
                                .use(drm: "UNENCRYPTED")
                                .request()
                                .validate()
                                .response{ callback($0.value, $0.error, $0.response) }
                        }
                        else {
                            callback($0.value, $0.error, $0.response)
                        }
                    }
                    else {
                        callback($0.value, $0.error, $0.response)
                    }
            }
        }
    }
}
