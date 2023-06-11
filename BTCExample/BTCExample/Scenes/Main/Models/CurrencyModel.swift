//
//  CurrencyModel.swift
//  BTCExample
//
//  Created by Krisakorn Amnajsatit on 9/6/2566 BE.
//
struct CurrencyModel: Codable {
    let code: String
    let symbol: String
    let rate: String
    let description: String
    let rate_float: Double
}
