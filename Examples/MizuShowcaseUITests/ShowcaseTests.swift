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
        snapshot(app, name: "Foundations light")
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
        snapshot(app, name: "Accessibility text dark")
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

    @MainActor
    private func catalogue(_ category: String, effects: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = effects ? ["--dark"] : ["--light", "--reduce-motion", "--no-effects"]
        app.launch()
        let link = app.buttons["Component catalogue"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        app.staticTexts[category].tap()
        snapshot(app, name: category)
        return app
    }

    @MainActor
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<8 {
            if element.exists && element.isHittable { return }
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor
    func testFormChoicesAndCopyFeedback() {
        let app = catalogue("Choices & inputs")
        app.descendants(matching: .any).matching(identifier: "Notifications").firstMatch.tap()
        app.descendants(matching: .any).matching(identifier: "Sound").firstMatch.tap()
        XCTAssertEqual(app.staticTexts["checkbox-result"].label, "Selected: Sound")
        app.buttons["Focused"].tap()
        XCTAssertEqual(app.staticTexts["radio-result"].label, "Mode: Focused")
        app.switches["Private mode"].tap()
        XCTAssertEqual(app.switches["Private mode"].value as? String, "1")
        let check = app.buttons["Check email"]
        reveal(check, in: app)
        check.tap()
        XCTAssertTrue(app.staticTexts["Include an @ in your email"].exists)
        let copy = app.buttons["Copy"]
        reveal(copy, in: app)
        copy.tap()
        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testComposerRejectsEmptyAndSendsOnce() {
        let app = catalogue("Conversation")
        let field = app.textFields["Message"]
        reveal(field, in: app)
        XCTAssertFalse(app.buttons["Send"].isEnabled)
        field.tap()
        field.typeText("  ")
        XCTAssertFalse(app.buttons["Send"].isEnabled)
        field.typeText("Hello Mizu")
        reveal(app.buttons["Send"], in: app)
        app.buttons["Send"].tap()
        XCTAssertEqual(app.staticTexts["sent-count"].label, "Sent: 1")
        XCTAssertTrue(app.staticTexts["Hello Mizu"].exists)
        XCTAssertFalse(app.buttons["Send"].isEnabled)
    }

    @MainActor
    func testQuestionsPreserveAnswersAndCompleteOnce() {
        let app = catalogue("Questions")
        XCTAssertFalse(app.buttons["Continue"].isEnabled)
        app.buttons["Personal"].tap()
        app.buttons["Continue"].tap()
        XCTAssertFalse(app.buttons["Finish"].isEnabled)
        app.buttons["Cards"].tap()
        app.buttons["Coverage"].tap()
        app.buttons["Back"].tap()
        XCTAssertTrue(app.buttons["Personal"].isSelected)
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Cards"].isSelected)
        XCTAssertTrue(app.buttons["Coverage"].isSelected)
        reveal(app.buttons["Finish"], in: app)
        app.buttons["Finish"].tap()
        XCTAssertEqual(app.staticTexts["question-result"].label, "Complete: 2 answers")
        XCTAssertFalse(app.buttons["Finish"].exists)
    }

    @MainActor
    func testAccordionDialogAndTableSorting() {
        let app = catalogue("Presentation & data")
        app.buttons["How surfaces work"].tap()
        XCTAssertTrue(app.staticTexts["Soft layers keep content readable."].exists)
        app.buttons["Open dialog"].tap()
        XCTAssertTrue(app.staticTexts["This sheet supports native focus, scrolling and dismissal."].waitForExistence(timeout: 3))
        app.buttons["Close"].tap()
        reveal(app.buttons["Name"], in: app)
        app.buttons["Name"].tap()
        let kai = app.staticTexts["Name: Kai"]
        let zoe = app.staticTexts["Name: Zoe"]
        XCTAssertTrue(kai.exists)
        XCTAssertLessThan(kai.frame.minY, zoe.frame.minY)
        app.buttons["Name"].tap()
        XCTAssertLessThan(zoe.frame.minY, kai.frame.minY)
    }

    @MainActor
    private func snapshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testButtonsWithDefaultPowFeedback() {
        let app = catalogue("Buttons & status", effects: true)
        XCTAssertFalse(app.buttons["Disabled"].isEnabled)
        app.buttons["Primary"].tap()
        XCTAssertEqual(app.staticTexts["catalogue-action"].label, "Primary selected")
        app.buttons["Ghost"].tap()
        XCTAssertEqual(app.staticTexts["catalogue-action"].label, "Ghost selected")
        reveal(app.buttons["Show success"], in: app)
        app.buttons["Show success"].tap()
        XCTAssertEqual(app.staticTexts["success-feedback"].label, "Saved · 1")
        app.buttons["Show success"].tap()
        XCTAssertEqual(app.staticTexts["success-feedback"].label, "Saved · 2")
        reveal(app.buttons["Show error"], in: app)
        app.buttons["Show error"].tap()
    }
}
