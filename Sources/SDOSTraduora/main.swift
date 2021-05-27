import Foundation
import ArgumentParser

//    TRADUORA_USER=oleg.tverdyy@sdos.es
//    TRADUORA_PASSWORD=sdos_0845
//    TRADUORA_CLIENT=3c44da2f-800f-49e1-8d67-3ab6a5268599
//    TRADUORA_SECRET=Vn9eFccrlQb7NmPD14jn3XzfdWiMHWta
//    TRADUORA_PROJECT=0ba33469-8cee-42b1-a638-1885a71ed4cf

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

//let semaphore = DispatchSemaphore(value: 0)
//
//let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
//    if let data = data, let dataString = String(data: data, encoding: .utf8) {
//        print(dataString)
//    }
//    semaphore.signal()
//}
//
//task.resume()
//semaphore.wait()
