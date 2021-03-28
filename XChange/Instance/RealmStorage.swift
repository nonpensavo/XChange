//
//  CurrencyStorage.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import RealmSwift
import RxSwift

class RealmStorage {
	static func firstCall() throws { _ = try Realm() }
	
	// MARK: - Singleton
	/// Singleton model for all realm persistent storage reads and writes.
	private init(){}
	static var instance = RealmStorage()
	
	// MARK: - Variables and Observers
	///We are creating single realm object for this singleton class, therefore need to make sure to call all access functions from same thread.
	///Configuration set to disable migration for development purposes only.
	var realm : Realm? = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true))
	var disposeBag = DisposeBag()
	
	// MARK: - Functions
	/// Realm initial reading and writing operations, required to call in proper order for apps functionality
	func initialize(){
		readLatestSelectedCurrency()
		subscribeToSelectedCurrency()
	}
	
	/// Deletes all realm persistent data from device/simulator. For development purposes only.
	func deleteAllData(){
		do {
			try realm?.write {
				realm?.deleteAll()
				print("Deleting all")
			}
		} catch {
			print ("Realm error while deleting currency list \(error)")
		}
	}
	
}

// MARK: - Currency List Extension
///Extension with functions responsible for operations with Currency List (for user to select from)
extension RealmStorage {
	/// Method to read the latest selected currency. If none, use initial value of the BehaviourSubject observer.
	func readLatestSelectedCurrency(){
		if let lastSelectedCurrency = realm?.objects(SelectedCurrency.self).first {
			if lastSelectedCurrency.code != (try? Observers.selectedCurrencySubject.value()) {
				Observers.selectedCurrencySubject.onNext(lastSelectedCurrency.code)
			}
		}
	}
	
	private func subscribeToSelectedCurrency(){
		/// Although subscription will always trigger for the first time, it wont write it unless value is different
		Observers.selectedCurrencySubject.subscribe(onNext: { [weak self] currencyCode in //Better keep all references as weak
			self?.saveSelectedCurrency(currencyCode: currencyCode)
		}).disposed(by: disposeBag)
	}
	
	/// Saves the given currencyCode to persistent storage
	/// - Parameter currencyCode: valid currency code that needs to be saved, 3 letters long.
	func saveSelectedCurrency(currencyCode: String){
		do {
			try realm?.write {
				realm?.add(SelectedCurrency(currencyCode), update: .modified)
			}
		} catch {
			print ("Realm error while saving currency list: \(error)")
		}
	}
	
	/// To call on app startup, and if need, refresh the currencies list. It reads realm db to get latest saved currency list.
	/// Currency list is not that important to update often, but it is required for this app architecture to build picker list and table view list, therefore set to 6 hours. Can be changed to any expiraton date easily
	/// Also it is possible to store data persistently without any timestamp, then in case of API changes, like deleting or adding currency types to their API, app reinstall would be required to refresh.
	func requestCurrencyList() {
		if let existingList = realm?.objects(CurrencyList.self).first {
			if existingList.retrievedTimestamp <= Date.sixHoursAgoTimestamp {
				print("Currency List is expired \(Date.halfHourAgoTimestamp - existingList.retrievedTimestamp) seconds ago.")
				//deleteCurrencyList(existingList)
			} else {
				print("Currency List was fetched \(Date.currentTimestamp - existingList.retrievedTimestamp) seconds ago, using same list.")
				Observers.currencyListSubject.onNext(existingList)
				return
			}
		}
		CurrencyAPI.instance.fetchAvailableCurrencies(){ response in 
			RealmStorage.instance.processCurrencyListResponse(response)
		}
	}
	
	/// Function to save the latest retrieved currency list into realm database, to be called at most 1 time for application run. If app would run again within 6 hours from this moment, it will use this saved currency model.
	/// - Parameter currencyList: currency list object to save into persistent storage
	func saveCurrencyList(_ currencyList: CurrencyList){
		do {
			try realm?.write {
				realm?.add(currencyList, update: .modified)
			}
		} catch {
			print ("Realm error while saving currency list: \(error)")
		}
		
		//For development purposes, I made it go full loop to call onNext after saving, not right after fetching to make sure it doesnt cause recursion
		//readCurrencyList()
	}
	
	/// Deletes selected currencyList from realm. For development purposes only. We retain only single copy via primary keys therefore there is no practical need to delete it.
	/// - Parameter currencyList: CurrencyList object that needs to be deleted from persistent storage
	func deleteCurrencyList(_ currencyList: CurrencyList){
		do {
			try realm?.write {
				realm?.delete(currencyList)
			}
		} catch {
			print ("Realm error while deleting currency list: \(error)")
		}
	}
	
	/// Function deals with fetch response and continues into appropriate logical outcome, either its successful or not
	/// - Parameter response: Optional APICurrencyListResponse object that needs to be addressed depend on its content
	func processCurrencyListResponse(_ response: APICurrencyListResponse?){
		if let apiCurrencies = response {
			if apiCurrencies.success {
				//This is unlikely to fail in case of success = true, unless api changes, therefore making sure
				if let fetchedCurrencies = apiCurrencies.currencies?.map({Currency($0.key, $0.value)}){
					//this sets timestamp and empty list
					let currencyList = CurrencyList()
					
					currencyList.currencies.append(objectsIn: fetchedCurrencies.sorted(by: { return $0.code < $1.code }))
					//Save the list for local persistent storage
					saveCurrencyList(currencyList)
					//Send the item to publisher
					Observers.currencyListSubject.onNext(currencyList)
				}
				
			} else {
				if let error = apiCurrencies.error {
					Observers.dataRetrieveError.onNext(error)
				}
			}
		} else {
			//fatalError("Currency List Response JSON decoding failed. Please, try again later")
			Observers.dataRetrieveError.onNext(APIError(code: 0, info: "Currency List Response JSON decoding failed. Please, try again later"))
		}
	}
	
}

