//
//  SummaryTableCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import UIKit

// id: summaryTableCell
class SummaryTableCell: UITableViewCell {

	@IBOutlet weak var bgView: UIView?
	@IBOutlet weak var nameLabel: UILabel?
	@IBOutlet weak var valuelabel: UILabel?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		bgView?.layer.cornerRadius = 16
    }
	
	func configure(with stock: StockSummary, and index: Int) {
		bgView?.backgroundColor = index % 2 == 0 ? UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00) : .clear
		nameLabel?.text = StockSummary.summaryProperties[index]
		valuelabel?.text = "-"
		switch index {
		case 0:
			valuelabel?.text = stock.previousClose ?? "-"
		case 1:
			valuelabel?.text = stock.open ?? "-"
		case 2:
			if let bid = stock.bid, let bidSize = stock.bidSize {
				valuelabel?.text = "\(bid) x \(bidSize)"
			}
		case 3:
			if let ask = stock.ask, let askSize = stock.askSize {
				valuelabel?.text = "\(ask) x \(askSize)"
			}
		case 4:
			if let low = stock.dayLow, let high = stock.dayHigh {
				valuelabel?.text = "\(low) - \(high)"
			}
		case 5:
			if let low = stock.fiftyTwoWeekLow, let high = stock.fiftyTwoWeekHigh {
				valuelabel?.text = "\(low) - \(high)"
			}
		case 6:
			valuelabel?.text = stock.volume ?? "-"
		case 7:
			valuelabel?.text = stock.averageVolume ?? "-"
		case 8:
			valuelabel?.text = stock.marketCap ?? "-"
		case 9:
			valuelabel?.text = stock.beta ?? "-"
		case 10:
			valuelabel?.text = stock.dividendRate ?? "-"
		default:
			valuelabel?.text = "-"
		}
	}

}
