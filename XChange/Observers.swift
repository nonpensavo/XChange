//
//  Observers.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/28/21.
//

import RxSwift

struct Observers {
	/// BehaviorSubject sequence for latest OR default selected currency, it will always return its latest value upon subscription.
	static var selectedCurrencySubject = BehaviorSubject<String>(value: Constants.InitialCurrencyCode)
	/// PublishSubject observer sequence for exchange rate subscriptions (RxSwift)
	static var exchangeRateSubject = PublishSubject<ExchangeRate?>()
	/// PublishSubject observer sequence for USD exchange rate subscriptions, only for free API (RxSwift)
	static var freeExchangeRateSubject = PublishSubject<ExchangeRate?>()
	/// PublishSubject observer sequence for currency list subscriptions (RxSwift)
	static var currencyListSubject = PublishSubject<CurrencyList?>()
	/// PublishSubject observer for subscribers for possible errors to pass
	static var dataRetrieveError = PublishSubject<APIError>()
	
	static func disposeAllObservers(){
		currencyListSubject.dispose()
		dataRetrieveError.dispose()
		exchangeRateSubject.dispose()
		freeExchangeRateSubject.dispose()
		selectedCurrencySubject.dispose()
	}
}
