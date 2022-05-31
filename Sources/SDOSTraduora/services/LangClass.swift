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
    
    private var cleanDirectory = false
    
    private var langs: [String]?
    
    func langs(project: String, server: String?) {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ws.getBaseUrl(server: server))\(Constants.ws.langs(project: project))")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = Constants.ws.method.GET
        request.allHTTPHeaderFields = [
            Constants.ws.headers.contentType: Constants.ws.headers.value.json,
            Constants.ws.headers.authorization: AuthClass.shared.bearer()
        ]
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let data = data else {
                print("[SDOSTraduora] Error al recuperar los lenguajes de las traducciones. Error: \(error!.localizedDescription)")
                semaphore.signal()
                exit(11)
            }
            
            if let lang = try? LangDTO(data: data) {
                self.langs = lang.data.map { $0.locale.code }
            }
            
            semaphore.signal()
        })
        
        dataTask.resume()
        
        semaphore.wait()
    }
    
    
    func upload(server: String?, project: String, language: String, fileName: String, format: String = "strings") {
        let semaphore = DispatchSemaphore(value: 0)
        
        guard let url = URL(string: "file://\(fileName)"), let fileData = try? Data(contentsOf: url)
        else {
            print("[SDOSTraduora] El fichero no es correcto.")
            exit(9)
        }
        
        var components = URLComponents(string: "\(Constants.ws.getBaseUrl(server: server))\(Constants.ws.upload(project: project))")!
        
        components.queryItems = [
            URLQueryItem(name: Constants.ws.query.locale, value: language),
            URLQueryItem(name: Constants.ws.query.format, value: format)
        ]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        let request = NSMutableURLRequest(url: components.url!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = Constants.ws.method.POST
        
        let boundary = UUID().uuidString
        
        let fileName = url.lastPathComponent
        let mimetype = mimeType(for: fileName)
        let paramName = "file"
        
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.allHTTPHeaderFields = [
            Constants.ws.headers.contentType: "multipart/form-data; boundary=\(boundary)",
            Constants.ws.headers.contentLenght: String(data.count),
            Constants.ws.headers.authorization: AuthClass.shared.bearer()
        ]
        
        let session = URLSession.shared
        let dataTask = session.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let _ = data else {
                print("[SDOSTraduora] Error al recuperar las traducciones. Error: \(error!.localizedDescription)")
                semaphore.signal()
                exit(10)
            }
            print("[SDOSTraduora] Traduccion subida correctamente.")
            
            semaphore.signal()
        })
        
        dataTask.resume()
        semaphore.wait()
    }
    
    private func mimeType(for path: String) -> String {
        let pathExtension = URL(fileURLWithPath: path).pathExtension as NSString
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
            let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
        else {
            return "application/octet-stream"
        }
        
        return mimetype as String
    }
    
    func download(server: String?, project: String, language: String, output: String, fileName: String, label: String? = nil) {
        guard output.isEmpty || fileName.isEmpty else {
            print("[SDOSTraduora] No se ha proporcionado ruta de salida o nombre del fichero de salida.")
            exit(9)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var components = URLComponents(string: "\(Constants.ws.getBaseUrl(server: server))\(Constants.ws.downloadLang(project: project, language: language, label: label))")!
        
        components.queryItems = [
            URLQueryItem(name: Constants.ws.query.locale, value: language),
            URLQueryItem(name: Constants.ws.query.format, value: Constants.ws.query.value.jsonNested)
        ]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        let request = NSMutableURLRequest(url: components.url!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = Constants.ws.method.GET
        request.allHTTPHeaderFields = [
            Constants.ws.headers.contentType: Constants.ws.headers.value.octet,
            Constants.ws.headers.authorization: AuthClass.shared.bearer()
        ]
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let data = data else {
                print("[SDOSTraduora] Error al recuperar las traducciones. Error: \(error!.localizedDescription)")
                semaphore.signal()
                exit(10)
            }
            if let items = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String] {
                let directoryName = "\(output)/\(language.split(separator: "_").first!).lproj"
                print("[SDOSTraduora] Generando fichero para el idioma \(language)")
                
                let fileManager = FileManager.default
                var isDir: ObjCBool = false
                
                if !self.cleanDirectory {
                    self.cleanDirectory = true
                    try? fileManager.removeItem(atPath: "\(output)")
                }
                
                if !fileManager.fileExists(atPath: directoryName, isDirectory: &isDir) {
                    do {
                        try fileManager.createDirectory(atPath: directoryName, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("[SDOSTraduora] Error al crear la carpeta para las traduciones \(directoryName). Error: \(error)")
                        exit(12)
                    }
                }
                
                let filePath = "\(directoryName)/\(fileName)"
                do {
                    let header = """
                    //  This is a generated file, do not edit!
                    //  Localizable.generated.strings
                    //
                    //  Generate \(items.count) keys
                    """
                    let strings = items.sorted(by: { e1, e2 in
                        e1.key < e2.key
                    }).map {
                        return "\"\($0.key)\" = \"\(self.formatLine($0.value))\";"
                    }.joined(separator: "\n")
                    try [header, strings].joined(separator: "\n\n").write(toFile: filePath, atomically: true, encoding: .utf8)
                } catch {
                    print("[SDOSTraduora] Error al generar el fichero de traducciones para el idioma \(language) en \(filePath). Error \(error.localizedDescription)")
                }
                print("[SDOSTraduora] Fichero generado para el idioma \(language) en \(filePath)")
            } else {
                if let json = String(data: data, encoding: .utf8) {
                    print("[SDOSTraduora] Error al parsear el JSON para el idioma \(language). JSON: \(json)")
                } else {
                    print("[SDOSTraduora] Error al parsear el JSON para el idioma \(language)")
                }
                exit(13)
            }
            semaphore.signal()
            
        })
        
        dataTask.resume()
        
        
        semaphore.wait()
    }
    
    func formatLine(_ line: String) -> String {
        
        var lineFinal = line
        
        lineFinal = lineFinal.replacingOccurrences(of: "%", with: "%%")
        lineFinal = lineFinal.replacingOccurrences(of: "\"", with: "\\\"")
        lineFinal = lineFinal.replacingOccurrences(of: "\n", with: "\\n")
        lineFinal = lineFinal.replaceRegexNumber()
        lineFinal = lineFinal.replaceRegexDecimal()
        lineFinal = lineFinal.replaceRegexString()
        
        return lineFinal
    }
    
    func getAllLangs() -> [String]? {
        langs
    }
    
}
