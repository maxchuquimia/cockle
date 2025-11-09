//
//  Shell+Execute.swift
//
//
//  Created by Max Chuquimia on 4/11/2023.
//

import Foundation
import Subprocess
import System

public extension Shell {

    func path(for commandName: String) throws -> String {
        try Self.path(for: commandName, in: configuration.environment)
    }

    /// Executes a raw command. This probably isn't the function you're looking for!
    func execute(path: String, args: [String]) async throws -> String {
        try await Self.executeRaw(path: path, args: args, configuration: configuration)
    }

    /// Returns the path to a command with the given name
    static func path(for commandName: String, in environment: ShellConfiguration.Environment) throws -> String {
        try Executable.name(commandName)
            .resolveExecutablePath(
                in: environment.asSubprocessEnvironment()
            )
            .string
    }

    /// Executes a raw command. This probably isn't the function you're looking for!
    static func executeRaw(path: String, args: [String], configuration: ShellConfiguration) async throws -> String {
        let path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if configuration.xtrace {
            print("[shell]", path, args)
        }

        let subprocessResult = try await Subprocess.run(
            .path(FilePath(path)),
            arguments: Arguments(args),
            environment: configuration.environment.asSubprocessEnvironment(),
            body: { _, _, standardOutput, standardError in
                let stdout = Task {
                    var content = ""
                    for try await line in standardOutput.lines(encoding: UTF8.self, bufferingPolicy: .unbounded) {
                        guard !line.isEmpty else { continue }
                        configuration.standardOutputHandler.handleOutput(line)
                        content.append(contentsOf: line)
                    }
                    return content
                }

                let stderr = Task {
                    var content = ""
                    for try await line in standardError.lines(encoding: UTF8.self, bufferingPolicy: .unbounded) {
                        guard !line.isEmpty else { continue }
                        configuration.standardErrorHandler.handleOutput(line)
                        content.append(contentsOf: line)
                    }
                    return content
                }

                return try await (stdout: stdout.value, stderr: stderr.value)
            }
        )

        let exitCode = switch subprocessResult.terminationStatus {
        case let .exited(code): code
        case let .unhandledException(code): code
        }

        if exitCode == 0 {
            return subprocessResult.value.stdout.trimmingCharacters(in: configuration.defaultOutputTrimming)
        } else if exitCode == 127 {
            throw NSError(domain: "\(path) not found", code: 127)
        } else {
            throw ExecutionError(
                command: path,
                code: exitCode,
                stdout: subprocessResult.value.stdout,
                stderr: subprocessResult.value.stderr
            )
        }
    }

}

/// Defines the failure state of a command
public struct ExecutionError: LocalizedError {

    /// The path of the command that failed
    public let command: String

    /// The exit code of the command
    public let code: Int32

    /// The standard output of the command
    public let stdout: String

    /// The standard error outout of the command
    public let stderr: String

    public var errorDescription: String? {
        "\(command) exited with error code \(code)."
    }

}
