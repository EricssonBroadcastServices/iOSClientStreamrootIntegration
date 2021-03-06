//
//  StreamrootIntegrationError.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-11.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

public enum StreamrootIntegrationError: Error {
    case unableToGenerateLocalManifestUrl(path: String?)
    case invalidUrlEncoding(path: String)
}
