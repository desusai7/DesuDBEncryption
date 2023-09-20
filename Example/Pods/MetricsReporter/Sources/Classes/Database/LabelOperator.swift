//
//  LabelOperator.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 30/06/23.
//

import Foundation
import SQLite3
import RudderKit

struct LabelEntity {
    let id: Int
    let name: String
    let value: String
    
    init(id: Int, name: String, value: String) {
        self.id = id
        self.name = name
        self.value = value
    }
}

class LabelOperator: LabelOperations {    
    private let database: OpaquePointer?
    private let syncQueue = DispatchQueue(label: "rudder.database.label")

    init(database: OpaquePointer?) {
        self.database = database
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS label(id INTEGER NOT NULL, name TEXT NOT NULL, value TEXT NOT NULL, PRIMARY KEY(name, value));"
        let tableCreator = TableCreator(database: database, createTableString: createTableString)
        tableCreator.createTable()
    }
    
    @discardableResult
    func saveLabel(name: String, value: String) -> LabelEntity? {
        syncQueue.sync { [weak self] in
            guard let self = self else { return nil }
            var label: LabelEntity?
            let insertStatementString = "INSERT INTO label(id, name, value) VALUES ((SELECT count(*) FROM label) + 1, ?, ?) RETURNING id;"
            var insertStatement: OpaquePointer?
            if sqlite3_prepare_v2(self.database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, (value as NSString).utf8String, -1, nil)
                Logger.logDebug("saveLabelSQL: \(insertStatementString)")
                if sqlite3_step(insertStatement) == SQLITE_ROW {
                    let rowId = Int(sqlite3_column_int(insertStatement, 0))
                    label = LabelEntity(id: rowId, name: name, value: value)
                    Logger.logDebug(Constants.Messages.Insert.Label.success)
                } else {
                    Logger.logError(Constants.Messages.Insert.Label.failed)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Insert.label), Reason: \(errorMessage)")
            }
            sqlite3_finalize(insertStatement)
            return label
        }
    }
    
    func fetchLabel(where name: String, value: String) -> LabelEntity? {
        syncQueue.sync { [weak self] in
            guard let self = self else { return nil }
            var queryStatement: OpaquePointer?
            var label: LabelEntity?
            let queryStatementString = "SELECT * FROM label WHERE name=\"\(name)\" AND value=\"\(value)\";"
            Logger.logDebug("countSQL: \(queryStatementString)")
            if sqlite3_prepare_v2(self.database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(queryStatement, 0))
                    let name = String(cString: sqlite3_column_text(queryStatement, 1))
                    let value = String(cString: sqlite3_column_text(queryStatement, 2))
                    label = LabelEntity(id: id, name: name, value: value)
                    Logger.logDebug(Constants.Messages.Select.Label.success)
                } else {
                    Logger.logError(Constants.Messages.Select.Label.failed)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Select.label), Reason: \(errorMessage)")
            }
            sqlite3_finalize(queryStatement)
            return label
        }
    }
    
    func fetchLabels(where coulmnName: String, in values: [String]) -> [LabelEntity]? {
        syncQueue.sync { [weak self] in
            guard let self = self else { return nil }
            var queryStatement: OpaquePointer?
            var labelList: [LabelEntity]?
            let value =  NSArray(array: values.map { str in
                "\"\(str)\""
            }).componentsJoined(by: ",")
            let queryStatementString = "SELECT * FROM label WHERE \"\(coulmnName)\" IN (\(value));"
            Logger.logDebug("countSQL: \(queryStatementString)")
            if sqlite3_prepare_v2(self.database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                labelList = [LabelEntity]()
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(queryStatement, 0))
                    let name = String(cString: sqlite3_column_text(queryStatement, 1))
                    let value = String(cString: sqlite3_column_text(queryStatement, 2))
                    let label = LabelEntity(id: id, name: name, value: value)
                    labelList?.append(label)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Select.label), Reason: \(errorMessage)")
            }
            sqlite3_finalize(queryStatement)
            return (labelList?.isEmpty ?? true) ? nil : labelList
        }
    }
    
    func clearAll() {
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            var deleteStatement: OpaquePointer?
            let deleteStatementString = "DELETE FROM label;"
            if sqlite3_prepare_v2(self.database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                Logger.logDebug("deleteEventSQL: \(deleteStatementString)")
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    Logger.logDebug(Constants.Messages.Delete.Label.success)
                } else {
                    Logger.logError(Constants.Messages.Delete.Label.failed)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.database))
                Logger.logError("\(Constants.Messages.Statement.Delete.label), Reason: \(errorMessage)")
            }
            sqlite3_finalize(deleteStatement)
        }
    }
}
