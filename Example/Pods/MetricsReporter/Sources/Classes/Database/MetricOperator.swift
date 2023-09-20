//
//  MetricOperator.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 30/06/23.
//

import Foundation
import SQLite3
import RudderKit

struct MetricEntity {
    let id: Int
    let name: String
    let value: Float
    let type: String
    let labels: String
    
    init(id: Int, name: String, value: Float, type: String, labels: String) {
        self.id = id
        self.name = name
        self.value = value
        self.type = type
        self.labels = labels
    }
}

class MetricOperator: MetricOperations {
    private let database: OpaquePointer?
    private let syncQueue = DispatchQueue(label: "rudder.database.metric")

    init(database: OpaquePointer?) {
        self.database = database
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS metric(id INTEGER NOT NULL, name TEXT NOT NULL, value NUMERIC NOT NULL, type TEXT NOT NULL, labels TEXT NOT NULL, PRIMARY KEY(name, type, labels));"
        let tableCreator = TableCreator(database: database, createTableString: createTableString)
        tableCreator.createTable()
    }
    
    @discardableResult
    func saveMetric(name: String, value: Float, type: String, labels: String) -> MetricEntity? {
        syncQueue.sync { [weak self] in
            guard let self = self else { return nil }
            var metric: MetricEntity?
            let insertStatementString = "INSERT INTO metric(id, name, value, type, labels) VALUES ((SELECT count(*) FROM metric) + 1, ?, ?, ?, ?) ON CONFLICT(name, type, labels) DO UPDATE SET value=value+excluded.value RETURNING id;"
            var insertStatement: OpaquePointer?
            if sqlite3_prepare_v2(self.database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 2, Float64(value))
                sqlite3_bind_text(insertStatement, 3, (type as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 4, (labels as NSString).utf8String, -1, nil)
                Logger.logDebug("saveEventSQL: \(insertStatementString)")
                if sqlite3_step(insertStatement) == SQLITE_ROW {
                    let rowId = Int(sqlite3_column_int(insertStatement, 0))
                    metric = MetricEntity(id: rowId, name: name, value: value, type: type, labels: labels)
                    Logger.logDebug(Constants.Messages.Insert.Metric.success)
                } else {
                    Logger.logError(Constants.Messages.Insert.Metric.failed)
                }
                
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Insert.metric), Reason: \(errorMessage)")
            }
            sqlite3_finalize(insertStatement)
            return metric
        }
    }
    
    func fetchMetric(where name: String, type: String, labels: String) -> MetricEntity? {
        syncQueue.sync { [weak self] in
            guard let self = self else { return nil }
            var queryStatement: OpaquePointer?
            var metric: MetricEntity?
            let queryStatementString = "SELECT * FROM metric WHERE name=\"\(name)\" AND type=\"\(type)\" AND labels=\"\(labels)\";"
            Logger.logDebug("countSQL: \(queryStatementString)")
            if sqlite3_prepare_v2(self.database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(queryStatement, 0))
                    let name = String(cString: sqlite3_column_text(queryStatement, 1))
                    let value = Float(sqlite3_column_double(queryStatement, 2))
                    let type = String(cString: sqlite3_column_text(queryStatement, 3))
                    let labels = String(cString: sqlite3_column_text(queryStatement, 4))
                    metric = MetricEntity(id: id, name: name, value: value, type: type, labels: labels)
                    Logger.logDebug(Constants.Messages.Select.Metric.success)
                } else {
                    Logger.logError(Constants.Messages.Select.Metric.failed)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Select.metric), Reason: \(errorMessage)")
            }
            sqlite3_finalize(queryStatement)
            return metric
        }
    }
    
    func fetchMetrics(where columnName: String, from valueFrom: Int, to valueTo: Int) -> [MetricEntity]? {
        syncQueue.sync { [weak self] in
            guard let self = self else { return nil }
            var queryStatement: OpaquePointer?
            var metricList: [MetricEntity]?
            let queryStatementString = "SELECT * FROM metric WHERE \(columnName) BETWEEN \(valueFrom) AND \(valueTo);"
            Logger.logDebug("countSQL: \(queryStatementString)")
            if sqlite3_prepare_v2(self.database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                metricList = [MetricEntity]()
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(queryStatement, 0))
                    let name = String(cString: sqlite3_column_text(queryStatement, 1))
                    let value = Float(sqlite3_column_double(queryStatement, 2))
                    let type = String(cString: sqlite3_column_text(queryStatement, 3))
                    let labels = String(cString: sqlite3_column_text(queryStatement, 4))
                    let metric = MetricEntity(id: id, name: name, value: value, type: type, labels: labels)
                    metricList?.append(metric)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Select.metric), Reason: \(errorMessage)")
            }
            sqlite3_finalize(queryStatement)
            return (metricList?.isEmpty ?? true) ? nil : metricList
        }
    }
    
    @discardableResult
    func updateMetric(_ metric: MetricEntity?, updatedValue: Float) -> Int? {
        syncQueue.sync { [weak self] in
            guard let self = self, let metric = metric else { return nil }
            var queryStatement: OpaquePointer?
            let queryStatementString = "UPDATE metric SET value=\(updatedValue) WHERE name=\"\(metric.name)\" AND type=\"\(metric.type)\" AND labels=\"\(metric.labels)\";"
            Logger.logDebug("countSQL: \(queryStatementString)")
            if sqlite3_prepare_v2(self.database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_DONE {
                    Logger.logDebug(Constants.Messages.Update.Metric.success)
                } else {
                    Logger.logError(Constants.Messages.Update.Metric.failed)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Select.metric), Reason: \(errorMessage)")
            }
            sqlite3_finalize(queryStatement)
            return metric.id
        }
    }
    
    func clearAll() {
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            var deleteStatement: OpaquePointer?
            let deleteStatementString = "DELETE FROM metric;"
            if sqlite3_prepare_v2(self.database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                Logger.logDebug("deleteEventSQL: \(deleteStatementString)")
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    Logger.logDebug(Constants.Messages.Delete.Metric.success)
                } else {
                    Logger.logError(Constants.Messages.Delete.Metric.failed)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Delete.metric), Reason: \(errorMessage)")
            }
            sqlite3_finalize(deleteStatement)
        }
    }
}
