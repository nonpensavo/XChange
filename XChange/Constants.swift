//
//  Constants.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/28/21.
//

struct Constants {
	/// Currency code used for calculation of all others due to limited free tier access
	static var FreeCurrencyCode : String = "USD"
	/// Currency code that will be shown in the very first app launch when there is no persistent storage value available
	static var InitialCurrencyCode : String = "JPY"
	/// API key for the 'Currency Layer' web service
	static var CurrencyAPIKey : String = "deabad728c0c6fbc9622305e811009b3"
}
