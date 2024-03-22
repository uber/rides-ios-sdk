//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import XCTest
@testable import UberCore

class AsyncDispatcherTests: XCTestCase {
    
    func testCallsAllClosures() {
        let urls: [URL] = [ URL(string: "http://www.google.com")! ]

        let withExp = XCTestExpectation(description: "with closure should be called")
        let continueExp = XCTestExpectation(description: "continue closure should be called")
        let finallyExp = XCTestExpectation(description: "finally closure should be called")

        var finallyCallCount = 0
        var currentUrlIndex = 0

        AsyncDispatcher.exec(for: urls,
                             with: { (url: URL) in
                                XCTAssertEqual(url, urls[currentUrlIndex])
                                currentUrlIndex += 1

                                withExp.fulfill()
                             },
                             asyncMethod: openURLTestMethod(_:completion:),
                             continue: { (error: NSError?) -> Bool in
                                continueExp.fulfill()
                                return true
                             },
                             finally: {
                                finallyCallCount += 1
                                XCTAssertEqual(finallyCallCount, 1)

                                finallyExp.fulfill()
                             })

        wait(for: [withExp, continueExp, finallyExp], timeout: 0.1)
    }

    func testExitsInterationEarly() {
        let urls: [URL] = [ URL(string: "http://www.google.com")!,
                            URL(string: "http://www.uber.com")!,
                            URL(string: "http://www.facebook.com")! ]

        let finallyExp = XCTestExpectation(description: "finally closure should be called")

        var emittedErrors = [NSError]()

        AsyncDispatcher.exec(for: urls,
                             with: { _ in },
                             asyncMethod: openURLTestMethod(_:completion:),
                             continue: { (error: NSError?) -> Bool in
                                if let error = error {
                                    emittedErrors.append(error)
                                    if error.domain == "http://www.uber.com" {
                                        return false
                                    }
                                }
                                return true
                             },
                             finally: {
                                finallyExp.fulfill()
                             })

        wait(for: [finallyExp], timeout: 0.1)

        let expectedErrors = [ NSError(domain: "http://www.google.com", code: 0, userInfo: nil),
                               NSError(domain: "http://www.uber.com", code: 0, userInfo: nil) ]

        XCTAssertEqual(emittedErrors, expectedErrors)
    }

    // MARK: - Test helpers

    func openURLTestMethod(_ url: URL, completion: ((NSError?) -> Void)?) {
        DispatchQueue.main.async {
            let error = NSError(domain: url.absoluteString, code: 0, userInfo: nil)
            completion?(error);
        }
    }

}
