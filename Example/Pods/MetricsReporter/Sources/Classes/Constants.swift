//
//  Constants.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 29/08/23.
//

import Foundation

struct Constants {
    struct Config {
        static let SDKMETRICS_URL = "https://sdk-metrics.rudderstack.com"
        static let MAX_METRICS_IN_A_BATCH = 10
        static let MAX_ERRORS_IN_A_BATCH = 5
        static let FLUSH_INTERVAL = 30
        static let START_FROM = 1
        static let DB_COUNT_THRESHOLD = 10000
    }
    
    struct Messages {
        struct Select {
            struct Label {
                static let success = "Label returned"
                static let failed = "Label return error"
            }
            
            struct Metric {
                static let success = "Metric returned"
                static let failed = "Metric return error"
            }
        }
        
        struct Delete {
            struct Label {
                static let success = "Labels deleted from DB"
                static let failed = "Label deletion error"
            }
            
            struct Metric {
                static let success = "Metrics deleted from DB"
                static let failed = "Metric deletion error"
            }
            
            struct Error {
                static let success = "Errors deleted from DB"
                static let failed = "Error deletion error"
            }
        }
        
        struct Update {
            struct Metric {
                static let success = "Metric updated"
                static let failed = "Metric updation error"
            }
        }
        
        struct Insert {
            struct Error {
                static let success = "Error inserted to table"
                static let failed = "Error insertion error"
            }
            
            struct Metric {
                static let success = "Metric inserted to table"
                static let failed = "Metric insertion error"
            }
            
            struct Label {
                static let success = "Label inserted to table"
                static let failed = "Label insertion error"
            }
        }
        
        struct Reset {
            static let success = "Metric inserted to table"
            static let failed = "Metric insertion error"
            static let statementError = "Reset table statement is not prepared"
        }
        
        struct Statement {
            struct Delete {
                static let label = "Label DELETE statement is not prepared"
                static let error = "Error DELETE statement is not prepared"
                static let metric = "Metric DELETE statement is not prepared"
            }
            
            struct Select {
                static let label = "Label SELECT statement is not prepared"
                static let error = "Error SELECT statement is not prepared"
                static let metric = "Metric SELECT statement is not prepared"
            }
            
            struct Insert {
                static let label = "Label INSERT statement is not prepared"
                static let error = "Error INSERT statement is not prepared"
                static let metric = "Metric INSERT statement is not prepared"
            }
        }
    }
}
