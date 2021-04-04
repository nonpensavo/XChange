//
//  ViewController.swift
//  XChange
//
//  Created by Zharas Suleimenov on 3/27/21.
//

import UIKit
import RxSwift

class CurrencyExchangeViewController: UIViewController {
	/// Dispose bag used for disposing subscriptions
	let disposeBag = DisposeBag()
	
	//MARK: - Interface Builder
	@IBOutlet weak var pickerLabel: PickerLabel!
	@IBOutlet weak var pickerTextField: CashValueTextField!
	@IBOutlet weak var pickerViewContainer: RoundedUIView!
	@IBOutlet weak var pickerView: UIPickerView!
	@IBOutlet weak var tableView: UITableView!
	
	//MARK: - VC Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		initializeViews()
		initializeData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		addKeyboardObservers()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		removeObservers()
		Observers.disposeAllObservers()
	}
	
	//MARK: - Variables
	private var currencies = Array<Currency>()
	private var latestCurrencyCode: String?
	private var latestExchangeRate: ExchangeRate?
	private var latestAmountValue: Int = 1

	//MARK: - Initialization
	private func initializeData(){
		//RealmStorage.instance.deleteAllData()
		subscribeToErrors()
		subscribeToExchangeRate()
		RealmStorage.instance.initialize()
		subscribeToSelectedCurrencyCode()
		subscribeToCurrencyLists()
		RealmStorage.instance.requestCurrencyList()
	}
	
	private func initializeViews(){
		setTapGestureRecognizer()
		
		pickerView.delegate = self
		pickerView.dataSource = self
		
		pickerViewContainer.isHidden = true
		
		pickerLabel.onPressed = { [weak self] in
			self?.pickerTextField.endEditing(false)
			self?.pickerViewContainer.isHidden = false
		}
		
		pickerTextField.onValueChanged = { [weak self] newValue in
			self?.latestAmountValue = newValue
			self?.reloadTable()
		}
		
		initializeTableView()
	}
	
	private lazy var dataSource : UITableViewDiffableDataSource<Int, Currency> = {
		return UITableViewDiffableDataSource(tableView: tableView, cellProvider: {  [weak self] (tableView, indexPath, currency) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateTableViewCell.identifier, for: indexPath) as? ExchangeRateTableViewCell
			if let exchangeRate = self?.latestExchangeRate {
				let targetCurrencyCode = currency.code
				let sourceCurrencyCode = exchangeRate.source
				let targetAmount : Double = Double(self?.latestAmountValue ?? 1)
				
				if let rate = self?.getRateForCurrency(code: targetCurrencyCode), targetCurrencyCode != sourceCurrencyCode  {
					cell?.setValues(for: currency, to: rate * targetAmount)
				} else {
					cell?.setValues(for: currency, to: nil)
				}
			} else {
				cell?.setValues(for: currency, to: nil)
			}
			return cell ?? UITableViewCell()
		})
	}()
	
}

//MARK: - Data subscriptions
extension CurrencyExchangeViewController {
	private func subscribeToSelectedCurrencyCode(){
		/// Snippet to update picker view selected value to our custom label
		Observers.selectedCurrencySubject.subscribe(onNext: { [weak self] currencyCode in //Better keep all references as weak
			self?.selectNewCurrencyCode(currencyCode: currencyCode)
		}).disposed(by: disposeBag)
	}
	
	private func selectNewCurrencyCode(currencyCode: String){
		latestCurrencyCode = currencyCode
		pickerLabel.text = currencyCode
		tableView.setLoading(true)
		RealmStorage.instance.requestExchangeRate(for: currencyCode)
	}
	
