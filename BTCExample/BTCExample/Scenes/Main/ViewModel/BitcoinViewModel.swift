//
//  MainViewModel.swift
//  BTCExample
//
//  Created by Krisakorn Amnajsatit on 8/6/2566 BE.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class BitcoinViewModel {
    private let disposeBag = DisposeBag()
    private let bitcoinPriceRelay = BehaviorRelay<BitcoinPriceModel?>(value: nil)
    private let currencyTypeRelay = BehaviorRelay<CurrencyType>(value: .usd)
    let currencyAmountRelay = BehaviorRelay<String>(value: "")
    let pinCodeRelay = BehaviorRelay<String>(value: "")
    
    var currencyType: Observable<CurrencyType> {
        return currencyTypeRelay.asObservable()
    }
    
    var bitcoinPrice: Observable<BitcoinPriceModel?> {
        return bitcoinPriceRelay.asObservable()
    }
    
    var dataHistory: [BitcoinPriceModel] = []
    
    func isValidPinCode(_ input: String) -> Bool {
        return isLengthValid(input)
            && isDuplicateConnectedLessThanThree(input)
            && isSequentialNumbersConnectedLessThanThree(input)
            && isDuplicatePairsLessThanThree(input)
    }
    
    private func isLengthValid(_ input: String) -> Bool {
        return input.count >= 6
    }
    
    private func isDuplicateConnectedLessThanThree(_ input: String) -> Bool {
        let duplicateThreshold = 3
        var duplicateCount = 1
        for i in 1..<input.count {
            let currentIndex = input.index(input.startIndex, offsetBy: i)
            let previousIndex = input.index(input.startIndex, offsetBy: i - 1)
            if input[currentIndex] == input[previousIndex] {
                duplicateCount += 1
                if duplicateCount >= duplicateThreshold {
                    return false
                }
            } else {
                duplicateCount = 1
            }
        }
        return true
    }
    
    private func isSequentialNumbersConnectedLessThanThree(_ input: String) -> Bool {
        let sequentialThreshold = 3
        
        guard input.count >= sequentialThreshold else {
            return true
        }
        // 1 2 3 4 5 6  6-3-1 = 2    0 1 2
        for i in 0..<(input.count - sequentialThreshold + 1) {
            let startIndex = input.index(input.startIndex, offsetBy: i)
            let endIndex = input.index(input.startIndex, offsetBy: i + sequentialThreshold - 1)
            
            let substring = input[startIndex...endIndex]
            
            let numbers = substring.compactMap { Int(String($0)) }
            
            if numbers.count == sequentialThreshold {
                guard let firstNumber = numbers.first,
                      let lastNumber = numbers.last else { return false }
                var isAscendingSequence = false
                var isDescendingSequence = false
                if firstNumber <= lastNumber {
                    isAscendingSequence = numbers == Array(firstNumber...lastNumber)
                } else {
                    isDescendingSequence = numbers == Array(lastNumber...firstNumber).reversed()
                }
                if isAscendingSequence || isDescendingSequence {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func isDuplicatePairsLessThanThree(_ input: String) -> Bool {
        var duplicateCount = 0
        var previousChar: Character? = nil
        
        for char in input {
            if let prevChar = previousChar {
                if char == prevChar {
                    duplicateCount += 1
                    
                    if duplicateCount >= 3 {
                        return false
                    }
                    
                    previousChar = nil
                    continue
                }
            }
            
            previousChar = char
        }
        
        return true
    }
    
    private func addToHistory() {
        guard let data = bitcoinPriceRelay.value else { return }
        dataHistory.append(data)
    }
    
    func convertToBitcoin(_ currencyType: CurrencyType, _ amount: String) -> String {
        guard let amount = Double(amount),
              let bitcoinPrice = bitcoinPriceRelay.value else { return "Please enter amount"}
        switch currencyType {
        case .usd:
            return "\(amount/bitcoinPrice.bpi.USD.rate_float) BTC"
        case .gbp:
            return "\(amount/bitcoinPrice.bpi.GBP.rate_float) BTC"
        case .eur:
            return "\(amount/bitcoinPrice.bpi.EUR.rate_float) BTC"
        }
    }
    
    func validateNumberFormat(_ text: String) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")
        let filteredText = String(text.filter { allowedCharacterSet.contains(UnicodeScalar(String($0))!) })
        return filteredText
    }
    
    func validatePinCodeFormat(_ text: String) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let filteredText = String(text.filter { allowedCharacterSet.contains(UnicodeScalar(String($0))!) })
        return filteredText
    }
    
    func showDropdown(viewController: UIViewController) {
        let actionSheet = UIAlertController(title: "Select currency", message: nil, preferredStyle: .actionSheet)
        let option1Action = UIAlertAction(title: "USD", style: .default) { [weak self] _ in
            self?.currencyTypeRelay.accept(.usd)
        }
        actionSheet.addAction(option1Action)
        let option2Action = UIAlertAction(title: "GBP", style: .default) { [weak self] _ in
            self?.currencyTypeRelay.accept(.gbp)
        }
        actionSheet.addAction(option2Action)
        let option3Action = UIAlertAction(title: "EUR", style: .default) { [weak self] _ in
            self?.currencyTypeRelay.accept(.eur)
        }
        actionSheet.addAction(option3Action)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    func fetchBitcoinPrice() {
        addToHistory()
        guard let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json") else { return }
            URLSession.shared.rx.data(request: URLRequest(url: url))
                .subscribe(onNext: { [weak self] data in
                    guard let self = self else { return }
                    let decoder = JSONDecoder()
                    if let bitcoinPrice = try? decoder.decode(BitcoinPriceModel.self, from: data) {
                        self.bitcoinPriceRelay.accept(bitcoinPrice)
                    }
                })
                .disposed(by: disposeBag)
    }
    
    func startFetchingPeriodically(interval: TimeInterval) {
            Observable<Int>.interval(.seconds(Int(interval)), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    self?.fetchBitcoinPrice()
                })
                .disposed(by: disposeBag)
    }
}
