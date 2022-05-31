import Foundation
import ArgumentParser

enum TypeScript: String, EnumerableFlag {
    case upload
    case download
}

enum UploadType: String, ExpressibleByArgument {
    case androidxml
    case csv
    case xliff12
    case jsonflat
    case jsonnested
    case yamlflat
    case yamlnested
    case properties
    case po
    case strings
}

struct SDOSTraduora: ParsableCommand {
    
    @Flag(help: "Flag that indicates if the script gonna download or upload the strings, by default, its --download | Example: --upload/--download") var typeScript: TypeScript = .download
    
    @Option(help: "Locale key to download, add one param each locale needed separeted by ';'. | Example: es_ES;eu_ES") var lang: String?
    @Option(name: [.customShort("k"), .long], help: "Label used to filter the translations exported by modules.") var label: String?
    @Option(name: [.customShort("c"), .long], help: "Client_id api created in traduora.") var clientId: String
    @Option(name: [.customShort("s"), .long], help: "Client_secret api created in traduora.") var clientSecret: String
    @Option(name: [.customShort("i"), .long], help: "Project id from traduora") var projectId: String
    @Option(name: [.long], help: "Traduora domain server (For example: traduora.sdos.es") var server: String?
    
    @Option(name: [.customShort("o"), .customLong("output-path")], help: "Desired output path for generated files.") var output: String?
    @Option(name: [.customShort("f"), .customLong("output-file-name")], help: "Desired file name for generated files.") var outputFileName: String?
    
    
    @Option(name: [.customShort("u"), .customLong("upload-path")], help: "Desired input path for upload files.") var upload: String?
    @Option(name: [.customShort("t"), .customLong("upload-type")], help: "Desired format for upload files. Default: strings | (androidxml, csv, xliff12, jsonflat, jsonnested, yamlflat, yamlnested, properties, po, strings)") var uploadFormat: UploadType = .strings
    
    
    var authObject: AuthObject!
    var langs: [String] = [String]()
    
    mutating func run() throws {
        auth()
        getLangs()
        
        langs.forEach {
            switch typeScript {
            case .upload:
                uploadLang(language: $0)
            case .download:
                downloadLang(language: $0)
            }
        }
    }
    
    func downloadLang(language: String) {
        print("[SDOSTraduora] Descargando idioma \(language)...")
        LangClass.shared.download(server: server, project: projectId, language: language, output: output ?? "", fileName: outputFileName ?? "", label: self.label)
    }
    
    func uploadLang(language: String) {
        print("[SDOSTraduora] Subiendo idioma \(language)...")
        LangClass.shared.upload(server: server, project: projectId, language: language, fileName: upload ?? "", format: uploadFormat.rawValue)
    }
    
    mutating func getLangs() {
        if let lang = lang {
            self.langs = lang.components(separatedBy: ";")
        }
        
        if self.langs.count == 0 {
            LangClass.shared.langs(project: projectId, server: server)
            if let langs = LangClass.shared.getAllLangs() {
                self.langs = langs
            }
        }
    }
    
    mutating func auth() {
        authObject = AuthObject(clientID: clientId, clientSecret: clientSecret)
        AuthClass.shared.auth(authObject, server: server)
    }
    
}

SDOSTraduora.main()
