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

    /// Whether a command's standard output should be printed as it runs.
    public let echoStandardError: Bool

    /// Whether a command's standard error outout should be printed as it runs.
    public let echoStandardOutput: Bool

    /// The environment variables available to the shell. Defaults to the current process' environment.
    public let environment: Environment

    /// Whether a command's input params names should have underscores replaces with dashes. Defualts to `true`.
    public let replaceUnderscoresWithDashes: Bool

    /// Whether a fully capitalized command's args should have underscores replaces with dashes, e.g. SOME_ARG_NAME. Defaults to `false`.
    public let replaceCapitalizedParamUnderscoresWithDashes: Bool

    /// Whether a command and its arguments should be printed before it is run. Defaults to `false`, useful for debugging.
    public let xtrace: Bool

    public init(
        defaultOutputTrimming: CharacterSet = .whitespacesAndNewlines,
        defaultShell: String = "/bin/sh",
        echoStandardError: Bool = true,
        echoStandardOutput: Bool = true,
        environment: Environment = .process,
        replaceUnderscoresWithDashes: Bool = true,
        replaceCapitalizedParamUnderscoresWithDashes: Bool = false,
        xtrace: Bool = false
    ) {
        self.defaultOutputTrimming = defaultOutputTrimming
        self.defaultShell = defaultShell
        self.echoStandardError = echoStandardError
        self.echoStandardOutput = echoStandardOutput
        self.environment = environment
        self.replaceUnderscoresWithDashes = replaceUnderscoresWithDashes
        self.replaceCapitalizedParamUnderscoresWithDashes = replaceCapitalizedParamUnderscoresWithDashes
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
