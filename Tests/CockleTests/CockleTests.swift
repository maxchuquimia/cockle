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

    func testStandardError() throws {
        let shell = try Shell(configuration: .init(xtrace: true))

        do {
            try shell.grep("", "random123")
        } catch let error as ExecutionError {
            XCTAssertEqual(error.stdout, "")
            XCTAssertEqual(error.stderr, "grep: random123: No such file or directory\n")
            XCTAssertEqual(error.code, 2)
            return
        } catch {
            XCTFail("Invalid error type")
        }

        XCTFail("Should not reach here")
    }

    func testEnvironment() throws {
        let shell = try Shell(configuration: .init(environment: .custom(["HELLO": "WORLD", "VALUE": "1"])))

        let output = try shell.env()
            .components(separatedBy: "\n")
            .sorted()

        XCTAssertEqual(output, ["HELLO=WORLD", "VALUE=1"])
    }

    func testAddingToEnvironment() throws {
        let shell = try Shell(configuration: .init(environment: .custom(["HELLO": "WORLD", "NO": "will be overwritten"])))

        let output = try shell.copy(addingEnvironment: ["YES": "2", "NO": "2"]).env()
            .components(separatedBy: "\n")
            .sorted()

        XCTAssertEqual(output, ["HELLO=WORLD", "NO=2", "YES=2"])
    }

    func testBigOutput() throws {
        let shell = try Shell(configuration: .init(echoStandardOutput: false, xtrace: false))

        // Lots of words
        let words = try shell.cat("/usr/share/dict/words")
        XCTAssertGreaterThan(words.lines.count, 200000)

        let expectation = expectation(description: "Big output finishes")
        DispatchQueue(label: "bg-queue").async {
            // 200+ MB of random ascii
            let random = try! shell.head(
                _c: 99999999,
                "/dev/urandom"
            )
            XCTAssertGreaterThan(random.count, 200000)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 20)
    }

}
