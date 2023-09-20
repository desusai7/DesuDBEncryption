//
//  MetricsClient.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 27/06/23.
//

import Foundation
import RudderKit
import RSCrashReporter

public class MetricsClient {
    internal let database: DatabaseOperations
    internal let configuration: Configuration
    internal var statsCollection = StatsCollection()
    internal var controller = Controller()
    
    /// Initialize Metrics Client
    /// - Parameter configuration: Instance of Configuration struct to configure Metrics Client
    public init(configuration: Configuration) {
        self.configuration = configuration
        Logger.logLevel = configuration.logLevel
        database = Database(database: Database.openDatabase())
        platformStartup()
    }
    
    /// Send metrics to server
    /// - Parameter metric: Instance of Count/Gauge which will be processed
    public func process(metric: Metric) {
        if statsCollection.isMetricsEnabled {
            controller.process(metric)
        } else {
            Logger.logDebug("Metrics collection is disabled")
        }
    }
    
    /// Enable/Disable error/crash collection
    public var isErrorsCollectionEnabled: Bool {
        set {
            statsCollection.isErrorsEnabled = newValue
        }
        get {
            return statsCollection.isErrorsEnabled
        }
    }
    
    /// Enable/Disable metric collection
    public var isMetricsCollectionEnabled: Bool {
        set {
            statsCollection.isMetricsEnabled = newValue
        }
        get {
            return statsCollection.isMetricsEnabled
        }
    }
    
    /// For internal testing purpose only. Don't use this API.
    public func testCrash() {
        let array = ["abc"]
        print(array[5])
    }
}
