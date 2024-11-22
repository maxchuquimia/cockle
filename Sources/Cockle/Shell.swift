//
//  Shell.swift
// 
//
//  Created by Max Chuquimia on 30/10/2023.
//

import Foundation

/// A shell "session"
@dynamicMemberLookup
public final class Shell {

    public let configuration: ShellConfiguration
    private var knownCommands: [String: Command] = [:]

    public init(configuration: ShellConfiguration = .init()) throws {
        self.configuration = configuration
        try use(CD(configuration: configuration))
    }

    private init(configuration: ShellConfiguration, knownCommands: [String: Command]) {
        self.configuration = configuration
        self.knownCommands = knownCommands
    }

}

public extension Shell {

    subscript(dynamicMember commandName: String) -> Command {
        if let existing = knownCommands[commandName] {
            return existing
        }
        let newCommand = try! Command(commandName: commandName, configuration: configuration)
        knownCommands[commandName] = newCommand
        return newCommand
    }

    /// Override defaults for a specific command
    func use<T: Command>(_ command: T) {
        knownCommands[command.commandName] = command
    }

    func copy(addingEnvironment moreEnvironmentVariables: [String: String]) -> Shell {
        Shell(
            configuration: .init(
                defaultOutputTrimming: configuration.defaultOutputTrimming,
                defaultShell: configuration.defaultShell,
                echoStandardError: configuration.echoStandardError,
                echoStandardOutput: configuration.echoStandardOutput,
                environment: .custom(
                    configuration.environment.underlyingEnvironment
                        .merging(moreEnvironmentVariables, uniquingKeysWith: { $1 })
                ),
                replaceUnderscoresWithDashes: configuration.replaceUnderscoresWithDashes,
                replaceCapitalizedParamUnderscoresWithDashes: configuration.replaceCapitalizedParamUnderscoresWithDashes,
                xtrace: configuration.xtrace
            ),
            knownCommands: knownCommands
        )
    }

}
