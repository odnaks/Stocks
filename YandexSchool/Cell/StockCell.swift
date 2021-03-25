//
//  StockCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 23.03.2021.
//

import UIKit

// id: stockCell
class StockCell: UITableViewCell {
	
	@IBOutlet weak var logoImageView: UIImageView?
	@IBOutlet weak var tickerLabel: UILabel?
	@IBOutlet weak var nameLabel: UILabel?
	@IBOutlet weak var currentPriceLabel: UILabel?
	@IBOutlet weak var changeValueLabel: UILabel?
	@IBOutlet weak var changePercentLabel: UILabel?
	
	override func awakeFromNib() {
        super.awakeFromNib()
			logoImageView?.layer.cornerRadius = 12
			logoImageView?.layer.masksToBounds = true
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }

}
