//
//  Film_LocationsUITests.swift
//  Film LocationsUITests
//
//  Created by Jessica Thrasher on 3/20/18.
//  Copyright © 2018 Codepath Spring17. All rights reserved.
//

import XCTest

class Film_LocationsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        snapshot("01LoginScreen")
        
        let app = XCUIApplication()
        app.buttons["Continue without login"].tap()
        

        
    }
    
}
