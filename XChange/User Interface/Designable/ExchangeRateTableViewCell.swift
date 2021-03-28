//
//  ExchangeRateTableViewCell.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import UIKit

class ExchangeRateTableViewCell: UITableViewCell {
	static let identifier : String = "exchangeRateTableViewCell"
	
	var titleValue: String? { titleLabel.text }
	var descriptionValue: String? { descriptionLabel.text }
	
	lazy var lineView : UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 1).isActive = true
		view.backgroundColor =  (UIColor(named: "colorMainForeground") ?? UIColor.white)?.withAlphaComponent(0.1)
		return view
	}()
	
	private lazy var titleLabel : UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont(name: "Avenir Next", size: 16)
		label.numberOfLines = 1
		label.isUserInteractionEnabled = false
		label.textColor = UIColor(named: "colorMainForeground")
		label.lineBreakMode = .byWordWrapping
		label.textAlignment = .left
		label.baselineAdjustment = .alignCenters
		return label
	}()
	
	private lazy var descriptionLabel : UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont(name: "Avenir Next", size: 14)
		label.numberOfLines = 1
		label.isUserInteractionEnabled = false
		label.textColor = UIColor(named: "colorMainForegroundSecondary")
		label.lineBreakMode = .byWordWrapping
		label.textAlignment = .left
		label.baselineAdjustment = .alignCenters
		return label
	}()
	
	private lazy var exchangeRateLabel : UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont(name: "Avenir Next", size: 14)
		label.numberOfLines = 1
		label.isUserInteractionEnabled = false
		label.adjustsFontSizeToFitWidth = true
		label.textColor = UIColor(named: "colorMainForeground")
		label.lineBreakMode = .byWordWrapping
		label.textAlignment = .right
		label.baselineAdjustment = .alignCenters
		return label
	}()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		initializeViews()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initializeViews()
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initializeViews()
	}
	
	fileprivate func initializeViews(){
		backgroundColor = .clear
		
		addSubview(titleLabel)
		addSubview(descriptionLabel)
		addSubview(exchangeRateLabel)
		addSubview(lineView)
		initializeConstraints()
	}
	
	fileprivate func initializeConstraints(){
		descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
		descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 3).isActive = true
		
		titleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor).isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
		titleLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
		
		exchangeRateLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
		exchangeRateLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10).isActive = true
		exchangeRateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		exchangeRateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
		
		lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3).isActive = true
		lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
		lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
	}
	
	func setValues(for currency: Currency, to result: Double?){
		
		titleLabel.text = currency.code
		//lets try to localize the description instead
		let localizedDescription = Localizable.Currency(rawValue: currency.code)?.localized
		//this way we can actually safely remove english localization for error code, optionally of course
		let localizedDesctiptionCount = localizedDescription?.count ?? 0
		
		descriptionLabel.text = localizedDesctiptionCount > 0 ? localizedDescription! : currency.desc
		
		if let finalRate = result, finalRate > 0 {
			let numberFormatter = NumberFormatter()
			numberFormatter.numberStyle = .decimal
			//High fraction due to most currencies having very low conversion rate, there is a high risk of showing 0 for most 1 to 1 rates.
			numberFormatter.maximumFractionDigits = 6
			
			let text = numberFormatter.string(for: finalRate)
			
			exchangeRateLabel.text = text ?? (Double(round(100000*finalRate)/100000)).printVersion
		} else {
			exchangeRateLabel.text = "---"
		}
	}
}
