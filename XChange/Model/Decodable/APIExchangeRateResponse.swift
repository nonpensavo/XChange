//
//  APIExchangeRateResponse.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/28/21.
//

///Response decodable for exchange rates,  variable names must match with API response for valid decoding. Can be remodeled using other ways of decoding, eg  SwiftyJSON
struct APIExchangeRateResponse : Decodable {
	let success : Bool
	var error: APIError?
	let terms: String?
	let privacy: String?
	let timestamp: Int?
	let source: String?
	let quotes: [String : Double]?
}
