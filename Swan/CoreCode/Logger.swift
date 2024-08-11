//
//  Logger.swift - Swan
//
//  Created by Ben216k on 3/10/24 (modified for Swan 7/3/24)
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import os.log

enum LogCategory: String {
    case swcanReader
    case mainCode
    case mainUI
    case processingUI
    case other

    var osLog: OSLog {
        switch self {
        case .swcanReader: return OSLog(subsystem: Logger.subsystem, category: "SwcanReader")
        case .mainUI: return OSLog(subsystem: Logger.subsystem, category: "MainUI")
        case .processingUI: return OSLog(subsystem: Logger.subsystem, category: "ProcessingUI")
        case .mainCode: return OSLog(subsystem: Logger.subsystem, category: "MainCode")
        case .other: return OSLog(subsystem: Logger.subsystem, category: "Other")
        }
    }
}

class Logger {
    static let subsystem = "me.ben216k.Swan"

    /**
    NOT RECOMMENDED. Logs a message to the console with the specified log category and type.
     
    Just use the `os_log` function. It's easier, and it'll actually point to the correct line in the code.
     
     - Parameters:
        - message: The message to log. Use a `StaticString` to ensure the message is evaluated at compile time for performance.
        - category: The category of the log, defined by the `LogCategory` enum. Helps organize and filter logs.
        - type: The log type (e.g., `.info`, `.debug`, `.error`). Defaults to `.default`.
        - args: A comma-separated list of arguments to substitute into the message's format specifiers. Follows `printf` style.
     
     - **Format Specifiers**:
         - %@ for objects or any value (e.g., String, Date)
         - %d or %i for signed integers
         - %u for unsigned integers
         - %f for floating-point numbers
         - %x (lowercase), %X (uppercase) for hexadecimal unsigned integers
         - %o for octal unsigned integers
         - %s for C strings
         - %c for characters
         - %p for pointers
     
     Example usage:
     ```
     Logger.log("A simple message", category: .ui)
     Logger.log("Loaded %d items from %@", category: .network, type: .info, 42, "example.com")
     ```
     */
    static func log(_ message: StaticString, category: LogCategory, type: OSLogType = .default, _ args: CVarArg...) {
        os_log(message, log: category.osLog, type: type, args)
    }
}
