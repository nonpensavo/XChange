//
//  APIError.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/28/21.
//

import Foundation

///Response decodable for error objects, variable names must match with API response for valid decoding.
struct APIError : Decodable {
	var code: Int
	var info: String?
}
