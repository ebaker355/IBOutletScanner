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

public struct Options {
    public let rootPath: String
    public let customViewClassNames: [String]

    private init(rootPath: String, customViewClassNames: [String]) {
        self.rootPath = rootPath
        self.customViewClassNames = customViewClassNames
    }

    private static var defaultRootPath: String? {
        let environment = ProcessInfo.processInfo.environment
        if let srcRoot = environment["SRCROOT"] {
            return srcRoot
        }
        return nil
    }

    public static func createFromCommandLineArguments() -> Options {
        var rootPath = Options.defaultRootPath ?? ""
        var customViewClassNames: [String] = []

        var isCustomViewClassNamesArg = false
        for (index, arg) in CommandLine.arguments.enumerated() {
            guard index > 0 else {
                continue
            }

            guard !isCustomViewClassNamesArg else {
                customViewClassNames.append(contentsOf: arg.components(separatedBy: ","))
                isCustomViewClassNamesArg = false
                continue
            }

            guard arg != "-customViewClassNames" && arg != "-customViewClassName" else {
                isCustomViewClassNamesArg = true
                continue
            }

            rootPath = arg
        }

        return Options(rootPath: rootPath, customViewClassNames: customViewClassNames)
    }
}
