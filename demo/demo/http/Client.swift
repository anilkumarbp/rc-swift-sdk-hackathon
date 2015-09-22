import Foundation

class Client {
    
    internal var useMock: Bool = false
    internal var appName: String
    internal var appVersion: String
    
    internal var mockRegistry: AnyObject?
    
    init(appName: String = "", appVersion: String = "") {
        self.appName = appName
        self.appVersion = appVersion
    }
    
    func getMockRegistry() -> AnyObject? {
        return mockRegistry
    }
    
    func useMock(flag: Bool = false) -> Client {
        self.useMock = flag
        return self
    }
    
    func send(request: NSMutableURLRequest, completion: (transaction: Transaction) -> Void) {
        if self.useMock {
            sendMock(request) {
                (t) in
                completion(transaction: t)
            }
        } else {
            sendReal(request) {
                (t) in
                completion(transaction: t)
            }
        }
    }
    
    func sendReal(request: NSMutableURLRequest, completion: (transaction: Transaction) -> Void) {
        var trans = Transaction(request: request)
        var task: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            trans.setData(data)
            trans.setResponse(response)
            trans.setError(error)
        }
        task.resume()
    }
    
    func sendMock(request: NSMutableURLRequest, completion: (transaction: Transaction) -> Void) {
        
    }
    
    // Modified create request
    
    func createRequest(method: String, url: String, options: [String: AnyObject], headers:[String: AnyObject]) -> NSMutableURLRequest {
        
        // URL api call for getting token
//        let url = NSURL(string: server + "/restapi/oauth/token")
        // Processing the Body String
        var grant=""
        var username=""
        var password=""
        var ext=""
        // URL api call for getting token
        let url = NSURL(string: server + path)
        
        // Setting up User info for parsing
        if let g = options["grant_type"] as? String {
            grant = g
        }
        if let u = options["username"] as? String {
            username = u
        }
        if let p = options["password"] as? String {
            password = p
        }
        if let e = options["extension"] as? String {
            ext = e
        }
        let bodyString = "grant_type=" + grant + "&" + "username=" + username + "&" + "password=" + password + "&" + "extension=" + ext

        // Setting up HTTP request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Basic" + " " + base64String, forHTTPHeaderField: "Authorization")
        

        return request
    }
    
    // Modified parseProperties 
    
//    func parseProperties(method: String, url: String, query: [String: String]?, body: AnyObject, headers: [String: String]) -> Array {
//        
//        
//    }
//    
    // makes a request
    func requestFactory(method: String, url: String, query: [String: String]?, body: AnyObject, headers: [String: String]) -> NSMutableURLRequest {
        
        var queryFinal: String = ""
        
        if let q = query {
            queryFinal = "?"
            for key in q.keys {
                queryFinal = queryFinal + key + "=" + q[key]! + "&"
            }
        }
        
        var bodyString: String
        
        if let json = body as? [String: AnyObject] {
            bodyString = jsonToString(json)
        } else {
            bodyString = body as! String
        }
        
        var request = NSMutableURLRequest()
        
        if let nsurl = NSURL(string: url + queryFinal) {
            request = NSMutableURLRequest(URL: nsurl)
            request.HTTPMethod = method
            request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
            for key in headers.keys {
                request.setValue(headers[key], forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    func getRequestHeaders() {
        
    }
//    
//    func parseProperties(method: String, url: String, query: [String: String]?, body: AnyObject, headers: [String: String]) -> Array {
//       return Array
//    }
    
    private func jsonToString(json: [String: AnyObject]) -> String {
        var result = "{"
        var delimiter = ""
        for key in json.keys {
            result += delimiter + "\"" + key + "\":"
            var item = json[key]
            if let check = item as? String {
                result += "\"" + check + "\""
            } else {
                if let check = item as? [String: AnyObject] {
                    result += jsonToString(check)
                } else if let check = item as? [AnyObject] {
                    result += "["
                    delimiter = ""
                    for item in check {
                        result += "\n"
                        result += delimiter + "\""
                        result += item.description + "\""
                        delimiter = ","
                    }
                    result += "]"
                } else {
                    result += item!.description
                }
            }
            delimiter = ","
        }
        result = result + "}"
        
        return result
    }
    
}