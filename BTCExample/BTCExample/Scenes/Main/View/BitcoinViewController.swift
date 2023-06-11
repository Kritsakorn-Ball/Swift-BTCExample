//
//  ViewController.swift
//  BTCExample
//
//  Created by Krisakorn Amnajsatit on 8/6/2566 BE.
//

import UIKit
import RxSwift
import RxCocoa

class BitcoinViewController: UIViewController {
    @IBOutlet weak var chartNameLabel: UILabel!
    @IBOutlet weak var codeUSDLabel: UILabel!
    @IBOutlet weak var codeGBPLabel: UILabel!
    @IBOutlet weak var codeEURLabel: UILabel!
    @IBOutlet weak var rateUSDLabel: UILabel!
    @IBOutlet weak var rateGBPLabel: UILabel!
    @IBOutlet weak var rateEURLabel: UILabel!
    @IBOutlet weak var lastUpdatedTimeLabel: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var currencyOptionsView: UIView!
    @IBOutlet weak var currentCurrencyOptionLabel: UILabel!
    @IBOutlet weak var currencyAmountTextField: UITextField!
    @IBOutlet weak var bitCoinOutputLabel: UILabel!
    @IBOutlet weak var pinCodeTextField: UITextField!
    @IBOutlet weak var invalidTextLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private let viewModel = BitcoinViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        bindViewModel()
        bindAction()
        configTableView()
        viewModel.fetchBitcoinPrice()
        viewModel.startFetchingPeriodically(interval: 60)
    }
    
    private func configTableView() {
        self.historyTableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        self.historyTableView.dataSource = self
    }
    
    private func bindAction() {
        let currencyOptionsTapGesture = UITapGestureRecognizer()
        currencyOptionsView.addGestureRecognizer(currencyOptionsTapGesture)
        
        currencyOptionsTapGesture.rx.event
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.showDropdown(viewController: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.bitcoinPrice
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bitcoinPrice in
                guard let self = self,
                      let bitcoinPrice = bitcoinPrice else { return }
                self.chartNameLabel.text = bitcoinPrice.chartName
                self.codeUSDLabel.text = bitcoinPrice.bpi.USD.code
                self.codeGBPLabel.text = bitcoinPrice.bpi.GBP.code
                self.codeEURLabel.text = bitcoinPrice.bpi.EUR.code
                self.rateUSDLabel.text = bitcoinPrice.bpi.USD.rate
                self.rateGBPLabel.text = bitcoinPrice.bpi.GBP.rate
                self.rateEURLabel.text = bitcoinPrice.bpi.EUR.rate
                if let date = DateFormatterUtility.shared.formatDateISOString(bitcoinPrice.time.updatedISO) {
                    self.lastUpdatedTimeLabel.text = "\(DateFormatterUtility.shared.formatShortDate(date)) (Current)"
                }
                self.historyTableView.reloadData()
                self.historyTableViewHeight.constant = self.historyTableView.contentSize.height > 300 ? 300 : self.historyTableView.contentSize.height + 10
            })
            .disposed(by: disposeBag)
        
        viewModel.currencyType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] currencyType in
                guard let self = self else { return }
                self.currentCurrencyOptionLabel.text = currencyType.rawValue
            })
            .disposed(by: disposeBag)
        
        currencyAmountTextField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .map { [weak self] text -> String in
                guard let self = self else { return "" }
                return self.viewModel.validateNumberFormat(text)
            }
            .bind(to: viewModel.currencyAmountRelay)
            .disposed(by: disposeBag)
        
        currencyAmountTextField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .map { [weak self] text -> String in
                guard let self = self else { return "" }
                return self.viewModel.validateNumberFormat(text)
            }
            .bind(to: currencyAmountTextField.rx.text)
            .disposed(by: disposeBag)
        
        pinCodeTextField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .map { [weak self] text -> String in
                guard let self = self else { return "" }
                return self.viewModel.validatePinCodeFormat(text)
            }
            .bind(to: viewModel.pinCodeRelay)
            .disposed(by: disposeBag)
        
        pinCodeTextField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .map { [weak self] text -> String in
                guard let self = self else { return "" }
                return self.viewModel.validatePinCodeFormat(text)
            }
            .bind(to: pinCodeTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.pinCodeRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pinCode in
                guard let self = self else { return }
                if self.viewModel.isValidPinCode(pinCode) {
                    self.invalidTextLabel.textColor = UIColor.cyan
                    self.invalidTextLabel.text = "Correct Format"
                } else {
                    self.invalidTextLabel.textColor = UIColor.red
                    self.invalidTextLabel.text = "Invalid Format"
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.currencyType, viewModel.currencyAmountRelay.asObservable())
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] currencyType, currencyAmount in
                guard let self = self else { return }
                self.bitCoinOutputLabel.text = self.viewModel.convertToBitcoin(currencyType, currencyAmount)
            })
            .disposed(by: disposeBag)
    }
}

extension BitcoinViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
        let bitcoinPrice = viewModel.dataHistory[indexPath.row]
        cell.setData(data: bitcoinPrice)
        return cell
    }
}
