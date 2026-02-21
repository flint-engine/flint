//
//  sparkCommandHandler.swift
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
import Execute
import Yams

/// Spark command handler.
let sparkCommandHandler: CommandHandler = { _, _, operandValues, optionValues in
    // Grab values.
    let templateNameOperand = operandValues[optional: 0]
    let templatePathOptionValue = optionValues.findOptionalArgument(for: sparkTemplatePathOption)
    let outputPathOptionValue = optionValues.findOptionalArgument(for: sparkOutputPathOption)
    let inputFilePathOptionValue = optionValues.findOptionalArgument(for: sparkInputFilePathOption)
    let force = optionValues.have(sparkForceOption)
    let verbose = optionValues.have(sparkVerboseOption)

    // Print input summary.
    if verbose {
        printVerbose(
            """
            Input Summary
            └╴Template Name: \(templateNameOperand ?? "nil")
            └╴Template Path: \(templatePathOptionValue ?? "nil")
            └╴Output Path  : \(outputPathOptionValue ?? "nil")
            └╴Input Path   : \(inputFilePathOptionValue ?? "nil")
            └╴Force        : \(force)
            └╴Verbose      : \(verbose)
            """
        )
    }

    // Prepare template.
    let template: Template
    do {
        let templatePath: Path
        if let templateName = templateNameOperand {
            templatePath = try getTemplateHomePath()[templateName]
            if let templatePathOptionValue = templatePathOptionValue {
                printWarning("Ignore \(templatePathOptionValue)")
            }
        } else if let templatePathOptionValue = templatePathOptionValue {
            templatePath = Path(fileURLWithPath: templatePathOptionValue)
        } else {
            printError("Template not specified")
            return
        }
        template = try Template(path: templatePath)
    } catch {
        printError(error.localizedDescription)
        return
    }

    // Output path.
    let outputPath: Path
    if let outputPathOptionValue = outputPathOptionValue {
        outputPath = Path(fileURLWithPath: outputPathOptionValue)
    } else {
        print("Output Path [--output | -o]: ", terminator: "")
        if let outputPathInput = readLine() {
            outputPath = Path(fileURLWithPath: FileManager.default.currentDirectoryPath)[outputPathInput]
        } else {
            printError("Output path not specified")
            return
        }
    }

    // Get inputs.
    var inputs: [String: String] = [:]

    for variable in (template.manifest.variables ?? []) {
        if let value = Env.environment["FLINT_\(variable.name.replacingOccurrences(of: " ", with: "_"))"] {
            inputs[variable.name] = value
        }
    }

    if let inputFilePathOptionValue = inputFilePathOptionValue {
        let inputPath = Path(fileURLWithPath: inputFilePathOptionValue)
        do {
            switch inputPath.rawValue.pathExtension {
            case "json":
                let data = try Data(contentsOf: inputPath.rawValue)
                for (key, value) in try JSONDecoder().decode([String: String].self, from: data) {
                    if (template.manifest.variables ?? []).map({ $0.name }).contains(key) {
                        inputs[key] = value
                    }
                }
            case "yaml", "yml":
                let string = try String(contentsOf: inputPath.rawValue)
                for (key, value) in try YAMLDecoder().decode([String: String].self, from: string) {
                    if (template.manifest.variables ?? []).map({ $0.name }).contains(key) {
                        inputs[key] = value
                    }
                }
            default:
                printError("Cannot read valid input file at \(inputPath.path)")
                return
            }
        } catch {
            printError(error.localizedDescription)
            return
        }
    }

    for variable in (template.manifest.variables ?? []).filter({ !inputs.keys.contains($0.name) }) {
        var output = (variable.displayName ?? variable.name).boldOutput
        if let defaultValue = variable.defaultValue {
            output += " (\(defaultValue))"
        }
        print("\(output): ", terminator: "")
        if let input = readLine() {
            inputs[variable.name] = input
        } else {
            inputs[variable.name] = variable.defaultValue
        }
    }

    // Prehooks.
    if verbose {
        printVerbose("Execute prehooks")
    }
    for prehook in template.manifest.prehooks ?? [] {
        let scriptPath = template.prehookScriptsPath[prehook]
        if scriptPath.exists {
            let work = ShCommand(command: "sh \"\(scriptPath.path)\"")
            var environment = ProcessInfo.processInfo.environment
            environment["FLINT_OUTPUT_PATH"] = outputPath.path
            for (key, input) in inputs {
                environment["FLINT_\(key.replacingOccurrences(of: " ", with: "_"))"] = input
            }
            Executor().sync(work, environment: environment)
        } else {
            printWarning("Cannot find prehook script \(prehook)")
        }
    }

    // Process variables.
    do {
        let templateFilesPath = template.templateFilesPath
        enumerationLoop: for content in try templateFilesPath.enumerated() {
            var relativePath = String(content.path.dropFirst(templateFilesPath.path.count + 1))

            if verbose {
                printVerbose("Process \(relativePath)")
            }

            processVariables(string: &relativePath, template: template, inputs: inputs)

            let contentOutputPath = outputPath[relativePath]

            // Check existing file
            if contentOutputPath.exists {
                if force {
                    try contentOutputPath.remove()
                } else {
                    print("File already exists at \(contentOutputPath.path)")
                    inputLoop: repeat {
                        print("override(o), skip(s), abort(a): ", terminator: "")
                        if let option = readLine() {
                            switch option {
                            case "override", "o":
                                try contentOutputPath.remove()
                                break inputLoop
                            case "skip", "s":
                                continue enumerationLoop
                            case "abort", "a":
                                return
                            default:
                                continue inputLoop
                            }
                        } else {
                            continue inputLoop
                        }
                    } while true
                }
            }

            if !contentOutputPath.parent.exists {
                try contentOutputPath.parent.createDirectory()
            }

            if content.isDirectory {
                try contentOutputPath.createDirectory()
            } else {
                var encoding = String.Encoding.utf8
                if var dataString = try? String(contentsOfFile: content.path, usedEncoding: &encoding) {
                    processVariables(string: &dataString, outputPath: contentOutputPath, template: template, inputs: inputs)
                    try dataString.write(toFile: contentOutputPath.path, atomically: true, encoding: encoding)
                } else {
                    try content.copy(to: contentOutputPath)
                }
            }
        }
    } catch {
        printError(error.localizedDescription)
        return
    }

    // Posthooks.
    if verbose {
        printVerbose("Execute posthooks")
    }
    for posthook in template.manifest.posthooks ?? [] {
        let scriptPath = template.posthookScriptsPath[posthook]
        if scriptPath.exists {
            let work = ShCommand(command: "sh \"\(scriptPath.path)\"")
            var environment = ProcessInfo.processInfo.environment
            environment["FLINT_OUTPUT_PATH"] = outputPath.path
            for (key, input) in inputs {
                environment["FLINT_\(key.replacingOccurrences(of: " ", with: "_"))"] = input
            }
            Executor().sync(work, environment: environment)
        } else {
            printWarning("Cannot find posthook script \(posthook)")
        }
    }

    print("✓".color(.green) + " Generated")
}
