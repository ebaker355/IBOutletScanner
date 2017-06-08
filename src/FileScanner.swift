/*
 MIT License

 Copyright (c) 2017 DuneParkSoftware, LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

import Foundation

enum FileScannerError: Error {
    case noPath
    case fileSystemError(path: String)
}

extension FileScannerError: CustomStringConvertible {
    var description: String {
        switch self {
        case .noPath:
            return "No search path specified"
        case .fileSystemError(let path):
            return "Can't access path: " + String(describing: path)
        }
    }
}

public struct FileScanner {
    typealias FileScannerProcessor = (_ file: URL) throws -> Void

    func processFiles(ofTypes fileTypes: [String], inPath path: String, _ processor: FileScannerProcessor) throws {
        guard path.count > 0 else {
            throw FileScannerError.noPath
        }

        guard let enumerator = FileManager.default.enumerator(atPath: path) else {
            throw FileScannerError.fileSystemError(path: path)
        }

        let rootURL = URL(fileURLWithPath: path)

        while let dir = enumerator.nextObject() as? String {
            let fileURL = rootURL.appendingPathComponent(dir)
            if fileTypes.contains(fileURL.pathExtension) {
                try processor(fileURL)
            }
        }
    }
}
