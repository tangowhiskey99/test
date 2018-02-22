//
//  FuelTests.swift
//  FuelTests
//
//  Created by Brad Leege on 11/21/17.
//  Copyright © 2017 Brad Leege. All rights reserved.
//

import XCTest
@testable import Fuel

class FuelTests: XCTestCase {
    
    private var mockOverViewContractView: MockOverviewContractView?
    private var mockAddStopContractView: MockAddStopContractView?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockOverViewContractView = MockOverviewContractView()
        mockAddStopContractView = MockAddStopContractView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockOverViewContractView = nil
        mockAddStopContractView = nil
        
        super.tearDown()
    }
    
    func testOverviewPresenterLoadStops() {
        let presenter = OverviewPresenter()
        presenter.onAttach(view: mockOverViewContractView!)
        presenter.onDetach()
        XCTAssertTrue(mockOverViewContractView?.displayStopsCalled == true)
    }
    
    func testOverviewPresenterShowStopSelection() {
        let presenter = OverviewPresenter()
        presenter.onAttach(view: mockOverViewContractView!)
        presenter.handleStopSelection(index: 1)
        presenter.onDetach()
        XCTAssertTrue(mockOverViewContractView?.displayStopOnMapCalled == true)
        XCTAssertTrue(mockOverViewContractView?.displayStopDataViewCalled == true)
    }
    
    func testOverviewPresenterAddStopFABTap() {
        let presenter = OverviewPresenter()
        presenter.onAttach(view: mockOverViewContractView!)
        presenter.handleAddStopFABTap()
        presenter.onDetach()
        XCTAssertTrue(mockOverViewContractView?.displayAddStopViewControllerCalled == true)
    }
    
    func testAddStopPresenterInitialDataPopulation() {
        let presenter = AddStopPresenter()
        presenter.onAttach(view: mockAddStopContractView!)
        presenter.onDetach()
        XCTAssertTrue(mockAddStopContractView?.initialDataPopulationCalled == true)
    }

    func testAddStopPresenterDismiss(){
        let presenter = AddStopPresenter()
        presenter.onAttach(view: mockAddStopContractView!)
        presenter.handleCancelTap()
        presenter.onDetach()
        XCTAssertTrue(mockAddStopContractView?.dismissCalled == true)
    }

    func testAddStopPresenterSave(){
        let presenter = AddStopPresenter()
        presenter.onAttach(view: mockAddStopContractView!)
        presenter.handleSaveTap()
        presenter.onDetach()
        XCTAssertTrue(mockAddStopContractView?.validateFormCalled == true)
        XCTAssertTrue(mockAddStopContractView?.gallonsDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.latitudeDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.longitudeDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.octaneDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.odometerDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.priceDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.ppgDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.stopDateDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.tripOdometerDataCalled == true)
        XCTAssertTrue(mockAddStopContractView?.dismissCalled == true)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
