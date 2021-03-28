//
//  ExchangeRate.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import RealmSwift

class ExchangeRate : Object {
	@objc dynamic var timestamp : Int = 0
	@objc dynamic var retrievedTimestamp : Int
	@objc dynamic var source: String = ""
	let quotes = List<Quote>()
	
	override init(){
		retrievedTimestamp = Date.currentTimestamp
	}
	
	//For each currency, it will have own unique value without repeating. So we can store values for all currencies independently, although when USD expires, they will not be used again but generated and rewwritten. If switch to basic or higher api, it will have more feasable benefit. Now its just small convenience.
	override static func primaryKey() -> String? {
		return "source"
	}
	
	convenience init (timestamp: Int, source: String, quotes: [Quote]){
		self.init()
		self.timestamp = timestamp
		self.source = source
		self.quotes.append(objectsIn: quotes)
		
	
	}
}

class Quote : Object {
	@objc dynamic var code: String = ""
	@objc dynamic var rate: Double = 0.0 //Preference over Float type due to further calculations with large numbers that might not fit into Float.
	
	convenience init (_ code: String, _ rate: Double){
		self.init()
		self.code = code
		self.rate = rate
	}
}
