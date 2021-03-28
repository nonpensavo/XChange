//
//  CurrencyList.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import RealmSwift

class CurrencyList : Object {
	//As we need to retain only one list of currencies, its primary key is 0 and wont be changed.
	//Therefore by requesting or writing it to database, it will always update the existing object without populating new objects
	@objc dynamic var primaryKey : Int = 0
	@objc dynamic var retrievedTimestamp : Int
	let currencies = List<Currency>()
	
	override static func primaryKey() -> String? {
		return "primaryKey"
	}
	
	override init(){
		retrievedTimestamp = Date.currentTimestamp
	}
}

class Currency : Object {
	@objc dynamic var code: String = ""
	@objc dynamic var desc: String = ""
	//var parentCategory = LinkingObjects(fromType: CurrencyList.self, property: "currencies") // We dont really need to track changes etc, because there would be none

	convenience init (_ code: String, _ description: String){
		self.init()
		self.code = code
		self.desc = description
	}
}

class SelectedCurrency : Object {
	//Same as list, we need only single value, therefore keeping it at primary key 0. We could use UserDefaults for this purpose, but lets not spread our small data over several storages
	@objc dynamic var primaryKey : Int = 0
	@objc dynamic var code: String = ""
	
	override static func primaryKey() -> String? {
		return "primaryKey"
	}
	
	convenience init (_ code: String){
		self.init()
		self.code = code
	}
}
