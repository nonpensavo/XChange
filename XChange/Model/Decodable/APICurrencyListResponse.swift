//
//  APICurrencyListResponse.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/28/21.
//
///Response decodable for currency list requests, variable names must match with API response for valid decoding.
struct APICurrencyListResponse : Decodable {
	let success: Bool
	var error: APIError?
	let terms: String?
	let privacy: String?
	var currencies: [String : String]?
}
