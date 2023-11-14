//
//  Command.swift
//
//
//  Created by Max Chuquimia on 30/10/2023.
//

import Foundation
import Darwin

/// A shell command.
@dynamicCallable
open class Command {
    public let commandName: String
    public var commandPath: String
    public var configuration: ShellConfiguration

    /// - Parameters:
    ///   - commandName: The name of the command. Defaults to a lowercased version of the class name, e.g. a subclass of Command called `XcodeBuild` will map to the shell command `xcodebuild`
    ///   - configuration: A configuration to use when running the command.
    public init(commandName: String? = nil, configuration: ShellConfiguration = .init()) throws {
        self.configuration = configuration
        self.commandName = commandName ?? String(describing: type(of: Self.self))
            .lowercased()
            .replacingOccurrences(of: ".type", with: "")

        self.commandPath = try Shell.which(command: self.commandName, shell: configuration.defaultShell)
    }

    public init(commandName: String, commandPath: String, configuration: ShellConfiguration = .init()) {
        self.commandName = commandName
        self.commandPath = commandPath
        self.configuration = configuration
    }

    /// Calls the command with a raw list of arguments, e.g. `command("-a", "1", "--verbose")`
    @discardableResult
    public func dynamicallyCall(withArguments: [String]) throws -> String {
        try execute(using: withArguments)
    }

    /// Calls the command with a Swift-y list of arguments. Pass `()` for any blanks, e.g. for `command sub-command -f --value 3` use `command(sub_command: (), _f: (), __value: 3)`
    @discardableResult
    public func dynamicallyCall(withKeywordArguments: KeyValuePairs<String, Any>) throws -> String {
        var args: [String] = []
        for (key, value) in withKeywordArguments {
            if !key.isEmpty {
                if configuration.replaceUnderscoresWithDashes {
                    args.append(key.replacingOccurrences(of: "_", with: "-"))
                } else {
                    args.append(key)
                }
            }

            if type(of: value) != Void.self {
                args.append(String(describing: value))
            }
        }

        return try execute(using: args)
    }

    /// Overridable function called to interface with the real Shell.
    open func execute(using args: [String]) throws -> String {
        try Shell.executeRaw(path: commandPath, args: args, configuration: configuration)
    }

}
