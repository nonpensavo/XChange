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
	
	private lazy var selectionView : RoundedUIView = {
		let view = RoundedUIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.cornerRadius = 12
		view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.08)
		view.alpha = 1.0
		
		return view
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
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
			self?.selectionView.alpha = selected ? 1.0 : 0.0
		}, completion: { [weak self] (isCompleted) in
			if selected {
				self?.setSelected(false, animated: animated)
			}
		})
		
		
		
	}

	fileprivate func initializeViews(){
		backgroundColor = .clear
		selectionStyle = .none
		
		addSubview(titleLabel)
		addSubview(descriptionLabel)
		addSubview(exchangeRateLabel)
		addSubview(lineView)
		addSubview(selectionView)
		
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
		exchangeRateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10).isActive = true
		exchangeRateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		exchangeRateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
		
		lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3).isActive = true
		lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
		lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		
		selectionView.topAnchor.constraint(equalTo: exchangeRateLabel.topAnchor, constant: -3).isActive = true
		selectionView.bottomAnchor.constraint(equalTo: exchangeRateLabel.bottomAnchor, constant: 2).isActive = true
		selectionView.leadingAnchor.constraint(equalTo: exchangeRateLabel.leadingAnchor, constant: -9).isActive = true
		selectionView.trailingAnchor.constraint(equalTo: exchangeRateLabel.trailingAnchor, constant: 6).isActive = true
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
