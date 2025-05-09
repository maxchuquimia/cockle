//
//  ShellConfiguration.swift
//  
//
//  Created by Max Chuquimia on 4/11/2023.
//

import Foundation

public struct ShellConfiguration {

    /// A character set to trim from any output returned by running a command. Defaults to newlines and whitespace.
    public let defaultOutputTrimming: CharacterSet

    /// The default shell to use with `-c` whilst discovering a command's path. Defaults to `/bin/sh`.
    public let defaultShell: String

    /// The environment variables available to the shell. Defaults to the current process' environment.
    public let environment: Environment

    /// Whether a command's input params names should have underscores replaces with dashes. Defualts to `true`.
    public let replaceUnderscoresWithDashes: Bool

    /// Whether a fully capitalized command's args should have underscores replaces with dashes, e.g. SOME_ARG_NAME. Defaults to `false`.
    /// This does not affect params that beging with an underscore.
    public let replaceCapitalizedParamUnderscoresWithDashes: Bool

    /// The standard error output handler. Defaults to `StandardErrorPrinter()`.
    public let standardErrorHandler: OutputHandler

    /// The standard output handler. Defaults to `StandardOutputPrinter()`.
    public let standardOutputHandler: OutputHandler

    /// Whether a command and its arguments should be printed before it is run. Defaults to `false`, useful for debugging.
    public let xtrace: Bool

    public init(
        defaultOutputTrimming: CharacterSet = .whitespacesAndNewlines,
        defaultShell: String = "/bin/sh",
        environment: Environment = .process,
        replaceUnderscoresWithDashes: Bool = true,
        replaceCapitalizedParamUnderscoresWithDashes: Bool = false,
        standardErrorHandler: OutputHandler = StandardErrorPrinter(),
        standardOutputHandler: OutputHandler = StandardOutputPrinter(),
        xtrace: Bool = false
    ) {
        self.defaultOutputTrimming = defaultOutputTrimming
        self.defaultShell = defaultShell
        self.environment = environment
        self.replaceUnderscoresWithDashes = replaceUnderscoresWithDashes
        self.replaceCapitalizedParamUnderscoresWithDashes = replaceCapitalizedParamUnderscoresWithDashes
        self.standardErrorHandler = standardErrorHandler
        self.standardOutputHandler = standardOutputHandler
        self.xtrace = xtrace
    }

}

public extension ShellConfiguration {

    enum Environment {

        /// Use the current process' environment
        case process

        /// Add additional environment variables to the current process' environment
        case adding([String: String])

        /// Use an entirely custom environment
        case custom([String: String])

        var underlyingEnvironment: [String: String] {
            switch self {
            case .process:
                return ProcessInfo.processInfo.environment
            case let .adding(additional):
                return ProcessInfo.processInfo.environment.merging(additional, uniquingKeysWith: { $1 })
            case let .custom(custom):
                return custom
            }
        }
        
    }

}
