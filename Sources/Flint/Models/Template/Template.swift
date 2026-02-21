//
//  Template.swift
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

/// Template.
struct Template {

    /// Manifest.
    let manifest: Manifest
    /// Template files path.
    let templateFilesPath: URL
    /// Included files path.
    let includedFilesPath: URL
    /// Prehook scripts path.
    let prehookScriptsPath: URL
    /// Posthook scripts path.
    let posthookScriptsPath: URL
    /// Template path.
    let path: URL

    /// Initialize template.
    ///
    /// - Parameter path: Path for template directory.
    /// - Throws: Template format error.
    init(path: URL) throws {
        // Read manifest.
        if FileManager.default.fileExists(atPath: path.appendingPathComponent("template.json").path) {
            manifest = try readJSONManifest(atPath: path.appendingPathComponent("template.json"))
        } else if FileManager.default.fileExists(atPath: path.appendingPathComponent("template.yaml").path) {
            manifest = try readYAMLManifest(atPath: path.appendingPathComponent("template.yaml"))
        } else if FileManager.default.fileExists(atPath: path.appendingPathComponent("template.yml").path) {
            manifest = try readYAMLManifest(atPath: path.appendingPathComponent("template.yml"))
        } else {
            throw TemplateFormatError.manifestFileNotExists(path)
        }
        // Set paths.
        templateFilesPath = path.appendingPathComponent("template")
        includedFilesPath = path.appendingPathComponent("include")
        prehookScriptsPath = path.appendingPathComponent("prehooks")
        posthookScriptsPath = path.appendingPathComponent("posthooks")
        self.path = path
    }
}