	private func subscribeToCurrencyLists(){
		/// Subscriiption to currency list updates to update picker view
		Observers.currencyListSubject.subscribe(onNext: { [weak self] currencyList in
			if let currencyList = currencyList {
				if currencyList.currencies.count > 0 {
					print("Currency List Subscription returned \(currencyList.currencies.count) elements")
					//After first successful fetch, we do not really need it anymore for current app instance
					self?.currencies = Array(currencyList.currencies)
					self?.pickerView.reloadAllComponents()
					
					//lets set pickerViews starting location to current selected value
					if let row = self?.currencies.firstIndex(where: { $0.code == self?.pickerLabel.text}) {
						self?.pickerView.selectRow(row, inComponent: 0, animated: false)
					}
					self?.reloadTable()
					Observers.currencyListSubject.dispose()
					return
				}
			}
			print("Currency List subscription returned invalid data")
		}).disposed(by: disposeBag)
	}
	
	private func subscribeToExchangeRate(){
		Observers.exchangeRateSubject.subscribe(onNext: { [weak self] exchangeRate in
			if exchangeRate?.source == self?.latestCurrencyCode {
				self?.latestExchangeRate = exchangeRate
				self?.reloadTable()
				self?.tableView.setLoading(false)
			}
		}).disposed(by: disposeBag)
	}
	
	private func subscribeToErrors(){
		Observers.dataRetrieveError.subscribe(onNext: { [weak self] error in
			//Localizing error messages
			if let errorMessage = Localizable.APIError(rawValue: error.code)?.localized ?? error.info{
				self?.showErrorPopup(message: errorMessage)
			}
		}).disposed(by: disposeBag)
	}
	
	private func getRateForCurrency(code: String) -> Double? {
		return latestExchangeRate?.quotes.first(where: { $0.code.suffix(3) == code })?.rate
	}
}


//MARK: - Picker View delegates
extension CurrencyExchangeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return currencies.count
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		Observers.selectedCurrencySubject.onNext(currencies[row].code)
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return currencies[row].code
	}
}
//MARK: - Gestures and Notification observers
extension CurrencyExchangeViewController {
	
	/// Initializes and sets gesture recognition that is served to close pickerView or hides the software keyboard
	private func setTapGestureRecognizer(){
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	/// Initializes NotificationCenter observers for keyboard shown and hidden events, that is needed to trigger UI controls during those events
	private func addKeyboardObservers(){
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	/// Removes all ovservers from notification center for current view controller
	private func removeObservers(){
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc private func viewDidTap(){
		pickerViewContainer.isHidden = true
		pickerTextField.endEditing(false)
	}
	@objc func keyboardWillShow(){
		pickerViewContainer.isHidden = true
	}
	@objc func keyboardWillHide(){
		
	}
}

//MARK: - Table View configuration
// we use hashable/datasource tables, minimum code maximum efficiency
extension CurrencyExchangeViewController : UITableViewDelegate {
	private func initializeTableView(){
		tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
		tableView.allowsSelection = true
		tableView.showsHorizontalScrollIndicator = false
		tableView.isPagingEnabled = false
		tableView.separatorStyle = .none
		tableView.dataSource = dataSource
		tableView.delegate = self
		tableView.register(ExchangeRateTableViewCell.self, forCellReuseIdentifier: ExchangeRateTableViewCell.identifier)
	}
	
	@available(iOS 13.0, *)
	private func reloadTable(){
		var snapshot = NSDiffableDataSourceSnapshot<Int, Currency>()
			snapshot.appendSections([0])
			snapshot.appendItems(currencies)
			snapshot.reloadItems(currencies)
			dataSource.apply(snapshot, animatingDifferences: false)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let targetCurrencyCode = currencies.get(at: indexPath.row)?.code, let rate = getRateForCurrency(code: targetCurrencyCode) else { return }
		
		let targetAmount : Double = Double(latestAmountValue)
		
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal
		//High fraction due to most currencies having very low conversion rate, there is a high risk of showing 0 for most 1 to 1 rates.
		numberFormatter.maximumFractionDigits = 12
		let stringRepresentation = numberFormatter.string(for: targetAmount * rate)
		let pasteBoard = UIPasteboard.general
		pasteBoard.string = stringRepresentation
		showErrorPopup(message: "Copied!", duration: 2, height: 35.0)
	}
}
