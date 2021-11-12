import Foundation
import ArgumentParser

struct SDOSTraduora: ParsableCommand {
    
    @Option(help: "Locale key to download, add one param each locale needed separeted by ';'. | Example: es_ES;eu_ES") var lang: String?
    @Option(name: [.customShort("k"), .long], help: "Label used to filter the translations exported by modules.") var label: String?
    
    @Option(name: [.customShort("u"), .long], help: "User used to login in traduora.") var user: String
    @Option(name: [.customShort("p"), .long], help: "Password used to login in traduora.") var password: String
    @Option(name: [.customShort("c"), .long], help: "Client_id api created in traduora.") var clientId: String
    @Option(name: [.customShort("s"), .long], help: "Client_secret api created in traduora.") var clientSecret: String
    @Option(name: [.customShort("i"), .long], help: "Project id from traduora") var projectId: String
    @Option(name: [.long], help: "Traduora domain server (For example: traduora.sdos.es") var server: String?
    
    @Option(name: [.customShort("o"), .customLong("output-path")], help: "Desired output path for generated files.") var output: String
    
    var authObject: AuthObject!
    var langs: [String] = [String]()
    
    mutating func run() throws {
        auth()
        getLangs()
        
        langs.forEach {
            downloadLang(language: $0)
        }
    }
    
    func downloadLang(language: String) {
        print("Downloading ... \(language)")
        LangClass.shared.download(server: server, project: self.projectId, language: language, output: self.output, label: self.label)
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
        authObject = AuthObject(username: user, password: password, clientID: clientId, clientSecret: clientSecret)
        AuthClass.shared.auth(authObject, server: server)
    }
    
}

SDOSTraduora.main()
