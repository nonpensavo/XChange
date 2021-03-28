//
//  AppDelegate.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		initializeRealm()
		return true
	}

	///Realm needs to be attempted to initialize early as possible, from doc: Like any disk I/O operation, creating a Realm instance could sometimes fail if resources are constrained. In practice, this can only happen the first time a Realm instance is created on a given thread 
	private func initializeRealm(){
		do {
			try RealmStorage.firstCall()
		} catch {
			print("First realm initialization failed with \(error)")
		}
	}
}

