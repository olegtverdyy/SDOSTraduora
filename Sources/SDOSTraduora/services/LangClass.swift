//
//  File.swift
//  
//
//  Created by Oleg Tverdyy on 27/5/21.
//

import Foundation

final class LangClass {
    static let shared = LangClass()
    
    private init() { }
    
    private var langs: [String]?
    
    func langs(project: String) {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ws.baseUrl)\(Constants.ws.langs(project: project))")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = "get"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "authorization": AuthClass.shared.bearer()
        ]
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let data = data else {
                semaphore.signal()
                return
            }
            
            if let lang = try? LangDTO(data: data) {
                self.langs = lang.data.map { $0.locale.code }
            }
            
            semaphore.signal()
        })
        
        dataTask.resume()
        
        semaphore.wait()
    }
    
    func download(project: String, language: String, output: String, label: String? = nil) {
        let semaphore = DispatchSemaphore(value: 0)
        
        var components = URLComponents(string: "\(Constants.ws.baseUrl)\(Constants.ws.downloadLang(project: project, language: language, label: label))")!

        components.queryItems = [
            URLQueryItem(name: "locale", value: language),
            URLQueryItem(name: "format", value: "jsonnested")
        ]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        let request = NSMutableURLRequest(url: components.url!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/octet-stream",
            "authorization": AuthClass.shared.bearer()
        ]
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let data = data else {
                semaphore.signal()
                return
            }
            
            if let items = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String] {
                let directoryName = "\(output)/\(language.split(separator: "_").first!).lproj"
                
                let fileManager = FileManager.default
                var isDir: ObjCBool = false
                
                if !fileManager.fileExists(atPath: directoryName, isDirectory: &isDir) {
                    try? fileManager.createDirectory(atPath: directoryName, withIntermediateDirectories: true, attributes: nil)
                }
                
                let filePath = "\(directoryName)/Localizable.generated.strings"
                do {
                    let header = """
                    //  This is a generated file, do not edit!
                    //  Localizable.generated.strings
                    //
                    //  Created by SDOS
                    //
                    //  Generate \(items.count) keys
                    """
                    let strings = items.map {
                        var finalLine = self.formatLine("\"\($0.key)\" = \"\($0.value)\";")
                        while finalLine.contains("{") {
                            finalLine = self.formatLine(finalLine)
                        }
                        return finalLine
                    }.joined(separator: "\n")
                    try [header, strings].joined(separator: "\n\n").write(toFile: filePath, atomically: true, encoding: .utf8)
                } catch { print(error.localizedDescription) }
            }
            
            semaphore.signal()
            
        })
        
        dataTask.resume()
        
        
        semaphore.wait()
    }
    
    func formatLine(_ line: String) -> String {
        
        var lineFinal = line
        
        lineFinal.removingRegexMatches(pattern: "%\\d", replaceWith: "")
        lineFinal = lineFinal.replacingOccurrences(of: "%", with: "%%")
        
        
        if let slice = lineFinal.slice(from: "{", to: "}") {
            if slice == "string" {
                lineFinal = lineFinal.replacingOccurrences(of: "{\(slice)}", with: "%@")
            } else if slice == "int" {
                lineFinal = lineFinal.replacingOccurrences(of: "{\(slice)}", with: "%ld")
            } else if slice.contains("int") {
                let valueToRemplace = slice.replacingOccurrences(of: "int", with: "ld")
                lineFinal = lineFinal.replacingOccurrences(of: "{\(slice)}", with: "%\(valueToRemplace)")
            }
        }

        return lineFinal
    }
    
    func getAllLangs() -> [String]? {
        langs
    }
    
}
