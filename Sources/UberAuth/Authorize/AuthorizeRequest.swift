//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

struct AuthorizeRequest: Request {
    
    // MARK: Private Properties
    
    private let app: UberApp?
    private let codeChallenge: String
    private let clientID: String
    private let redirectURI: String
    private let requestURI: String?
    
    // MARK: Initializers
    
    init(app: UberApp?,
         clientID: String,
         codeChallenge: String,
         redirectURI: String,
         requestURI: String?) {
        self.app = app
        self.clientID = clientID
        self.codeChallenge = codeChallenge
        self.redirectURI = redirectURI
        self.requestURI = requestURI
    }
    
    // MARK: Request
    
    struct Response: Codable {}
    
    var parameters: [String : String]? {
        [
            "response_type": "code",
            "client_id": clientID,
            "code_challenge": codeChallenge,
            "code_challenge_method": "S256",
            "redirect_uri": redirectURI,
            "request_uri": requestURI
        ]
        .compactMapValues { $0 }
    }
    
    var host: String? = nil
    
    var path: String {
        let identifier = app?.urlIdentifier ?? "universal"
        return "/oauth/v2/\(identifier)/authorize"
    }
}
