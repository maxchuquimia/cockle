//
//  CockleTests.swift
//
//
//  Created by Max Chuquimia on 4/11/2023.
//

import XCTest
import Cockle // Without @testable so we can test as a third party

final class CockleTests: XCTestCase {

    func testCockle1() throws {
        let shell = try Shell(configuration: .init(xtrace: true))

        try shell.cd("/tmp")
        XCTAssertEqual(try shell.pwd(), "/tmp")

        let randomDirectoryName = UUID().uuidString
        try shell.mkdir(randomDirectoryName)
        try shell.cd(randomDirectoryName)
        XCTAssertEqual(try shell.pwd(), "/private/tmp/\(randomDirectoryName)")
        
        try shell.touch("abc.txt")
        try shell.touch("def.txt")

        let files = try shell.ls()
        XCTAssertEqual(files.lines, ["abc.txt", "def.txt"])

        try shell.rm(_r: "abc.txt")

        let files2 = try shell.ls()
        XCTAssertEqual(files2.lines, ["def.txt"])

        try shell.cd("..")
        XCTAssertEqual(try shell.pwd(), "/tmp")

        try shell.rm(_rf: (), randomDirectoryName)
    }

    func testCockle2() throws {
        let shell = try Shell(configuration: .init(xtrace: true))

        try shell.mkdir(_p: "/tmp/testCockle2")
        try shell.cd("/tmp/testCockle2")
        try shell.git(clone: (), __depth: 1, "https://github.com/maxchuquimia/cockle.git")
        try shell.cd("/tmp/testCockle2/cockle")
        try shell.git("log", "--oneline")
        try shell.cd("/tmp")
        try shell.rm(_rf: "testCockle2")
    }

}
