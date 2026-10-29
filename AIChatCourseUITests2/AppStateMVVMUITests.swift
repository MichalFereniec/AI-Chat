import XCTest

@MainActor
final class AppStateMVVMUITests: XCTestCase {

    func testAccountDeletionReturnsToWelcomeAfterConfirmation() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()

        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.navigationBars["Profile"].buttons["Settings"].tap()
        app.collectionViews.buttons["Delete account"].tap()

        let confirmation = app.alerts["Delete Account?"]
        XCTAssertTrue(confirmation.waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["StartButton"].exists)
        confirmation.buttons["Delete"].tap()

        XCTAssertTrue(app.buttons["StartButton"].waitForExistence(timeout: 3))
    }
}
