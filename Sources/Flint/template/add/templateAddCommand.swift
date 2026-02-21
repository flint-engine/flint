//
//  templateAddCommand.swift
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

struct TemplateAddCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a local template to template home path.",
        aliases: ["a"]
    )

    @Argument(help: "Path to template directory.")
    var templatePath: String

    @Argument(help: "Template name.")
    var templateName: String?

    @Flag(name: [.customShort("f"), .customLong("force")], help: "Force overwrite.")
    var force: Bool = false

    @Flag(name: [.customShort("v"), .customLong("verbose")], help: "Verbose.")
    var verbose: Bool = false

    mutating func run() throws {
        templateAddCommandHandler(
            templatePathOperand: templatePath,
            templateNameOperand: templateName,
            force: force,
            verbose: verbose
        )
    }
}
