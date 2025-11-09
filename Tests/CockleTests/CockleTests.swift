//
//  CockleTests.swift
//
//
//  Created by Max Chuquimia on 4/11/2023.
//

import XCTest
import Cockle // Without @testable so we can test as a third party

final class CockleTests: XCTestCase {

    func testCockle1() async throws {
        let shell = try Shell(configuration: .init(xtrace: true))

        try await shell.cd("/tmp")
        var stdout = try await shell.pwd()
        XCTAssertEqual(stdout, "/tmp")

        let randomDirectoryName = UUID().uuidString
        try await shell.mkdir(randomDirectoryName)
        try await shell.cd(randomDirectoryName)
        stdout = try await shell.pwd()
        XCTAssertEqual(stdout, "/private/tmp/\(randomDirectoryName)")

        try await shell.touch("abc.txt")
        try await shell.touch("def.txt")

        let files = try await shell.ls()
        XCTAssertEqual(files.lines, ["abc.txt", "def.txt"])

        try await shell.rm(_r: "abc.txt")

        let files2 = try await shell.ls()
        XCTAssertEqual(files2.lines, ["def.txt"])

        try await shell.cd("..")
        stdout = try await shell.pwd()
        XCTAssertEqual(stdout, "/tmp")

        try await shell.rm(_rf: (), randomDirectoryName)
    }

    func testCockle2() async throws {
        let shell = try Shell(configuration: .init(xtrace: true))

        try await shell.mkdir(_p: "/tmp/testCockle2")
        try await shell.cd("/tmp/testCockle2")
        try await shell.git(clone: (), __depth: 1, "https://github.com/maxchuquimia/cockle.git")
        try await shell.cd("/tmp/testCockle2/cockle")
        try await shell.git("log", "--oneline")
        try await shell.cd("/tmp")
        try await shell.rm(_rf: "testCockle2")
    }

    func testArrayArgs() async throws {
        let shell = try Shell(configuration: .init(defaultOutputTrimming: .none, xtrace: true))

        let result1 = try await shell.echo(_n: (), ["1", "2", "3"])
        XCTAssertEqual(result1, "1 2 3")

        let result2 = try await shell.echo(_n: ["1", "2", "3"])
        XCTAssertEqual(result2, "1 2 3")

        let result3 = try await shell.echo(["1", "2", "3"])
        XCTAssertEqual(result3, "1 2 3\n")
    }

    func testStandardError() async throws {
        let shell = try Shell(configuration: .init(xtrace: true))

        do {
            try await shell.grep("", "random123")
        } catch let error as ExecutionError {
            XCTAssertEqual(error.stdout, "")
            XCTAssertEqual(error.stderr, "grep: random123: No such file or directory\n")
            XCTAssertEqual(error.code, 2)
            return
        }
        XCTFail("Should not reach here")
    }

    func testEnvironment() async throws {
        let shell = try Shell(configuration: .init(environment: .custom(["HELLO": "WORLD", "VALUE": "1"])))

        let output = try await shell.env()
            .components(separatedBy: "\n")
            .sorted()

        XCTAssertEqual(output, ["HELLO=WORLD", "VALUE=1"])
    }

    func testAddingToEnvironment() async throws {
        let shell = try Shell(configuration: .init(environment: .custom(["HELLO": "WORLD", "NO": "will be overwritten"])))

        let output = try await shell.copy(addingEnvironment: ["YES": "2", "NO": "2"]).env()
            .components(separatedBy: "\n")
            .sorted()

        XCTAssertEqual(output, ["HELLO=WORLD", "NO=2", "YES=2"])
    }

}
