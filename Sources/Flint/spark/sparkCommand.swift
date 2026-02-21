//
//  sparkCommand.swift
//  Flint
//
//  Copyright (c) 2018 Jason Nam (https://jasonnam.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ArgumentParser

struct Spark: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "spark",
        abstract: "Generate project or files from template.",
        aliases: ["s"]
    )

    @Argument(help: "Template name.")
    var templateName: String?

    @Option(name: [.customShort("t"), .customLong("template")], help: "Template path.")
    var templatePath: String?

    @Option(name: [.customShort("o"), .customLong("output")], help: "Output path.")
    var outputPath: String?

    @Option(name: [.customShort("i"), .customLong("input")], help: "Input file path.")
    var inputFilePath: String?

    @Flag(name: [.customShort("f"), .customLong("force")], help: "Force overwrite.")
    var force: Bool = false

    @Flag(name: [.customShort("v"), .customLong("verbose")], help: "Verbose.")
    var verbose: Bool = false

    mutating func run() throws {
        sparkCommandHandler(
            templateNameOperand: templateName,
            templatePathOptionValue: templatePath,
            outputPathOptionValue: outputPath,
            inputFilePathOptionValue: inputFilePath,
            force: force,
            verbose: verbose
        )
    }
}
