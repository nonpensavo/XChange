//
//  GradientUIView.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import UIKit

@IBDesignable
/// UIView with gradient background option
class GradientUIView: UIView {
	
	@IBInspectable
	var startColor: UIColor = .white {
		didSet {
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var endColor: UIColor = .white {
		didSet {
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var startPointX: CGFloat = 0.5 {
		didSet {
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var startPointY: CGFloat = 0 {
		didSet {
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var endPointX: CGFloat = 0.5 {
		didSet {
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var endPointY: CGFloat = 1 {
		didSet {
			setNeedsLayout()
		}
	}
	
	override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}
	
	override func layoutSubviews() {
		let gradientLayer = layer as! CAGradientLayer
		gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
		gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
		gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
	}
}
