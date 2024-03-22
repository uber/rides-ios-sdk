//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

struct PlistParser {
    
    private let contents: [String: Any]
    
    /// A non-throwing initializer. Any invalid parameters will result in 
    /// empty storage and all keys will return nil.
    /// All keys are checked against the `UberAuth` object contained in the plist.
    ///
    /// - Parameters:
    ///   - name: The name of the plist to access
    ///   - bundle: The bundle the plist is contained in
    init(plistName: String,
         bundle: Bundle = .main) {
        guard let plistUrl = bundle.url(forResource: plistName, withExtension: "plist") else {
            self.contents = [:]
            return
        }
        
        guard let contents = (try? NSDictionary(contentsOf: plistUrl, error: ())) as? [String: Any] else {
            self.contents = [:]
            return
        }
        
        self.contents = contents
    }
    
    /// A throwing initializer. Any invalid parameters will result in
    /// a thrown ParserError indicating the failure.
    /// All keys are checked against the `UberAuth` object contained in the plist.
    ///
    /// - Parameters:
    ///   - name: The name of the plist to access
    ///   - bundle: The bundle the plist is contained in
    init(name: String,
         bundle: Bundle = .main) throws {
        guard let plistUrl = bundle.url(forResource: name, withExtension: "plist") else {
            throw ParserError.noResourceFound
        }
        let contents = (try NSDictionary(contentsOf: plistUrl, error: ())) as? [String: Any] ?? [:]
        self.contents = contents
    }
    
    subscript<T>(key: String) -> T? {
        contents[key] as? T
    }
    
    enum ParserError: Error {
        
        // A plist with the supplied name was not found
        case noResourceFound
        
        // An `UberAuth` object was not found in the plist
        case missingContents
    }
}
