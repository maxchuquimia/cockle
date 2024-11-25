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
            fflush(Darwin.stdout)
        }

        let url = URL(fileURLWithPath: path)

        return try launch(tool: url, arguments: args, configuration: configuration)
    }

    // Modified version of https://developer.apple.com/forums/thread/690310?answerId=688174022#688174022 with the following changes
    // - Removed reliance on closure callback
    // - Removed ability to pass input data streams
    // - Added ShellConfiguration
    // - Added support for stderr capturing
    // - Simplified error handling
    // - Made stdout and stderr capturing faster
    // - Attempt to remove reliance on being called from main thread
    private static func launch(tool: URL, arguments: [String] = [], configuration: ShellConfiguration) throws -> String {
        // dispatchPrecondition(condition: .onQueue(.main))
//        if !Thread.current.isMainThread {
//            throw ExecutionError(
//                command: "",
//                code: 1,
//                stdout: "",
//                stderr: "Shell commands must be run on the main thread."
//            )
//        }

        let group = DispatchGroup()
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        // Read large volumes of data in the most O(1)-y way we can
        var standardOutputChunkMap: [Int: Data] = [:]
        var standardOutputChunkCount = 0
        var standardErrorChunkMap: [Int: Data] = [:]
        var standardErrorChunkCount = 0

        let proc = Process()
        proc.executableURL = tool
        proc.arguments = arguments
        proc.standardInput = inputPipe
        proc.standardOutput = outputPipe
        proc.standardError = errorPipe
        proc.environment = configuration.environment.underlyingEnvironment
        var isComplete = false

        group.enter()
        proc.terminationHandler = { process in
            // Wait some time in case proc.run() exits immediately - we want the code below it to run first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            isComplete = true
        }

        do {
            try proc.run()

            group.enter()
            let readIO = DispatchIO(type: .stream, fileDescriptor: outputPipe.fileHandleForReading.fileDescriptor, queue: .main) { _ in
                try! outputPipe.fileHandleForReading.close()
            }
            readIO.read(offset: 0, length: .max, queue: .main) { isDone, chunkQ, error in
                autoreleasepool {
                    let data = chunkQ.map { Data(copying: $0) }

                    if let data, !data.isEmpty {
                        standardOutputChunkMap[standardOutputChunkCount] = data
                        standardOutputChunkCount += 1
                    }

                    if configuration.echoStandardOutput, let data {
                        fputs(String(data: data)!, Darwin.stdout)
                        fflush(Darwin.stdout)
                    }

                    if isDone || error != 0 {
                        readIO.close()
                        group.leave()
                    }
                }
            }

            group.enter()
            let readErrorIO = DispatchIO(type: .stream, fileDescriptor: errorPipe.fileHandleForReading.fileDescriptor, queue: .main) { _ in
                try! errorPipe.fileHandleForReading.close()
            }
            readErrorIO.read(offset: 0, length: .max, queue: .main) { isDone, chunkQ, error in
                autoreleasepool {
                    let data = chunkQ.map { Data(copying: $0) }

                    if let data, !data.isEmpty {
                        standardErrorChunkMap[standardOutputChunkCount] = data
                        standardErrorChunkCount += 1
                    }

                    if configuration.echoStandardError, let data {
                        fputs(String(data: data)!, Darwin.stderr)
                        fflush(Darwin.stderr)
                    }

                    if isDone || error != 0 {
                        readErrorIO.close()
                        group.leave()
                    }
                }
            }
        } catch {
            proc.terminationHandler!(proc)
        }

        while !isComplete {
            RunLoop.current.run(mode: .default, before: .distantFuture)
        }

        var standardOutput = ""
        var errorOutput = ""
        for chunk in standardOutputChunkMap.sorted(by: { $0.key < $1.key }) {
            standardOutput += String(data: chunk.value)!
        }

        for chunk in standardErrorChunkMap.sorted(by: { $0.key < $1.key }) {
            errorOutput += String(data: chunk.value)!
        }

        if proc.terminationStatus != 0 {
            throw ExecutionError(
                command: tool.path,
                code: proc.terminationStatus,
                stdout: standardOutput.trimmingCharacters(in: configuration.defaultOutputTrimming),
                stderr: errorOutput
            )
        }

        return standardOutput.trimmingCharacters(in: configuration.defaultOutputTrimming)
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
