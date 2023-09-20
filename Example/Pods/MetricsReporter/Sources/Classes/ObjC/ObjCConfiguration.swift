//
//  ObjCConfiguration.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 17/07/23.
//

import Foundation
import RudderKit

@objc(RSMetricConfiguration)
public class ObjCConfiguration: NSObject {
    var configuration: Configuration
    
    @objc
    public init(logLevel: Int, writeKey: String, sdkVersion: String) {
        configuration = Configuration(logLevel: LogLevel(rawValue: logLevel) ?? .error, writeKey: writeKey, sdkVersion: sdkVersion)
    }
    
    @discardableResult @objc
    public func sdkMetricsUrl(_ sdkMetricsUrl: String) -> ObjCConfiguration {
        configuration.sdkMetricsUrl = sdkMetricsUrl
        return self
    }
    
    @discardableResult @objc
    public func maxErrorsInBatch(_ maxErrorsInBatch: Int) -> ObjCConfiguration {
        configuration.maxErrorsInBatch = maxErrorsInBatch
        return self
    }
    
    @discardableResult @objc
    public func maxMetricsInBatch(_ maxMetricsInBatch: Int) -> ObjCConfiguration {
        configuration.maxMetricsInBatch = maxMetricsInBatch
        return self
    }
    
    @discardableResult @objc
    public func flushInterval(_ flushInterval: Int) -> ObjCConfiguration {
        configuration.flushInterval = flushInterval
        return self
    }
    
    @discardableResult @objc
    public func dbCountThreshold(_ dbCountThreshold: Int) -> ObjCConfiguration {
        configuration.dbCountThreshold = dbCountThreshold
        return self
    }
}
