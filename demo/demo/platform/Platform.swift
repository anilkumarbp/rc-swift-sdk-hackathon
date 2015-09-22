import Foundation

/// Platform used to call HTTP request methods.
class Platform {
    
    // Platform constants
    let ACCESS_TOKEN_TTL: Double = 3600 // 60 minutes
    let REFRESH_TOKEN_TTL: Double = 604800 // 1 week
    let TOKEN_ENDPOINT: String = "/restapi/oauth/token"
    let REVOKE_ENDPOINT: String = "/restapi/oauth/revoke"
    let API_VERSION: String = "v1.0"
    let URL_PREFIX: String = "/restapi"
   
    
    
    // Platform credentials
    var auth: Auth?
    var client: Client!
    let server: String
    let appKey: String
    let appSecret: String
    var subscription: Subscription?
    
    /// Constructor for the platform of the SDK
    ///
    /// :param: appKey      The appKey of your app
    /// :param: appSecet    The appSecret of your app
    /// :param: server      Choice of PRODUCTION or SANDBOX
    init(client: Client, appKey: String, appSecret: String, server: String) {
        self.appKey = appKey
        self.appSecret = appSecret
        self.server = server

        self.client = client
    }
    
    
    // To retreive the auth variable
    func getAuth() -> Auth {
        return self.auth!
    }
    
 
    /// Authorizes the user with the correct credentials
    ///
    /// :param: username    The username of the RingCentral account
    /// :param: password    The password of the RingCentral account
    func authorize(username: String, password: String, remember: Bool = true) {
        let authHolder = Auth(username: username, password: password, server: server)
        let feedback = authHolder.login(appKey, secret: appSecret)
        if (feedback.1 as! NSHTTPURLResponse).statusCode / 100 == 2 {
            self.auth = authHolder
        }
    }
    
    // Modified login ( to authorize the user without extensions )
    
    /// :param: username    The username of the RingCentral account
    /// :param: password    The password of the RingCentral account
    func login(username: String, ext: String, password: String, remember: Bool = true) {
        
        let response = requestToken(self.TOKEN_ENDPOINT,options: [
            "grant_type": password,
            "username": username,
            "extension": ext,
            "password": password,
            "acess_token_ttl": self.ACCESS_TOKEN_TTL,
            "refresh_token_ttl": self.REFRESH_TOKEN_TTL
            ])
        let authHolder = Auth(username: username, ext: ext, password: password, server: self.server)
//        let feedback = authHolder.login(appKey, secret: appSecret)
//        if (response.1 as! NSHTTPURLResponse).statusCode / 100 == 2 {
//            self.auth = authHolder
//        }
    }

    
    // Modified requestToken Method()
    
