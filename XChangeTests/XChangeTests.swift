//
//  XChangeTests.swift
//  XChangeTests
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import XCTest
@testable import XChange

class XChangeTests: XCTestCase {
	var initialCurrencyCode : String = Constants.InitialCurrencyCode
	let initialApiKey = Constants.CurrencyAPIKey
	
    override func setUpWithError() throws {
		initialCurrencyCode = try Observers.selectedCurrencySubject.value()
    }

    override func tearDownWithError() throws {
		RealmStorage.instance.saveSelectedCurrency(currencyCode: initialCurrencyCode)
		Constants.CurrencyAPIKey = initialApiKey
    }

	//If Realm() fails, it is documented to be only the first call for speciific reasons. Therefore we call it in appDelegate
	func testRealmInitialInitialization() {
		XCTAssertNoThrow(try RealmStorage.firstCall())
	}
	
    func testBehaviorSubscription() {
		let exp = expectation(description: "Subscription disposal, timeout 1")
		Observers.selectedCurrencySubject.take(1).subscribe(onNext: { value in
														XCTAssertGreaterThan(value.count, 0, "Has to always have some value")},
													onError: { error in
														XCTFail("Behavior Subscription error is not expected")},
													onDisposed: {
														exp.fulfill()
													}).disposed(by: RealmStorage.instance.disposeBag)
		
		waitForExpectations(timeout: 1, handler: nil)
    }
	
	func testRealmReadWrite(){
		let testCurrencyCode = "XCT"
		
		let exp = expectation(description: "Subscription disposal, timeout 1")
		Observers.selectedCurrencySubject.takeLast(1).subscribe(onNext: { value in
																	XCTAssertEqual(value, testCurrencyCode, "Has to be equal to written value")},
																onError: { error in
																	XCTFail("Behavior Subscription error is not expected")},
																onDisposed: {
																	exp.fulfill()
																}).disposed(by: RealmStorage.instance.disposeBag)
		
		RealmStorage.instance.saveSelectedCurrency(currencyCode: testCurrencyCode)
		RealmStorage.instance.readLatestSelectedCurrency()
		Observers.selectedCurrencySubject.onCompleted()
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testKeysAndConstants() {
		XCTAssertGreaterThan(Constants.CurrencyAPIKey.count, 0, "Make sure API_KEY has been set")
		XCTAssertEqual(Constants.InitialCurrencyCode.count, 3, "Currency Codes have to be exactly 3 letters long")
		XCTAssertEqual(Constants.FreeCurrencyCode.count, 3, "Currency Codes have to be exactly 3 letters long")
	}

    func testDateExtension() throws {
		let sixHoursAgo = Date.sixHoursAgoTimestamp
		let halfHoursAgo = Date.halfHourAgoTimestamp
		
		//Called last
		let date = Date()
		
		let timestamp = Int(date.timeIntervalSince1970)
		let sixHoursAgoManual = timestamp - 60*60*6
		let halfHourAgoManual = timestamp - 60*30
		XCTAssertGreaterThanOrEqual(sixHoursAgoManual, sixHoursAgo)
		XCTAssertLessThanOrEqual(sixHoursAgoManual - sixHoursAgo, 10)
		
		XCTAssertGreaterThanOrEqual(halfHourAgoManual, halfHoursAgo)
		XCTAssertLessThanOrEqual(halfHourAgoManual - halfHoursAgo, 10)
		
    }
	
	func testStringExtension(){
		let notNumeric = "Hello World"
		XCTAssertFalse(notNumeric.isDecimalNumber)
		
		let numeric = "293193"
		XCTAssertTrue(numeric.isDecimalNumber)
		
		let floatNumber = "123123.1123"
		XCTAssertFalse(floatNumber.isDecimalNumber)
		
		let wrongNumeric = "12312312,2312"
		XCTAssertFalse(wrongNumeric.isDecimalNumber)
		
		let mixedNumbers = "231lll12"
		XCTAssertFalse(mixedNumbers.isDecimalNumber)
	}
	
	func testCurrencyAPICurrencyList(){
		
		let exp1 = expectation(description: "Fetch currencies from server, timeout 2")
		CurrencyAPI.instance.fetchAvailableCurrencies { response in
			XCTAssertNotNil(response)
			XCTAssertTrue(response!.success)
			XCTAssertGreaterThan(response?.currencies?.count ?? 0, 0, "Currencies were not fetched properly")
			XCTAssertNil(response?.error)
			exp1.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)
		Constants.CurrencyAPIKey = initialApiKey + "MODIFIED"
		
		let exp2 = expectation(description: "Fetch currencies from server with Wrong API Key, timeout 2")
		CurrencyAPI.instance.fetchAvailableCurrencies { response in
			XCTAssertNotNil(response)
			XCTAssertFalse(response!.success)
			XCTAssertNil(response?.currencies, "Currencies were misinitialied")
			XCTAssertNotNil(response?.error)
			XCTAssertGreaterThan(response!.error!.code, 0)
			exp2.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)
		
	}
	
	func testCurrencyAPIExchangeRate() {
		let validCurrency = "USD"
		let exp1 = expectation(description: "Fetch exchange rate from API, timeout 2")
		CurrencyAPI.instance.fetchExchangeRate(for: validCurrency) { (response) in
			XCTAssertNotNil(response)
			XCTAssertTrue(response!.success)
			XCTAssertGreaterThan(response?.quotes?.count ?? 0, 100, "Currencies were not fetched properly")
			XCTAssertNil(response?.error)
			exp1.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)
		
		let invalidCurrency = "JPY" //API tier restriction
		let exp2 = expectation(description: "Free Tier subscription cannot set source other than USD, timeout 2")
		CurrencyAPI.instance.fetchExchangeRate(for: invalidCurrency) { (response) in
			XCTAssertNotNil(response)
			XCTAssertFalse(response!.success)
			XCTAssertNil(response?.quotes, "Quote were initializaed inproperly")
			XCTAssertNotNil(response?.error)
			exp2.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)
		
	}
	
	func testTableViewCell(){
		let cell = ExchangeRateTableViewCell()
		cell.setValues(for: Currency("JPY", "Japanese Yen"), to: nil)
		XCTAssertEqual(cell.titleValue, "JPY")
		XCTAssertGreaterThan(cell.descriptionValue?.count ?? 0, 0, "Description should not be empty")
	}
	
	func testLocalization(){
		
	}
}
