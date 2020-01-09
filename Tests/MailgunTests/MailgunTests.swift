import XCTest
@testable import Mailgun
import Vapor

final class MailgunTests: XCTestCase {

    func testMessage() {
        let expectation = self.expectation(description: "mailsend")
        let env = ProcessInfo.processInfo.environment
        guard let apiKey = env["MAILGUN_API_KEY"], let domain = env["MAILGUN_DOMAIN"] else {
            XCTFail("Cannot test without defining MAILGUN information")
            return
        }
        let region = env["MAILGUN_REGION"] ?? "us"
        guard let from = env["MAILGUN_TEST_FROM"], let to = env["MAILGUN_TEST_TO"] else {
            XCTFail("Cannot test without defining test FROM and TO")
            return
        }
        guard let app = try? Application() else {
            XCTFail("Cannot create app context")
            return
        }

        let mailgun = Mailgun(apiKey: apiKey, domain: domain, region: (region == "eu") ? .eu: .us)
        let message = Mailgun.Message(from: from, to: to, subject: "TEST: simple mail", text: "simple mail")
        do {
            let future = try mailgun.send(message, on: app)
            future.whenSuccess { value in
                print("\(value)")
            }
            future.whenFailure { error in
                XCTFail("\(error)")
            }
            future.whenComplete {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testTemplateMessage() {
        let expectation = self.expectation(description: "mailsend")
        let env = ProcessInfo.processInfo.environment
        guard let apiKey = env["MAILGUN_API_KEY"], let domain = env["MAILGUN_DOMAIN"] else {
            XCTFail("Cannot test without defining MAILGUN information")
            return
        }
        let region = env["MAILGUN_REGION"] ?? "us"
        guard let from = env["MAILGUN_TEST_FROM"], let to = env["MAILGUN_TEST_TO"] else {
            XCTFail("Cannot test without defining test FROM and TO")
            return
        }
        let template = env["MAILGUN_TEST_TEMPLATE"] ?? "test"
        guard let app = try? Application() else {
            XCTFail("Cannot create app context")
            return
        }
        let mailgun = Mailgun(apiKey: apiKey, domain: domain, region: (region == "eu") ? .eu: .us)
        let message = Mailgun.TemplateMessage(from: from, to: to, subject: "TEST: template mail", template: template, templateData: ["data": "testdata"])

        do {
            let future = try mailgun.send(message, on: app)
            future.whenSuccess { value in
                print("\(value)")
            }
            future.whenFailure { error in
                XCTFail("\(error)")
            }
            future.whenComplete {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        } catch {
            XCTFail("\(error)")
        }
    }

    static var allTests = [
        ("testMessage", testMessage),
        ("testTemplateMessage", testTemplateMessage)
    ]
}
