//
//  templateAddCommandHandler.swift
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
import PathFinder
import Bouncer
import Motor

/// Template add command handler.
let templateAddCommandHandler: CommandHandler = { _, _, operandValues, optionValues in
    // Grab values.
    let templatePathOperand = operandValues[0]
    let templateNameOperand = operandValues[optional: 1]
    let force = optionValues.have(templateAddForceOption)
    let verbose = optionValues.have(templateAddVerboseOption)

    // Print input summary.
    if verbose {
        printVerbose(
            """
            Input Summary
            └╴Template Path: \(templatePathOperand)
            └╴Template Name: \(templateNameOperand ?? "nil")
            └╴Force        : \(force)
            └╴Verbose      : \(verbose)
            """
        )
    }

    // Prepare paths.
    let templatePath = URL(fileURLWithPath: templatePathOperand)
    let pathToCopyTemplate: URL
    do {
        let templateName = templateNameOperand ?? templatePath.lastPathComponent
        pathToCopyTemplate = try getTemplateHomePath().appendingPathComponent(templateName)
    } catch {
        printError(error.localizedDescription)
        return
    }

    // Check existing template.
    if FileManager.default.fileExists(atPath: pathToCopyTemplate.path) {
        if force {
            do {
                try FileManager.default.removeItem(at: pathToCopyTemplate)
            } catch {
                printError(error.localizedDescription)
                return
            }
        } else {
            printWarning("Template already exists at \(pathToCopyTemplate.path)")
            printWarning("Use --force/-f option to override existing template")
            return
        }
    }

    // Start copying.
    if verbose {
        printVerbose("Copy \(templatePath.path) to \(pathToCopyTemplate.path)")
    }
    let spinner = Spinner(pattern: Patterns.dots, delay: 2)
    spinner.start(message: "Copying...")
    do {
        if !FileManager.default.fileExists(atPath: pathToCopyTemplate.deletingLastPathComponent().path) {
            try FileManager.default.createDirectory(at: pathToCopyTemplate.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        try FileManager.default.copyItem(at: templatePath, to: pathToCopyTemplate)
        spinner.stop(message: "✓".color(.green) + " Done")
    } catch {
        spinner.stop()
        printError(error.localizedDescription)
        return
    }
}
