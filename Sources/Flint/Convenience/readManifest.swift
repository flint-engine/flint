//
//  readManifest.swift
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
import Yams

/// Read JSON manifest file.
///
/// - Parameter path: Path for JSON manifest file.
/// - Returns: Manifest.
/// - Throws: Read data error. Decode error.
func readJSONManifest(atPath path: URL) throws -> Manifest {
    let data = try Data(contentsOf: path)
    return try JSONDecoder().decode(Manifest.self, from: data)
}

/// Read YAML manifest file.
///
/// - Parameter path: Path for YAML manifest file.
/// - Returns: Manifest.
/// - Throws: Read data error. Decode error.
func readYAMLManifest(atPath path: URL) throws -> Manifest {
    let string = try String(contentsOf: path, encoding: .utf8)
    return try YAMLDecoder().decode(Manifest.self, from: string)
}
