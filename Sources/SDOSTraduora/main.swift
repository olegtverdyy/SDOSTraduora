import Foundation
import ArgumentParser

struct SDOSTraduora: ParsableCommand {
    
    @Option(help: "The lang separeted by ';' Example: es_ES;eu_ES") var lang: String?
    @Option(name: [.customShort("k"), .long]) var label: String?
    
    @Option(name: [.customShort("u"), .long]) var user: String
    @Option(name: [.customShort("p"), .long]) var password: String
    @Option(name: [.customShort("c"), .long]) var clientId: String
    @Option(name: [.customShort("s"), .long]) var clientSecret: String
    @Option(name: [.customShort("i"), .long]) var projectId: String
    
    @Option(name: [.customShort("o"), .customLong("output-path")]) var output: String
    
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
        LangClass.shared.download(project: self.projectId, language: language, output: self.output, label: self.label)
    }
    
    mutating func getLangs() {
        if let lang = lang {
            self.langs = lang.components(separatedBy: ";")
        }
        
        if self.langs.count == 0 {
            LangClass.shared.langs(project: projectId)
            if let langs = LangClass.shared.getAllLangs() {
                self.langs = langs
            }
        }
    }
    
    mutating func auth() {
        authObject = AuthObject(username: user, password: password, clientID: clientId, clientSecret: clientSecret)
        AuthClass.shared.auth(authObject)
    }
    
}

SDOSTraduora.main()
