//
//  PickerTextField.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import UIKit

@IBDesignable
/// Custom label for picker view that meets design model requirements
class PickerLabel: UIView {
	var onPressed: (() -> Void)?
	
	@IBInspectable
	var text: String = "" {
		didSet {
			label.text = text
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var foreground : UIColor = UIColor.white {
		didSet {
			label.textColor = foreground
			imageView.tintColor = foreground
			setNeedsLayout()
		}
	}
	
	lazy var label : UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .clear
		label.text = self.text
		label.lineBreakMode = .byClipping
		label.textAlignment = .right
		label.font = UIFont(name: "Avenir Next", size: 27.0)
		return label
	}()
	
	lazy var imageView : UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.backgroundColor = .clear
		imageView.tintColor = .white
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(systemName: "chevron.down") //image is from SF Symbols
		return imageView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeViews()
		
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initializeViews()
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		initializeViews()
	}
}



extension PickerLabel {
	private func initializeViews() {
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewDidTap(_:)))
		self.isUserInteractionEnabled = true
		self.addGestureRecognizer(gestureRecognizer)
		self.backgroundColor = UIColor.clear
		
		addSubview(label)
		addSubview(imageView)
		initializeConstraints()
	}
	
	@objc func viewDidTap(_ sender: UITapGestureRecognizer? = nil){
		onPressed?()
	}
	
	fileprivate func initializeConstraints(){
		//self.translatesAutoresizingMaskIntoConstraints = false
		imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
		imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		
		label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
		label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	
}
