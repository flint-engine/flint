//
//  templateCloneCommandHandler.swift
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

import Foundation
import Motor
import Execute

/// Template clone command handler.
func templateCloneCommandHandler(
    gitURLOperand: String,
    templateNameOperand: String?,
    branch: String?,
    force: Bool,
    verbose: Bool
) {

    // Print input summary.
    if verbose {
        printVerbose(
            """
            Input Summary
            └╴Repository URL: \(gitURLOperand)
            └╴Template Name : \(templateNameOperand ?? "nil")
            └╴Branch        : \(branch ?? "HEAD")
            └╴Force         : \(force)
            └╴Verbose       : \(verbose)
            """
        )
    }

    // Prepare paths.
    let pathToCloneTemplate: URL
    do {
        guard let gitURL = URL(string: gitURLOperand) else {
            printError("\(gitURLOperand) is not a valid url.")
            return
        }
        let templateName = templateNameOperand ?? gitURL.deletingPathExtension().lastPathComponent
        pathToCloneTemplate = try getTemplateHomePath().appendingPathComponent(templateName)
    } catch {
        printError(error.localizedDescription)
        return
    }

    // Check existing template.
    if FileManager.default.fileExists(atPath: pathToCloneTemplate.path) {
        if force {
            do {
                try FileManager.default.removeItem(at: pathToCloneTemplate)
            } catch {
                printError(error.localizedDescription)
                return
            }
        } else {
            printWarning("Template already exists at \(pathToCloneTemplate.path)")
            printWarning("Use --force/-f option to override existing template")
            return
        }
    }

    // Prepare cloning.
    let spinner = Spinner(pattern: Patterns.dots, delay: 2)
    var gitCommand = "git clone \(gitURLOperand) \"\(pathToCloneTemplate.path)\" --single-branch --depth 1"
    if let branch = branch {
        gitCommand.append(" -b \(branch)")
    }
    let gitClone = ShCommand(command: gitCommand)

    // Start cloning.
    if verbose {
        printVerbose("Execute: \(gitCommand)")
    }
    spinner.start(message: "Downloading...")

    // Clean up.
    switch Executor().sync(gitClone) {
    case .success:
        spinner.stop(message: "✓".color(.green) + " Done")
    case let .failure(error):
        spinner.stop(message: "✗".color(.red) + " Failed: \(error.localizedDescription)")
    }
}
