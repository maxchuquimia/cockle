//
//  OutputPrinter.swift
//
//
//  Created by Max Chuquimia on 9/5/2025.
//

import Foundation

/// A protocol for handling command output.
public protocol OutputHandler {
    /// Handles the output of a command, typically used to print to the console.
    /// - Parameter data: The output data from the command. The amount is determined by the command's output, no guarantees are made about it being a single line etc.
    func handleOutput(_ data: Data)
}

/// An OutputHandler that prints to standard output.
public struct StandardOutputPrinter: OutputHandler {

    public init() {}

    public func handleOutput(_ data: Data) {
        fputs(String(data: data, encoding: .utf8)!, Darwin.stdout)
        fflush(Darwin.stdout)
    }

}

/// An OutputHandler that prints to standard error.
public struct StandardErrorPrinter: OutputHandler {

    public init() {}

    public func handleOutput(_ data: Data) {
        fputs(String(data: data, encoding: .utf8)!, Darwin.stderr)
        fflush(Darwin.stderr)
    }

}

public struct NoOutputPrinter: OutputHandler {

    public init() {}

    public func handleOutput(_ data: Data) {
        // No-op
    }

}
