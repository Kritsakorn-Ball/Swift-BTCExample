//
//  HistoryTableViewCell.swift
//  BTCExample
//
//  Created by Krisakorn Amnajsatit on 10/6/2566 BE.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var rateUSDLabel: UILabel!
    @IBOutlet weak var rateGBPLabel: UILabel!
    @IBOutlet weak var rateEURLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: BitcoinPriceModel) {
        if let date = DateFormatterUtility.shared.formatDateISOString(data.time.updatedISO) {
            dateTimeLabel.text = DateFormatterUtility.shared.formatShortDate(date)
        }
        rateUSDLabel.text = data.bpi.USD.rate
        rateGBPLabel.text = data.bpi.GBP.rate
        rateEURLabel.text = data.bpi.EUR.rate
    }
}
