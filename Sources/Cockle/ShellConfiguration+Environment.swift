//
//  ShellConfiguration+Environment.swift
//  Cockle
//
//  Created by Max Chuquimia on 29/9/2025.
//

import Foundation
import struct Subprocess.Environment

public extension ShellConfiguration {

    struct Environment {

        internal enum Configuration {
            /// Use the current process' environment
            case process

            /// Add additional environment variables to the current process' environment
            case adding([String: String])

            /// Use an entirely custom environment
            case custom([String: String])
        }

        internal let configuration: [Configuration]

        internal init(configuration: Configuration) {
            self.configuration = [configuration]
        }

        internal init(configuration: [Configuration]) {
            self.configuration = configuration
        }

        internal func asSubprocessEnvironment() -> Subprocess.Environment {
            guard !configuration.isEmpty else { return .inherit }

            var configuration = configuration
            var result: Subprocess.Environment = switch configuration.removeFirst() {
            case .process: .inherit
            case let .adding(values): .inherit.updating(values.asSubprocessEnvironmentVariables())
            case let .custom(values): .custom(values.asSubprocessEnvironmentVariables())
            }

            for value in configuration {
                switch value {
                case .process, .custom:
                    fatalError(".process and .custom will only ever be the first item in self.configuration")
                case let .adding(values):
                    result = result.updating(values.asSubprocessEnvironmentVariables())
                }
            }

            return result
        }

        public static let process = Environment(configuration: .process)

        public static func adding(_ values: [String: String]) -> Environment {
            Environment(configuration: .adding(values))
        }

        public static func custom(_ values: [String: String]) -> Environment {
            Environment(configuration: .custom(values))
        }

        public func adding(_ more: [String: String]) -> Environment {
            var configuration = self.configuration
            configuration.append(.adding(more))
            return Environment(configuration: configuration)
        }

    }

}

private extension Dictionary<String, String> {

    func asSubprocessEnvironmentVariables() -> [Subprocess.Environment.Key: String] {
        var result: [Subprocess.Environment.Key: String] = [:]
        for (key, value) in self {
            result[.init(rawValue: key)!] = value
        }
        return result
    }

}
