//
//  Logger.swift
//  RudderKit
//
//  Created by Pallab Maiti on 11/07/23.
//

import Foundation

@objc(RudderLogLevel)
@frozen public enum LogLevel: Int {
    case verbose = 5
    case debug = 4
    case info = 3
    case warning = 2
    case error = 1
    case `none` = 0
    
    func toString() -> String {
        switch self {
            case .verbose:
                return "Verbose"
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            case .none:
                return ""
        }
    }
}

public class Logger {
    public static var logLevel: LogLevel = .error
    
    public static func logDebug(_ message: String, function: String? = #function, line: Int? = #line) {
        rsLog(message: message, logLevel: .debug, function: function, line: line)
    }
    
    public static func logInfo(_ message: String, function: String? = #function, line: Int? = #line) {
        rsLog(message: message, logLevel: .info, function: function, line: line)
    }
    
    public static func logWarning(_ message: String, function: String? = #function, line: Int? = #line) {
        rsLog(message: message, logLevel: .warning, function: function, line: line)
    }
    
    public static func logError(_ message: String, function: String? = #function, line: Int? = #line) {
        rsLog(message: message, logLevel: .error, function: function, line: line)
    }
    
    static func rsLog(message: String, logLevel: LogLevel, function: String? = #function, line: Int? = #line) {
        if self.logLevel == .verbose || self.logLevel == logLevel {
            var metadata = ""
            if let function = function, let line = line {
                metadata = " - \(function):\(line):"
            }
            print("RudderStack:\(logLevel.toString()):\(metadata)\(message)")
        }
    }
}

@objc(RudderLogger)
public class ObjCLogger: NSObject {
    @objc
    public static var logLevel: LogLevel {
        set {
            Logger.logLevel = newValue
        }
        get {
            return Logger.logLevel
        }
    }
    
    @objc
    public static func logDebug(_ message: String) {
        Logger.logDebug(message, function: nil, line: nil)
    }
    
    @objc
    public static func logInfo(_ message: String) {
        Logger.logInfo(message, function: nil, line: nil)
    }
    
    @objc
    public static func logWarning(_ message: String) {
        Logger.logWarning(message, function: nil, line: nil)
    }
    
    @objc
    public static func logError(_ message: String) {
        Logger.logError(message, function: nil, line: nil)
    }
}
