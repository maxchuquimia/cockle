//
//  CD.swift
//
//
//  Created by Max Chuquimia on 31/10/2023.
//

import Foundation

/// Manually performs directory changing so that `cd` behaves as expected (is maintained throughout a script).
final class CD: Command {
    
    private var previousDirectory = FileManager.default.currentDirectoryPath

    override func execute(using args: [String]) throws -> String {
        let path = ((args.first ?? "~") as NSString).expandingTildeInPath

        // This is likely naive, is it safe to always single-quote the path?
        // We definitely need the new working directory to be printed in the same command though...
        let newPath = try Shell.executeRaw(
            path: configuration.defaultShell,
            args: ["-c", "cd '\(path)' && pwd"],
            configuration: .init(echoStandardOutput: false)
        )

        FileManager.default.changeCurrentDirectoryPath((newPath as NSString).expandingTildeInPath)
        return ""
    }

}
