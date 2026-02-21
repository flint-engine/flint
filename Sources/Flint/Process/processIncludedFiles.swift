//
//  processIncludedFiles.swift
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

/// Process all kind of included files.
///
/// - Parameters:
///   - string: Raw string.
///   - includedFilesPath: Included files path.
func processIncludedFiles(string: inout String, includedFilesPath: URL) {
    processIncludedFiles(string: &string, includedFilesPath: includedFilesPath, tagOpening: "___", tagClosing: "___")
    processIncludedFiles(string: &string, includedFilesPath: includedFilesPath, tagOpening: "__", tagClosing: "__")
    processIncludedFiles(string: &string, includedFilesPath: includedFilesPath, tagOpening: "--", tagClosing: "--")
    processIncludedFiles(string: &string, includedFilesPath: includedFilesPath, tagOpening: "\\{\\{", tagClosing: "\\}\\}")
}

/// Process included files with specific tag opening and closing.
///
/// - Parameters:
///   - string: Raw string.
///   - includedFilesPath: Included files path.
///   - tagOpening: Tag opening.
///   - tagClosing: Tag closing.
func processIncludedFiles(string: inout String, includedFilesPath: URL, tagOpening: String, tagClosing: String) {
    repeat {
        // Get include tag
        let regex = "(?<=\(tagOpening)INCLUDE:)(.*?)(?=\(tagClosing))"
        guard let includeTagRange = string.range(of: regex, options: .regularExpression) else {
            break
        }
        let includeTag = String(string[includeTagRange])
        let includedFileString = (try? String(contentsOf: includedFilesPath.appendingPathComponent(includeTag))) ?? ""

        // Replace tag
        let trimmedTagOpening = tagOpening.replacingOccurrences(of: "\\", with: "")
        let trimmedTagClosing = tagClosing.replacingOccurrences(of: "\\", with: "")
        let tag = "\(trimmedTagOpening)INCLUDE:\(includeTag)\(trimmedTagClosing)"
        string = string.replacingOccurrences(of: tag, with: includedFileString)
    } while true
}
