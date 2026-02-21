//
//  templateRemoveCommandHandler.swift
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
import Bouncer

/// Template remove command handler.
let templateRemoveCommandHandler: CommandHandler = { _, _, operandValues, optionValues in
    // Grab values.
    let templateNames = operandValues
    let verbose = optionValues.have(templateRemoveVerboseOption)

    // Print input summary.
    if verbose {
        printVerbose(
            """
            Input Summary
            └╴Templates: \(templateNames)
            └╴Verbose  : \(verbose)
            """
        )
    }

    // Template paths to remove.
    var templatePathsToRemove: [URL] = []
    do {
        for templateName in templateNames {
            templatePathsToRemove.append(try getTemplateHomePath().appendingPathComponent(templateName))
        }
    } catch {
        printError(error.localizedDescription)
        return
    }

    // Remove templates.
    for templatePathToRemove in templatePathsToRemove {
        if verbose {
            printVerbose("Remove \(templatePathToRemove.path)")
        }

        if (try? Template(path: templatePathToRemove)) == nil {
            printError("Cannot find template at \(templatePathToRemove.path)")
            continue
        }

        do {
            try FileManager.default.removeItem(at: templatePathToRemove)
            print("✓".color(.green) + " Removed")
        } catch {
            printError(error.localizedDescription)
            continue
        }
    }
}
