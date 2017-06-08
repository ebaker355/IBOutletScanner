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

public class IBOutletScanner {

    static let options = Options.createFromCommandLineArguments()

    private lazy var connections: [IBOutletConnection] = { return [] }()
    private lazy var views: [IBView] = { return [] }()
    private let outletElementTypes = ["outlet"]
    private let viewElementTypes = ["barButtonItem", "button", "label", "segmentedControl",
                                    "tabBarItem", "tableView", "textField", "textView", "view"]

    typealias IgnoreViewFilterName = String
    typealias IgnoreViewFilterValues = [String]
    typealias IgnoreViewFilters = [ IgnoreViewFilterName : IgnoreViewFilterValues]

    private let ignoreViewFilters: IgnoreViewFilters = ["systemItem" : ["flexibleSpace",
                                                                        "fixedSpace"]]

    public static func run() -> Int32 {
        let fileScanner = FileScanner()
        let rootPath = options.rootPath

        do {
            try fileScanner.processFiles(ofTypes: ["storyboard", "xib"], inPath: rootPath) { file in
                let scanner = IBOutletScanner()
                try scanner.scan(ibFile: file)
                for view in scanner.disconnectedViews {
                    print("warning: disconnected view: " + String(describing: view) +
                          " in file: " + scanner.path(toFile: file, relativeToRootPath: rootPath))
                }
            }
        }
        catch {
            print("error: " + String(describing: error))
            return 1
        }

        return 0
    }

    public func path(toFile file: URL, relativeToRootPath rootPath: String) -> String {
        var path = file.path.replacingOccurrences(of: rootPath, with: "")
        while path.hasPrefix("/") {
            path.remove(at: path.startIndex)
        }
        return path
    }

    public var disconnectedViews: [IBView] {
        return views.filter { view in
            return connections.filter({ connection in
                connection.connectsToObject(withIdentifier: view.identifier)
            }).count < 1
        }
    }

    private func scan(ibFile: URL) throws {
        let xml = try String(contentsOf: ibFile)
        let xmlIndexer = SWXMLHash.lazy(xml)
        parse(xml: xmlIndexer)
    }

    private func parse(xml: XMLIndexer) {
        xml.children.forEach { child in
            guard let element = child.element else { return }

            // Collect outlets
            if outletElementTypes.contains(element.name) {
                if let destination = element.allAttributes["destination"] {
                    connections.append(IBOutletConnection(destination: destination.text))
                }
            }

            // Collect view objects
            let type = element.name
            if viewElementTypes.contains(type) && !shouldIgnore(viewElement: element) {
                if let identifier = element.allAttributes["id"] {
                    let customClass = element.allAttributes["customClass"]?.text ?? ""

                    if type != "view" ||
                        (type == "view" && IBOutletScanner.options.customViewClassNames.contains(customClass)) {
                        views.append(IBView(identifier: identifier.text, type: type, customClass: customClass))
                    }
                }
            }

            parse(xml: child)
        }
    }

    private func shouldIgnore(viewElement element: XMLElement) -> Bool {
        // TODO: How can we "functionalize" these loops?
        for filter in ignoreViewFilters {
            let name = filter.key
            if let attribute = element.allAttributes[name]?.text {
                for value in filter.value {
                    if attribute == value {
                        return true
                    }
                }
            }
        }
        return false
    }
}
