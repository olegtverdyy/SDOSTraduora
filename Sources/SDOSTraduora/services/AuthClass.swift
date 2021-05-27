//
//  File.swift
//  
//
//  Created by Oleg Tverdyy on 27/5/21.
//

import Foundation

final class AuthClass {
    static let shared = AuthClass()
    
    private init() { }
    
    private var authObject: AuthDTO?
    
    func auth(_ form: AuthObject) {
        
        guard let parameters = try? form.jsonData() else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = NSMutableURLRequest(url: NSURL(string: "\(Constants.ws.baseUrl)\(Constants.ws.auth)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = parameters
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let data = data else {
                semaphore.signal()
                return
            }

            if let auth = try? AuthDTO(data: data) {
                self.authObject = auth
            }
            
            semaphore.signal()
        })
        
        dataTask.resume()
        
        semaphore.wait()
    }
    
    func printAuth() {
        dump(authObject)
    }
    
    func bearer() -> String {
        "Bearer \(authObject?.accessToken ?? "")"
    }
}
