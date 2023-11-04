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

}
