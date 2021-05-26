//
//  Logger.swift
//  CyberSwift
//
//  Created by msm72 on 27.02.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//
//  https://medium.com/@sauvik_dolui/developing-a-tiny-logger-in-swift-7221751628e6
//

import Foundation

/// App Scheme
public enum LogEvent: String {
    case error      =   "[‼️]"
    case info       =   "[ℹ️]"          // for guard & alert & route
    case debug      =   "[💬]"          // tested values & local notifications
    case verbose    =   "[🔬]"          // current values
    case warning    =   "[⚠️]"
    case severe     =   "[🔥]"          // tokens & keys & init & deinit
    case request    =   "[⬆️]"
    case response   =   "[⬇️]"
    case event      =   "[🎇]"
}

public class Logger {
    // MARK: - Properties
    static var showEvents: [LogEvent]?
    static var shownApiMethods: [String]?

    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"

    static var dateFormatter: DateFormatter {
        let formatter           =   DateFormatter()
        formatter.dateFormat    =   dateFormat
        formatter.locale        =   Locale.current
        formatter.timeZone      =   TimeZone.current

        return formatter
    }
    private static var isOn = true

    // MARK: - Class Functions
    public static func on() {
        isOn = true
    }

    public static func off() {
        isOn = false
    }

    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")

        return components.isEmpty ? "" : components.last!
    }

    // message:     This will be the debug message to appear on the debug console.
    // event:       Type of event as cases of LogEvent enum.
    // fileName:    The file name from where the log will appear.
    // line:        The line number of the log message.
    // column:      The same will happen for this parameter too.
    // funcName:    The default value of this parameter is the signature of the function from where the log function is getting called.
    public class func log(message: String, event: LogEvent, fileName: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function, apiMethod: String? = nil) {
        if !isOn {return}
        if showEvents?.contains(event) == false {return}
        if let method = apiMethod, shownApiMethods?.contains(method) == false {return}
        #if DEBUG
            print("\(Date().toString()) \(event.rawValue)[\(sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)")
        #else
        #endif
    }
}

extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
