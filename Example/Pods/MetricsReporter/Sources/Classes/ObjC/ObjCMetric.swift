//
//  ObjCMetric.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 17/07/23.
//

import Foundation

@objc(RSMetricType)
public enum ObjCMetricType: Int {
    case count
    case gauge
}

@objc(RSMetric)
public protocol ObjCMetric: NSObjectProtocol {
    var name: String { get set }
    var labels: [String: String]? { get set }
    var type: ObjCMetricType { get set }
}

@objc(RSCount)
public class ObjCCount: NSObject, ObjCMetric {
    public var name: String
    public var labels: [String: String]?
    public var type: ObjCMetricType = .count
    public var value: Int
    
    @objc
    public init(name: String, labels: [String: String]? = nil, value: Int) {
        self.name = name
        self.labels = labels
        self.value = value
    }
}

@objc(RSGauge)
public class ObjCGauge: NSObject, ObjCMetric {
    public var name: String
    public var labels: [String: String]?
    public var type: ObjCMetricType = .gauge
    public var value: Float
    
    @objc
    public init(name: String, labels: [String: String]? = nil, value: Float) {
        self.name = name
        self.labels = labels
        self.value = value
    }
}

extension ObjCMetric {
    func toSwiftMetric() -> Metric? {
        switch self {
            case let m as ObjCCount:
                return Count(name: m.name, labels: m.labels, value: m.value)
            case let m as ObjCGauge:
                return Gauge(name: m.name, labels: m.labels, value: m.value)
            default:
                return nil
        }
    }
}
