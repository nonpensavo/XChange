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
	/// API key for the 'Currency Layer' web service, register and receive your key at currencylayer.com
	static var CurrencyAPIKey : String = "PUT_YOUR_API_KEY"
}
