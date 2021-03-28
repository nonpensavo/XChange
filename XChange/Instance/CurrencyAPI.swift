//
//  CurrencyLayerService.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import Foundation

//For small convenience, keeping them together
struct APIKeyword {
	static let accessKey = "?access_key="
	static let sourceCurrency = "&source="
	static let currencyList = "list"
	static let exchangeRates = "live"
}

class CurrencyAPI {
	private var serviceDomain : String = "http://api.currencylayer.com/"
	private var accessKey : String { APIKeyword.accessKey.appending(Constants.CurrencyAPIKey) }

	static let instance = CurrencyAPI()
	
	/// Fetches available currency list and returns via completion handler. Resulting list might vary with the one from exchange rates
	func fetchAvailableCurrencies(completion: ((APICurrencyListResponse?) -> Void)?){
		print("Fetching currencies from currency API")
		let urlString = serviceDomain + APIKeyword.currencyList + accessKey
		fetch(url: urlString, completion: completion)
	}
	/// Fetches exchange rate for selected currency and returns via completion handler. Although free tier supports only USD request, better have it for theoretically possible functionality scaling in the future
	func fetchExchangeRate(for currency: String, completion: ((APIExchangeRateResponse?) -> Void)?){
		print("Fetching exchange rates for \(currency) from currency API")
		let urlString = serviceDomain + APIKeyword.exchangeRates + accessKey + APIKeyword.sourceCurrency + currency
		//much more neat and reusable now
		fetch(url: urlString, completion: completion)
	}
	
	/// Refactored method that takes url and completion handler for request and performs URLSession request
	private func fetch<T: Decodable>(url urlString: String, completion: ((T?) -> Void)?){
		let safeCompletion: ((T?) -> Void) = { response in
			//Make sure we always execute completion handler on a main thread
			DispatchQueue.main.async {
				completion?(response)
			}
		}
		
		guard let url = URL(string: urlString) else {
			safeCompletion(nil)
			return
		}
		let request = URLRequest(url: url)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let data = data {
				if let exchangeRate = try? JSONDecoder().decode(T.self, from: data) {
					safeCompletion(exchangeRate)
					return
				}
			}
			safeCompletion(nil)
		}.resume()
	}
	
}

/*

//Mark: - RxCocoa Fetch
// This section is completely commented out due to redundancy, but was initally developed for demonstration purposes only.
// In order to use it again, need to add pod 'RxCocoa' in PodFile and update workspace using pod install.



// Data request analogues using rx library. Functionality is equal to the above except using rx extension for URLSession from RxCocoa pod that can return observable for caller to subscribe for response.
// Using rx from rxCocoa library to demonstrate data requests without callbacks or delegates, although it is subscribing to itself and using singletons to store the result, otherwise couldn't make it modular to comment out without changing other files.



import RxSwift
import RxCocoa

//need to add it to main class as they are stored properties
class CurrencyAPI {
	let disposeBag = DisposeBag()
	private init(){
	URLSession.rx.shouldLogRequest = { request in return false }
}

extension CurrencyAPI {
	func fetchAvailableCurrencies(){
		print("Fetching currencies from currency API")
		let urlString = serviceDomain + APIKeyword.currencyList + accessKey
		if let url = URL(string: urlString) {
			let request = URLRequest(url: url)
			let dataObservable = URLSession.shared.rx.data(request: request)
			dataObservable.map { data -> APICurrencyListResponse? in
				return try? JSONDecoder().decode(APICurrencyListResponse.self, from: data)
			}.subscribe(onNext: { response in  //yeah im just subscribing right away here cause commenting full block causes changes in other places
				DispatchQueue.main.async {
					RealmStorage.instance.processCurrencyListResponse(response)
				}
			}).disposed(by: disposeBag)
		}
	}
	
	func fetchExchangeRate(for currency: String){
		let urlString = serviceDomain + APIKeyword.exchangeRates + accessKey + APIKeyword.sourceCurrency + currency
		
		if let url = URL(string: urlString) {
			let request = URLRequest(url: url)
			let dataObservable = URLSession.shared.rx.data(request: request)
			dataObservable.map { data -> APIExchangeRateResponse? in
				return try? JSONDecoder().decode(APIExchangeRateResponse.self, from: data)
			}.subscribe(onNext: { response in
				DispatchQueue.main.async {
					RealmStorage.instance.processExchangeRateResponse(response)
				}
				
			}).disposed(by: disposeBag)
		}
	}
}*/




