//
//  Controller.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 29/08/23.
//

import Foundation

class Controller {
    func add(plugin: Plugin) {
        plugins.append(plugin)
    }
    
    var plugins = [Plugin]()
    
    @discardableResult
    func process<M: Metric>(_ incomingMetric: M) -> M? {
        plugins.forEach { plugin in
            _ = plugin.execute(metric: incomingMetric)
        }
        return incomingMetric
    }
}
