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
        testSiteAccessId = ProcessInfo.processInfo.environment["testSiteAccessId"]!
    }
    
    func testConfiguringSiteAccessId() {
        psApp.configure(siteAccessId: invalidAccessId)
        XCTAssertEqual(psApp.siteAccessId, invalidAccessId)
    }
    
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
    
    func testGettingSignedStatusFakeKeys() {
        let signer: PSSignerID = "examplefake@example.com"
        let gkey: String = "example-fake-group-key"
        let expect = expectation(description: "Get signer status for the signer \(signer)")
        psApp.configure(siteAccessId: invalidAccessId)
        psApp.signedStatus(for: signer, groupKey: gkey) { (needsAcceptance, contractIds) in
            XCTAssertNil(contractIds)
            expect.fulfill()
        }
        waitForExpectations(timeout: maxTimeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPreloadingWithFakeKeys() {
        let gkey: String = "example-fake-group-key"
        let expect = expectation(description: "Preload the group key \(gkey)")
        psApp.configure(siteAccessId: invalidAccessId)
        psApp.preload(withGroupKey: gkey)
        expect.fulfill()
        XCTAssertEqual(false, psApp.preloaded)
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
