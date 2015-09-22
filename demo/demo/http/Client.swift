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
    
    // New Client.send
    func send1(request: NSMutableURLRequest, completion: (transaction: Transaction) -> Void) {
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
    
    func createRequest(method: String, url: String, options: [String: AnyObject], headers:[String: AnyObject], server:String) -> NSMutableURLRequest {
        
        // URL api call for getting token
//        let url = NSURL(string: server + "/restapi/oauth/token")
        // Processing the Body String
        var grant=""
        var username=""
        var password=""
        var ext=""
        var auth=""
        
        // URL api call for getting token
        let url = NSURL(string: server + url)   // UPDATE the server variable
        
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
        // setting up the Authorization header
        if let a = headers["Authorization"] as? String {
            auth = a
        }
        let bodyString = "grant_type=" + grant + "&" + "username=" + username + "&" + "password=" + password + "&" + "extension=" + ext

        // Setting up HTTP request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = method
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let token = headers["Authorize"] as? Bool
        if token == true {
        request.setValue("Basic" + " " + auth, forHTTPHeaderField: "Authorization")
        }
        else {
        request.setValue("Basic" + " " + auth, forHTTPHeaderField: "Authorization")    
        }
        
        

        return request
    }
    
    // Modified Create Request newest
    func createRequest1(options: [String: AnyObject], server:String)-> Request {
        
        var method = ""
        var url = ""
        var headers: [String: String] = ["": ""]
        var query: [String: String]?
        var body: AnyObject = ""
        if let m = options["method"] as? String {
            method = m
        }
        if let u = options["url"] as? String {
            url = server + u
        }
        if let h = options["headers"] as? [String: String] {
            headers = h
        }
        if let q = options["query"] as? [String: String] {
            query = q
        }
        if let b = options["body"] {
            if let check = b as? NSDictionary {
                body = check
            } else {
                body = b as! String
            }
        }
        var request = Request(method: method, url: url, headers: headers, query: query, body: body)
      
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