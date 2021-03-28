//
//  CashValueTextField.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import UIKit

@IBDesignable
/// Custom UI view that serves as text field, for design purposes.
class CashValueTextField: UIView {
	
	//delegate for clicking on view to show picker view
	var onValueChanged: ((Int) -> Void)?
	
	private var lineHeightConstraint :  NSLayoutConstraint?
	
	@IBInspectable
	var value: Int = 1 {
		didSet {
			textField.text = String(value)
			
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var maxLength: Int = 8 {
		
		//If value after multiplaction exceeds double limits, results would be inaccurate
		didSet {
			textField.text = String(textField.text?.prefix(maxLength) ?? "")
		}
	}
	
	@IBInspectable
	var lineHeight: CGFloat = 2 {
		didSet {
			lineHeightConstraint?.constant = lineHeight
			lineView.layer.cornerRadius = lineHeight/2
			setNeedsLayout()
		}
	}
	
	@IBInspectable
	var foreground : UIColor = UIColor(named: "colorMainForeground") ?? UIColor.white {
		didSet {
			textField.textColor = foreground
			lineView.backgroundColor = foreground
			setNeedsLayout()
		}
	}
	
	lazy var textField : UITextField = {
		let textField = UITextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.backgroundColor = .clear
		textField.tintColor = .clear
		textField.textColor = foreground
		textField.text = String(value)
		textField.adjustsFontSizeToFitWidth = true
		textField.textAlignment = .right
		textField.keyboardType = .numberPad
		textField.contentVerticalAlignment = .bottom
		textField.clearsOnBeginEditing = true
		textField.clearsOnInsertion = false
		textField.font = UIFont(name: "Avenir Next", size: 40.0)
		textField.delegate = self
		return textField
	}()
	
	lazy var lineView : UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		lineHeightConstraint = view.heightAnchor.constraint(equalToConstant: lineHeight)
		
		view.layer.cornerRadius = lineHeight/2
		view.backgroundColor = foreground
		return view
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

extension CashValueTextField {
	private func initializeViews() {
		self.backgroundColor = UIColor.clear
		
		addSubview(textField)
		addSubview(lineView)
		initializeConstraints()
	}
	
	fileprivate func initializeConstraints(){
		//self.translatesAutoresizingMaskIntoConstraints = false
		lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		lineHeightConstraint?.isActive = true
		
		textField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		textField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		textField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		textField.bottomAnchor.constraint(equalTo: lineView.topAnchor).isActive = true
		
	}
}

extension CashValueTextField : UITextFieldDelegate {
	//Limiting textfield to maxCount and digits (in case of paste, cause keyboard is numpad), and first element as 0
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let textFieldText = textField.text, let rangeOfTextToReplace = Range(range, in: textFieldText) else {
			return false
		}
		let substringToReplace = textFieldText[rangeOfTextToReplace]
		let count = textFieldText.count - substringToReplace.count + string.count
		
		let allowedCharacters = CharacterSet.decimalDigits
		let characterSet = CharacterSet(charactersIn: string)
		let isFirstZero = textField.text?.count == 0 && string.starts(with: "0")
		
		return allowedCharacters.isSuperset(of: characterSet) && !isFirstZero  && count <= maxLength
		
	}
	func textFieldDidChangeSelection(_ textField: UITextField) {
		// Call delegate only if textfield value is valid number
		if let value = textField.text, value.isDecimalNumber {
			let numericValue = Int(value) ?? 1
			onValueChanged?(numericValue)
		} else {
			//if empty or anything else, show default 1:1 exchange rate
			onValueChanged?(1)
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		//That would give it nice UX addition of not being empty
		if textField.text == "" || textField.text == nil {
			textField.placeholder = "1"
		}
	}
}
