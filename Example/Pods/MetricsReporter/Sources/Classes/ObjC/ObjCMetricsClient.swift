//
//  ObjCMetricsClient.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 17/07/23.
//

import Foundation

@objc(RSMetricsClient)
public class ObjCMetricsClient: NSObject {
    let metricClient: MetricsClient
    
    @objc
    public init(configuration: ObjCConfiguration) {
        metricClient = MetricsClient(configuration: configuration.configuration)
    }
}

extension ObjCMetricsClient {
    @objc(process:)
    public func process(metric: ObjCMetric) {
        if let metric = metric.toSwiftMetric() {
            metricClient.process(metric: metric)
        }
    }
    
    @objc
    public var isErrorsCollectionEnabled: Bool {
        set {
            metricClient.isErrorsCollectionEnabled = newValue
        }
        get {
            return metricClient.isErrorsCollectionEnabled
        }
    }
    
    @objc
    public var isMetricsCollectionEnabled: Bool {
        set {
            metricClient.isMetricsCollectionEnabled = newValue
        }
        get {
            return metricClient.isMetricsCollectionEnabled
        }
    }
}
