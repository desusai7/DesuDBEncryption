//
//  ServiceType.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 27/06/23.
//

import Foundation

protocol ServiceType {    
    func sdkMetrics(params: String, _ completion: @escaping Handler<Bool>)
}
