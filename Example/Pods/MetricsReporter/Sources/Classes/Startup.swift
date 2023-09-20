//
//  Startup.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 28/08/23.
//

import Foundation

extension MetricsClient {
    internal func platformStartup() {
        add(plugin: CrashReporter())
        add(plugin: MetricsUploader())
    }

    @discardableResult
    func add(plugin: Plugin) -> Plugin {
        plugin.configure(metricsClient: self)
        controller.add(plugin: plugin)
        return plugin
    }
}
