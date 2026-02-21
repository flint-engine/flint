#!/usr/bin/swift

import Foundation

let pathToVersion = "Version"
let pathToVersionSwift = "Sources/Flint/version/version.swift"

let version = try! String(contentsOfFile: pathToVersion, encoding: .utf8).dropLast()
let versionSwift = try! String(contentsOfFile: pathToVersionSwift, encoding: .utf8)

var lines: [String] = []
versionSwift.enumerateLines { line, _ in
    lines.append(line)
}
lines.removeLast()
lines.append("let flintVersion = \"\(version)\"\n")
let newFileContent = lines.joined(separator: "\n")

try! newFileContent.write(toFile: pathToVersionSwift, atomically: true, encoding: .utf8)
