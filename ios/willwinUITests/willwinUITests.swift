//
//  willwinUITests.swift
//  willwinUITests
//
//  Created by Володимир Борисенко on 27.05.2026.
//

import XCTest

final class willwinUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testEditingReplacingDeletingAndRelaunching() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        addUIInterruptionMonitor(withDescription: "Notification permission") { alert in
            for title in ["Allow", "Дозволити"] where alert.buttons[title].exists {
                alert.buttons[title].tap()
                return true
            }
            return false
        }
        app.launch()
        let english = app.buttons.containing(.staticText, identifier: "English").firstMatch
        if english.exists { english.tap() }
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for title in ["Allow", "Дозволити"] {
            if springboard.alerts.buttons[title].exists {
                springboard.alerts.buttons[title].tap()
                break
            }
        }
        // На повторному запуску можна залишитися в попередньому тренуванні.
        while !app.buttons["addWeek"].exists && app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
        }
        XCTAssertTrue(app.buttons["addWeek"].waitForExistence(timeout: 5))
        app.buttons["addWeek"].tap()
        let weeks = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'weekRow-'"))
        weeks.element(boundBy: weeks.count - 1).tap()
        app.buttons["addWorkout"].tap()
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'workoutRow-' ")).firstMatch.tap()
        app.buttons["addExercise"].tap()
        let library = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'libraryExercise-'"))
        XCTAssertTrue(library.firstMatch.waitForExistence(timeout: 5))
        library.firstMatch.tap()
        XCTAssertTrue(library.firstMatch.waitForNonExistence(timeout: 5))
        let weights = app.textFields.matching(NSPredicate(format: "identifier BEGINSWITH 'setWeight-'"))
        let reps = app.textFields.matching(NSPredicate(format: "identifier BEGINSWITH 'setReps-'"))
        XCTAssertTrue(weights.firstMatch.waitForExistence(timeout: 5))
        let weightID = weights.firstMatch.identifier
        focus(weights.firstMatch, in: app)
        weights.firstMatch.typeText("12.5")
        let done = app.buttons["keyboardDone"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        done.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 3))
        XCTAssertEqual(weights.firstMatch.value as? String, "12.5")
        focus(reps.firstMatch, in: app)
        reps.firstMatch.typeText("8")
        done.tap()

        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'addSet-' ")).firstMatch.tap()
        XCTAssertEqual(weights.count, 2)
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'exerciseMenu-' ")).firstMatch.tap()
        app.buttons["Replace exercise"].tap()
        XCTAssertTrue(library.firstMatch.waitForExistence(timeout: 5))
        let replacementName = library.element(boundBy: 1).label
        library.element(boundBy: 1).tap()
        XCTAssertTrue(library.firstMatch.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[replacementName].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields[weightID].waitForExistence(timeout: 5))
        XCTAssertEqual(weights.count, 2)
        XCTAssertEqual(app.textFields[weightID].value as? String, "12.5")

        let deletion = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'deleteSet-'"))
        let readyToDelete = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: deletion.element(boundBy: 1))
        XCTAssertEqual(XCTWaiter.wait(for: [readyToDelete], timeout: 5), .completed)
        deletion.element(boundBy: 1).tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5))
        app.alerts.buttons["Cancel"].tap()
        XCTAssertEqual(weights.count, 2)
        deletion.element(boundBy: 1).tap()
        app.alerts.buttons["Delete"].tap()
        XCTAssertEqual(weights.count, 1)

        // Згорнути одразу після редагування, повернутися та повністю перезапустити.
        focus(reps.firstMatch, in: app)
        reps.firstMatch.typeText("1")
        let expectedReps = reps.firstMatch.value as? String
        XCTAssertNotEqual(expectedReps, "8")
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.textFields[weightID].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.textFields[weightID].waitForExistence(timeout: 10))
        XCTAssertEqual(app.textFields[weightID].value as? String, "12.5")
        XCTAssertEqual(reps.firstMatch.value as? String, expectedReps)
        XCTAssertEqual(weights.count, 1)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    private func focus(_ field: XCUIElement, in app: XCUIApplication) {
        field.tap()
        // При приховуванні клавіатури ScrollView ще може змінювати розкладку.
        if !app.keyboards.firstMatch.waitForExistence(timeout: 2) { field.tap() }
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
