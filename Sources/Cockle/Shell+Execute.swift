//
//  executeInShell.swift
//
//
//  Created by Max Chuquimia on 4/11/2023.
//

import Foundation

public extension Shell {

    /// Executes a raw command. This probably isn't the function you're looking for!
    static func executeRaw(path: String, args: [String], configuration: ShellConfiguration) throws -> String {
        let path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if configuration.xtrace {
            print("[shell]", path, args)
        }

        let task = Process()
        let standardOutputPipe = Pipe()
        let standardErrorPipe = Pipe()

        task.standardOutput = standardOutputPipe
        task.standardError = standardErrorPipe
        task.arguments = args
        task.executableURL = URL(fileURLWithPath: path)

        // Read large volumes of data in the most O(1)-y way we can
        var standardOutputChunkMap: [Int: Data] = [:]
        var standardOutputChunkCount = 0
        var standardErrorChunkMap: [Int: Data] = [:]
        var standardErrorChunkCount = 0

        standardOutputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            standardOutputChunkMap[standardOutputChunkCount] = data
            standardOutputChunkCount += 1

            if configuration.echoStandardOutput {
                fputs(String(data: data, encoding: .utf8)!, Darwin.stdout)
                fflush(Darwin.stdout)
            }
        }

        standardErrorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            standardErrorChunkMap[standardErrorChunkCount] = data
            standardErrorChunkCount += 1

            if configuration.echoStandardOutput {
                fputs(String(data: data, encoding: .utf8)!, Darwin.stderr)
                fflush(Darwin.stderr)
            }
        }

        task.launch()
        task.waitUntilExit()

        try standardOutputPipe.fileHandleForReading.close()
        try standardErrorPipe.fileHandleForReading.close()

        var standardOutput = ""
        var errorOutput = ""

        for chunk in standardOutputChunkMap.sorted(by: { $0.key < $1.key }) {
            standardOutput += String(data: chunk.value, encoding: .utf8)!
        }

        for chunk in standardErrorChunkMap.sorted(by: { $0.key < $1.key }) {
            errorOutput += String(data: chunk.value, encoding: .utf8)!
        }

        if task.terminationStatus == 0 {
            return standardOutput.trimmingCharacters(in: configuration.defaultOutputTrimming)
        } else if task.terminationStatus == 127 {
            throw NSError(domain: "\(path) not found", code: 127)
        } else {
            throw ExecutionError(
                command: path,
                code: task.terminationStatus,
                stdout: standardOutput,
                stderr: errorOutput
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

public extension Shell {

    /// Silently find the path to a specific command
    static func which(command: String, shell: String) throws -> String {
        do {
            return try Shell.executeRaw(
                path: shell,
                args: ["-c", "which \(command)"],
                configuration: .init(echoStandardOutput: false, xtrace: false)
            )
        } catch {
            throw ExecutionError(
                command: "which",
                code: 1,
                stdout: "",
                stderr: "Unable to locate command '\(command)'"
            )
        }
    }

}
