//
//  StockCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 23.03.2021.
//

import UIKit
import Kingfisher

// id: stockCell
class StockCell: UITableViewCell {
	
	@IBOutlet weak var logoImageView: UIImageView?
	@IBOutlet weak var tickerLabel: UILabel?
	@IBOutlet weak var nameLabel: UILabel?
	@IBOutlet weak var currentPriceLabel: UILabel?
	@IBOutlet weak var changePriceLabel: UILabel?
	@IBOutlet weak var bgView: UIView?
	@IBOutlet weak var starButton: UIButton?
	
	private var stock: Stock?
	private var isEven: Bool = false
	
	override func awakeFromNib() {
        super.awakeFromNib()
		nullify()
		logoImageView?.layer.cornerRadius = 12
		logoImageView?.layer.masksToBounds = true
		
		bgView?.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00)
		bgView?.layer.cornerRadius = 16
		
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		nullify()
	}
	
	private func nullify() {
		tickerLabel?.text = nil
		nameLabel?.text = nil
		currentPriceLabel?.text = nil
		changePriceLabel?.text = nil
		logoImageView?.image = nil
		starButton?.changeColor(.clear)
		bgView?.backgroundColor = .clear
//		starButton?.imageView?.image = nil
	}
	
	func configure(with stock: Stock, isEven: Bool) {
		self.stock = stock
		self.isEven = isEven
		
		guard let name = stock.name,
			  let currentPrice = stock.currentPrice,
			  let symbol = stock.symbol,
			  let changeValue = stock.changeValue,
			  let changePercent = stock.changePercent,
			  let website = stock.website else { return }
		
		bgView?.backgroundColor = isEven ? UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00) : .white
		tickerLabel?.text = stock.ticker
		nameLabel?.text = name
		currentPriceLabel?.text = "\(symbol)\(currentPrice)"
		changePriceLabel?.text = "\(changeValue)\(symbol) (\(changePercent))"
		logoImageView?.kf.setImage(with: website)
	}
	
//	private func getPrice(with price: String, and symbol: String) -> String {
//		return symbol == "₽" ? "\(price) \(symbol)" : "\(symbol) \(price)"
//	}
	
	@IBAction func clickStar(_ sender: Any) {
		print("click star")
	}
	
}
