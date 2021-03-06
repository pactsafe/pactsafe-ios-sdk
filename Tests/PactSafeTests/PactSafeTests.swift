import XCTest
@testable import PactSafe

final class PactSafeTests: XCTestCase {
    
    private var psApp: PSApp!
    private var invalidAccessId: String! = "random-invalid-access-id"
    private var testSiteAccessId: String!
    private let maxTimeout: Double = 5
    
    override func setUp() {
        // Set up the shared app
        psApp = PSApp.shared
        psApp.debugMode = true
        testSiteAccessId = ProcessInfo.processInfo.environment["testSiteAccessId"]!
    }
    
    func testConfiguringSiteAccessId() {
        psApp.configure(siteAccessId: invalidAccessId)
        XCTAssertEqual(psApp.siteAccessId, invalidAccessId)
    }
    
    // MARK: Test Loading Groups
    func testLoadingGroupWithFakeKeys() {
        psApp.configure(siteAccessId: invalidAccessId)
        let gkey: String = "example-group"
        let expect = expectation(description: "GET group with key: \(gkey)")
        psApp.loadGroup(groupKey: gkey) { (group, error) in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testLoadingGroupWithGroupKey() {
        psApp.configure(siteAccessId: testSiteAccessId)
        let gkey: String = "example-mobile-app-group"
        let expect = expectation(description: "GET group with key: \(gkey)")
        psApp.loadGroup(groupKey: gkey) { (group, error) in
            XCTAssertNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Test Sending Events
    func testSendingAgreedEvent() {
        let userSignerId: PSSignerID = "example@example.com"
        let signer: PSSigner = PSSigner(signerId: userSignerId)
        let gkey: String = "example-mobile-app-group"
        let expect = expectation(description: "Send activity for signer: \(signer)")
        psApp.configure(siteAccessId: testSiteAccessId)
        psApp.loadGroup(groupKey: gkey) { (group, error) in
            XCTAssertNotNil(group)
            self.psApp.sendActivity(.agreed, signer: signer, group: group!, testMode: true) { (error) in
                XCTAssertNil(error)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testSendingUpdatedEvent() {
        let userSignerId: PSSignerID = "example@example.com"
        let signer: PSSigner = PSSigner(signerId: userSignerId)
        let gkey: String = "example-mobile-app-group"
        let expect = expectation(description: "Send activity for signer: \(signer)")
        psApp.configure(siteAccessId: testSiteAccessId)
        psApp.loadGroup(groupKey: gkey) { (group, error) in
            XCTAssertNotNil(group)
            self.psApp.sendActivity(.updated, signer: signer, group: group!, testMode: true) { (error) in
                XCTAssertNil(error)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Test Getting Signed Status
    func testGettingSignedStatusFakeKeys() {
        let signer: PSSignerID = "examplefake@example.com"
        let gkey: String = "example-fake-group-key"
        let expect = expectation(description: "Get signer status for the signer \(signer)")
        psApp.configure(siteAccessId: invalidAccessId)
        psApp.signedStatus(for: signer, groupKey: gkey) { (needsAcceptance, contractIds) in
            XCTAssertEqual(false, needsAcceptance)
            XCTAssert((contractIds) != nil)
            expect.fulfill()
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Test Preloading Group
    func testPreloadingGroupWithFakeKeys() {
        let gkey: String = "example-fake-group-key"
        let expect = expectation(description: "Preload the group with key \(gkey)")
        psApp.configure(siteAccessId: invalidAccessId)
        psApp.preload(withGroupKey: gkey, refreshCacheData: true) { (loaded) in
            XCTAssertEqual(false, loaded)
            XCTAssertEqual(false, self.psApp.preloaded)
            expect.fulfill()
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPreloadingGroupWithKey() {
        let gkey: String = "example-mobile-app-group"
        let expect = expectation(description: "Preload the group with key \(gkey)")
        psApp.configure(siteAccessId: testSiteAccessId)
        psApp.preload(withGroupKey: gkey) { (loaded) in
            XCTAssertEqual(true, loaded)
            XCTAssertEqual(true, self.psApp.preloaded)
            expect.fulfill()
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
}
