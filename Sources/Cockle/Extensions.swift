//
//  Extensions.swift
//
//
//  Created by Max Chuquimia on 4/11/2023.
//

import Foundation

public extension CharacterSet {

    /// An empty character set
    static var none: CharacterSet { .init() }

}

public extension String {

    /// Splits the receiver into lines
    var lines: [String] {
        components(separatedBy: .newlines)
    }

    var hasLowercaseLetters: Bool {
        contains { $0.isLowercase }
    }

    var shellEscaped: String {
        guard !isEmpty else { return "\"\"" }

        // If it contains only safe characters, return as-is
        let safeChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_./")
        if rangeOfCharacter(from: safeChars.inverted) == nil {
            return self
        }

        // Otherwise, single-quote it, escaping internal single quotes
        let escaped = replacingOccurrences(of: "'", with: "'\\''")
        return "'\(escaped)'"
    }

}
