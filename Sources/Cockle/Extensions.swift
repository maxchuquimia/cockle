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

}
