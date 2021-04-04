//
//  Extenstions.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import UIKit

extension Date {
	/// Timestamp in seconds for current moment
	static var currentTimestamp : Int {
		get {
			return Int(Date().timeIntervalSince1970)
		}
	}
	
	/// Timestamp in seconds for time equivalent of 30 minutes earlier than Date().now
	static var halfHourAgoTimestamp: Int {
		get {
			return Int(Date(timeIntervalSinceNow: -1800).timeIntervalSince1970)
		}
	}
	
	/// Timestamp in seconds for time equivalent of 6 hours earlier than Date().now
	static var sixHoursAgoTimestamp: Int {
		get {
			//just using anothr method for fun, although force unwrapping, it is guaranteed that -6 hours will not cause any issue cause our input dates are solid
			return Int(Calendar.current.date(byAdding: .hour, value: -6, to: Date())!.timeIntervalSince1970)
		}
	}
}


extension String {
	/// True if string completely consists of digits, false - otherwise
	public var isDecimalNumber: Bool {
		return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
	}
}

extension Double {
	/// Printable version with less rate to show scientific representation
	var printVersion: String {
		let check = floor(self) == self
		if check {
			return String(self.rounded())
		} else {
			return String(self)
		}
	}
}

extension UITableView {
	
	/// Shows loading indicator in the middle of the table view with slight dimming. Cancel with same method
	func setLoading(_ loading: Bool) {
		let tag = 808404
		if loading {
			let parentHeight = self.bounds.size.height
			let parentWidth = self.bounds.size.width
			
			self.alpha = 0.4
			self.isScrollEnabled = false
			let indicator = UIActivityIndicatorView()
			indicator.center = CGPoint(x: parentWidth/2.0, y: parentHeight/2.0-50)
			indicator.style = .large
			indicator.tag = tag
			self.addSubview(indicator)
			indicator.startAnimating()
		} else {
			self.alpha = 1.0
			self.isScrollEnabled = true
			if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
				indicator.stopAnimating()
				indicator.removeFromSuperview()
			}
		}
		setNeedsLayout() 
	}
}

extension UIViewController {
	func showErrorPopup(message : String, font: UIFont? = UIFont(name: "Avenir Next", size: 12), duration: TimeInterval = 4.0, height: CGFloat = 50.0) {
		
		let label = UILabel(frame: CGRect(x: 25, y: self.view.frame.size.height-50-height, width: self.view.frame.size.width-50, height: height))
		label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		label.textColor = UIColor.white
		label.font = font
		label.textAlignment = .center;
		label.text = message
		label.alpha = 1.0
		label.layer.cornerRadius = 14;
		label.clipsToBounds = true
		self.view.addSubview(label)
		UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
			label.alpha = 0.0
		}, completion: {(isCompleted) in
			label.removeFromSuperview()
		})
	}
}

extension Array {
	func get(at index: Int) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