    func requestToken(path:String,options: [String: AnyObject]){
//        var grant=""
//        var username=""
//        var password=""
//        var ext=""
//        // URL api call for getting token
//        let url = NSURL(string: server + path)
//        
//        // Setting up User info for parsing
//        if let g = options["grant_type"] as? String {
//            grant = g
//        }
//        if let u = options["username"] as? String {
//            username = u
//        }
//        if let p = options["password"] as? String {
//            password = p
//        }
//        if let e = options["extension"] as? String {
//            ext = e
//        }
//        let bodyString = "grant_type=" + grant + "&" + "username=" + username + "&" + "password=" + password + "&" + "extension=" + ext
        
        let plainData = (self.appKey + ":" + self.appSecret as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        let headers:[String: AnyObject] = [
            "Authorization":base64String,
            "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
        ]
        
        // createRequest()
        
        let request = self.client.createRequest("POST", url: path, options: options, headers: headers)
        
        return self.sendRequest(request)
        
    }
    
    // Modified sendRequest
    func sendRequest(request:NSMutableURLRequest) {
        
//        inflateRequest(request)
        
        // To do ( send from client)
        return self.client.send(inflateRequest(request),)
        
    }
    
    // Modified inflateRequest()
    // Adding Authorization Header
    
    func inflateRequest(request:NSMutableURLRequest){
        request.setHeader("Authorization", value: "Bearer" + " " + auth!.getAccessToken())
    }

    
    /// Authorizes the user with the correct credentials (with extra ext)
    ///
    /// :param: username    The username of the RingCentral account
    /// :param: password    The password of the RingCentral account
    /// :param: ext         The extension of the RingCentral account
    func authorize(username: String, ext: String, password: String) {
        let authHolder = Auth(username: username, ext: ext, password: password, server: self.server)
        let feedback = authHolder.login(appKey, secret: appSecret)
        if (feedback.1 as! NSHTTPURLResponse).statusCode / 100 == 2 {
            self.auth = authHolder
        }
    }
    
    
    /// Refreshes the Auth object so that the accessToken and refreshToken are updated.
    ///
    /// **Caution**: Refreshing an accessToken will deplete it's current time, and will
    /// not be appended to following accessToken.
    func refresh() {
        if let holder: Auth = self.auth {
            self.auth!.refresh()
        } else {
            notAuthorized()
        }
    }
    
    
    /// Logs the user out of the current account.
    ///
    /// Kills the current accessToken and refreshToken.
    func logout() {
        auth!.revokeToken()
    }
    
    
    /// Returns whether or not the current accessToken is valid.
    ///
    /// :return: A boolean to check the validity of token.
    func isTokenValid() -> Bool {
        return false
    }
    
    
    /// Returns whether or not the current Platform has been authorized with a user.
    ///
    /// :return: A boolean to check the validity of authorization.
    func isAuthorized() -> Bool {
        return auth!.isAccessTokenValid()
    }
    
    /// Tells the user that the platform is not yet authorized.
    ///
    ///
    func notAuthorized() {
        
    }

    
    
    
    // Generic Method Calls
    
    func get(url: String, query: [String: String] = ["": ""]) {
        apiCall([
            "method": "GET",
            "url": url,
            "query": query
            ])
    }
    // Modified get
    func get1(url: String, query: [String: String] = ["": ""], headers: [String: String] = ["": ""], options: [String: AnyObject]) {
        sendRequest(self.client.createRequest([
            "method": "GET",
            "url": url,
            "query": query
            ],server: self.server))
    }
    
    func put(url: String, body: String = "") {
        apiCall([
            "method": "PUT",
            "url": url,
            "body": body
            ])
    }
    
    func post(url: String, body: String = "") {
        apiCall([
            "method": "POST",
            "url": url,
            "body": body
            ])
    }
    
    func delete(url: String) {
        apiCall([
            "method": "DELETE",
            "url": url,
            ])
    }
    
    func apiCall(options: [String: AnyObject]) {
        
        if (auth != nil) {
            if (auth!.authenticated != true) {
                if auth!.refreshing {
                    sleep(1)
                } else {
                    auth!.refresh()
                }
            }
        } else {
            return
        }
        
        if (auth?.authenticated != true) {
            return
        }
        
        var method = ""
        var url = ""
        var headers: [String: String] = ["": ""]
        var query: [String: String]?
        var body: AnyObject = ""
        if let m = options["method"] as? String {
            method = m
        }
        if let u = options["url"] as? String {
            url = self.server + u
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
        
        request.setHeader("Authorization", value: "Bearer" + " " + auth!.getAccessToken())
        request.send()
    }
    
    
    func apiCall(options: [String: AnyObject], completion:  (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        
        if (auth != nil) {
            if (auth!.authenticated != true) {
                if auth!.refreshing {
                    sleep(1)
                } else {
                    auth!.refresh()
                }
            }
        } else {
            return
        }
        
        if (auth?.authenticated != true) {
            return
        }
        
        var method = ""
        var url = ""
        var headers: [String: String] = ["": ""]
        var query: [String: String]?
        var body: AnyObject = ""
        if let m = options["method"] as? String {
            method = m
        }
        if let u = options["url"] as? String {
            url = self.server + u
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
        request.setHeader("Authorization", value: "Bearer" + " " + auth!.getAccessToken())
        request.send() {
            (data, response, error) in
            completion(data: data, response: response, error: error)
        }

    }
    
    

    
}
