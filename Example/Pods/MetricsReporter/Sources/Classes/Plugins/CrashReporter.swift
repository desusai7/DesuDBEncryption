//
//  CrashReporter.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 27/07/23.
//

import Foundation
import RSCrashReporter

class CrashReporter: Plugin, RSCrashReporterNotifyDelegate {
    
    weak var metricsClient: MetricsClient? {
        didSet {
            initialSetup()
            startCollectingCrash()
        }
    }
    
    private var database: DatabaseOperations?
    private let sdkList = ["MetricsReporter", "Rudder"]
    
    func initialSetup() {
        guard let metricsClient = self.metricsClient else { return }
        database = metricsClient.database
    }
    
    func startCollectingCrash() {
        RSCrashReporter.start(with: self)
    }
    
    func execute<M: Metric>(metric: M?) -> M? {
        return metric
    }
    
    func notifyCrash(_ event: BugsnagEvent?, withRequestPayload requestPayload: [AnyHashable: Any]?) {
        guard let metricsClient = self.metricsClient, let database = self.database else { return }
        if let requestPayload = requestPayload, (checkIfRudderCrash(event: event) && metricsClient.statsCollection.isErrorsEnabled),
           let eventList = requestPayload["events"] as? [[String: Any]], let events = eventList.toJSONString() {
            database.saveError(events: events)
        }
    }
    
    func checkIfRudderCrash(event: BugsnagEvent?) -> Bool {
        var isRudderCrash = false
        if let event = event {
            for error in event.errors {
                for stacktrace in error.stacktrace {
                    if let machoFile = stacktrace.machoFile, let url = URL(string: machoFile), sdkList.contains(url.lastPathComponent) {
                        isRudderCrash = true
                        break
                    }
                }
            }
        }
        return isRudderCrash
    }
}
