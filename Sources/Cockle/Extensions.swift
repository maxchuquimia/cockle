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

    init?(data: Data) {
        if let string = String(data: data, encoding: .utf8) {
            self = string
        } else if let string = String(data: data, encoding: .ascii) {
            self = string
        } else {
            return nil
        }
    }

}

extension Data {

    init(copying dd: DispatchData) {
        var result = Data(count: dd.count)
        result.withUnsafeMutableBytes { buf in
            _ = dd.copyBytes(to: buf)
        }
        self = result
    }

}