// MARK: - Exchange Rate Extension
extension RealmStorage {
	///It tries to read realm for not expired exchange rate for selected currency, if not, then redirects for API request
	func requestExchangeRate(for currency: String){
		print("\tRequesting currency for \(currency)")
		if let existingExchangeRate = realm?.object(ofType: ExchangeRate.self, forPrimaryKey: currency), existingExchangeRate.retrievedTimestamp > Date.halfHourAgoTimestamp {
			print("Exchange rate for \(existingExchangeRate.source) was fetched \((Date.currentTimestamp - existingExchangeRate.retrievedTimestamp)/60) minutes ago, using it again.")
			Observers.exchangeRateSubject.onNext(existingExchangeRate)
				
			//Additional subscription update if its free tier request
			if existingExchangeRate.source == Constants.FreeCurrencyCode {
				Observers.freeExchangeRateSubject.onNext(existingExchangeRate)
			}
			
		} else {
			
			
			//If its free tier, then request, otherwise generate. With Basic or higher tier, can be removed to safely fetch values from server for all currencies
			switch currency {
				case Constants.FreeCurrencyCode:
					
					//Lets try to use completion block instead of subscription. Cause we are sending output to singleton anyway, it is more readable approach for this project
					CurrencyAPI.instance.fetchExchangeRate(for: currency) { exchangeRateResponse in
						DispatchQueue.main.async {
							RealmStorage.instance.processExchangeRateResponse(exchangeRateResponse)
						}
					}
					//CurrencyAPI.instance.fetchExchangeRate(for: currency)
					break
				
				default:
					generateExchangeRate(for: currency)
			}
			
		}
	}
	
	/// Function to save the exchange rate object into realm local database. Will replace same currency code, if any, or write new row otherwise.
	/// - Parameter exchangeRate: ExchangeRate object to save into persistent storage
	func saveExchangeRate(_ exchangeRate: ExchangeRate){
		do {
			try realm?.write {
				realm?.add(exchangeRate, update: .all)
			}
		} catch {
			print ("Realm error while saving exchange rate: \(error)")
		}
	}
	
	/// Function deals with fetch response and continues into appropriate logical outcome, either its successful or not
	/// - Parameter response: Optional APIExchangeRateResponse object that needs to be addressed depend on its content
	func processExchangeRateResponse(_ response: APIExchangeRateResponse?){
		if let exchangeRateResponse = response {
			if exchangeRateResponse.success {
				//This is unlikely to fail in case of success = true, unless api changes, therefore making sure
				if let source = exchangeRateResponse.source, let timestamp = exchangeRateResponse.timestamp, let quotes = exchangeRateResponse.quotes {
					print("Received \(quotes.capacity) for \(source)")
					let exchangeRate = ExchangeRate(timestamp: timestamp, source: source, quotes: quotes.map{ Quote($0.key, $0.value)})
					saveExchangeRate(exchangeRate)
					Observers.exchangeRateSubject.onNext(exchangeRate)
					
					//If its free tier request, tell subscribers its ready
					if exchangeRate.source == Constants.FreeCurrencyCode {
						Observers.freeExchangeRateSubject.onNext(exchangeRate)
					}
				}
			} else {
				if let error = exchangeRateResponse.error {
					Observers.dataRetrieveError.onNext(error)
				}
			}
		} else {
			
			//fatalError("Exchange Rate Response JSON decoding failed. Please, try again later")
			Observers.dataRetrieveError.onNext(APIError(code: 0, info:  "Exchange Rate Response JSON decoding failed. Please, try again later"))
		}
	}
	
	/// This method generates exchangeRateObjects for any chosen currency code based on FreeCurrencyCode
	/// - Parameter currency: currency rate that is not available via API and needs to be generated
	func generateExchangeRate(for currency: String){
		print("Requested to generate exchange rate for \(currency)")
		guard currency != Constants.FreeCurrencyCode else { return }
		
		Observers.freeExchangeRateSubject.take(1).subscribe(onNext: { [weak self] exchangeRate in
			if let sourceExchangeRate = exchangeRate {
					if let targetRate = sourceExchangeRate.quotes.first(where: { $0.code == sourceExchangeRate.source + currency })?.rate {
						let targetExchangeRate = ExchangeRate()
						//all timestamps going to be same with USD, because its calculated based on USD
						targetExchangeRate.timestamp = sourceExchangeRate.timestamp
						targetExchangeRate.retrievedTimestamp = sourceExchangeRate.retrievedTimestamp
						targetExchangeRate.source = currency
						let targetQuotes = Array(sourceExchangeRate.quotes.map{ Quote(currency + $0.code.suffix(3), $0.rate/targetRate)})
						targetExchangeRate.quotes.append(objectsIn: targetQuotes)
						self?.saveExchangeRate(targetExchangeRate)
						Observers.exchangeRateSubject.onNext(targetExchangeRate)
					}
					else {
						//Invalid code, reset
						Observers.selectedCurrencySubject.onNext(Constants.InitialCurrencyCode)
					}
			}
		}, onDisposed: {
			print("\(currency) subscription disposed")
		}).disposed(by: disposeBag)
		
		
		requestExchangeRate(for: Constants.FreeCurrencyCode)
		
	}
}
