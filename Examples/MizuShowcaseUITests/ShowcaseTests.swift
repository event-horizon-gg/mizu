import XCTest

final class ShowcaseTests: XCTestCase {
    @MainActor
    func testSelectionActionsAndDisabledState() {
        let app = XCUIApplication()
        app.launchArguments = ["--light"]
        app.launch()
        let controls = app.buttons["Controls"]
        XCTAssertTrue(controls.waitForExistence(timeout: 10))
        controls.tap()
        XCTAssertEqual(app.staticTexts["selected-section"].label, "Controls")
        app.buttons["Primary action"].tap()
        XCTAssertEqual(app.staticTexts["action-feedback"].label, "Primary action selected")
        app.buttons["Secondary action"].tap()
        XCTAssertEqual(app.staticTexts["action-feedback"].label, "Secondary action selected")
        XCTAssertFalse(app.buttons["Unavailable action"].isEnabled)
    }

    @MainActor
    func testLargeTextAndReducedMotionRemainOperable() {
        let app = XCUIApplication()
        app.launchArguments = ["--dark", "--large-text", "--reduce-motion"]
        app.launch()
        XCTAssertTrue(app.buttons["Controls"].waitForExistence(timeout: 10))
        app.buttons["Controls"].tap()
        XCTAssertEqual(app.staticTexts["selected-section"].label, "Controls")
        for _ in 0..<6 {
            if app.buttons["Primary action"].isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(app.buttons["Primary action"].isHittable)
        app.buttons["Primary action"].tap()
        XCTAssertEqual(app.staticTexts["action-feedback"].label, "Primary action selected")
        app.swipeUp()
        app.swipeUp()
        let preview = app.switches["Preview Reduce Motion"]
        XCTAssertTrue(preview.exists)
        XCTAssertEqual(preview.value as? String, "1")
    }
}
