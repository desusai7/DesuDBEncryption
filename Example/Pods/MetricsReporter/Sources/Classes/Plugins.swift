//
//  Plugins.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 28/08/23.
//

import Foundation

protocol Plugin: AnyObject {
    var metricsClient: MetricsClient? { get set }
    
    func execute<M: Metric>(metric: M?) -> M?
}

extension Plugin {
    public func configure(metricsClient: MetricsClient) {
        self.metricsClient = metricsClient
    }
}
