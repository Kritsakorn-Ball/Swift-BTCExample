//
//  BitcoinPrice.swift
//  BTCExample
//
//  Created by Krisakorn Amnajsatit on 8/6/2566 BE.
//
struct BitcoinPriceModel: Codable {
    let time: TimeModel
    let disclaimer: String
    let chartName: String
    let bpi: BPIModel
}
