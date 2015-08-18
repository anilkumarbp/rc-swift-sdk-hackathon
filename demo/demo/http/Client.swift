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
    
    func send(request: NSMutableURLRequest) {
        if self.useMock {
            sendMock(request)
        } else {
            sendReal(request)
        }
    }
    
    func sendReal(request: NSMutableURLRequest) {
        var task: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request)
        task.resume()
    }
    
    func sendReal(request: NSMutableURLRequest, completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        var task: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (d, r, e) in
            completion(data: d, response: r, error: e)
        }
        task.resume()
    }
    
    func sendMock(request: NSMutableURLRequest) {
        
    }
    
    
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
    
    func parseProperties() {
        
    }
    
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