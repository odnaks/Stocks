//
//  StockCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 23.03.2021.
//

import UIKit
import Kingfisher

protocol StockCellDelegate {
	func addToFavorite(_ stock: Stock)
	func deleteFromFavorite(_ stock: Stock)
}

// id: stockCell
class StockCell: UITableViewCell {
	
	@IBOutlet weak var logoImageView: UIImageView?
	@IBOutlet weak var tickerLabel: UILabel?
	@IBOutlet weak var nameLabel: UILabel?
	@IBOutlet weak var currentPriceLabel: UILabel?
	@IBOutlet weak var changePriceLabel: UILabel?
	@IBOutlet weak var bgView: UIView?
	@IBOutlet weak var starButton: UIButton?
	
	var delegate: StockCellDelegate?
	
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
	}
	
	func configure(with stock: Stock, isEven: Bool) {
		self.stock = stock
		self.isEven = isEven
		
		tickerLabel?.text = stock.ticker
		bgView?.backgroundColor = isEven ? UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00) : .white
		
		guard let name = stock.name else { return }
		nameLabel?.text = name
		guard let currentPrice = stock.currentPrice,
			  let changeValue = stock.changeValue,
			  let changePercent = stock.changePercent else { return }
		starButton?.changeColor(stock.isFavorite ? UIColor(red: 1, green: 0.791, blue: 0.108, alpha: 1) : UIColor(red: 0.729, green: 0.729, blue: 0.729, alpha: 1))
//		if let intPrice = currentPrice.toInt() {
//			currentPriceLabel?.text = "$\(intPrice)"
//		} else {
			currentPriceLabel?.text = "$\(currentPrice.rounded(toPlaces: 2))"
//		}
		if changeValue < 0 {
			changePriceLabel?.text = "-$\(abs(changeValue.rounded(toPlaces: 2))) (\(abs(changePercent.rounded(toPlaces: 2)))%)"
			changePriceLabel?.textColor = UIColor(red: 0.70, green: 0.14, blue: 0.14, alpha: 1.00)
		} else {
			changePriceLabel?.text = "+$\(changeValue.rounded(toPlaces: 2)) (\(changePercent.rounded(toPlaces: 2))%)"
			changePriceLabel?.textColor = UIColor(red: 0.14, green: 0.70, blue: 0.36, alpha: 1.00)
		}
		if let website = stock.website {
			logoImageView?.kf.setImage(with: website) { [weak self] result in
				switch result {
				case .failure:
					self?.logoImageView?.image = self?.image(with: stock.ticker)
				default:
					break
				}
			}
		} else {
			logoImageView?.image = image(with: stock.ticker)
		}
	}
	
	@IBAction func clickStar(_ sender: Any) {
		guard let isFavorite = stock?.isFavorite else { return }
		self.stock?.isFavorite = !isFavorite
		starButton?.changeColor(isFavorite ? UIColor(red: 0.729, green: 0.729, blue: 0.729, alpha: 1) : UIColor(red: 1, green: 0.791, blue: 0.108, alpha: 1))
		guard let stock = stock else { return }
		if isFavorite {
			delegate?.deleteFromFavorite(stock)
		} else {
			delegate?.addToFavorite(stock)
		}
	}
	
	private func image(with ticker: String) -> UIImage? {
		let mySubstring = String(ticker.uppercased().prefix(2))
		let frame = CGRect(x: 0, y: 0, width: 520, height: 520)
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
		nameLabel.backgroundColor = .black
		nameLabel.textColor = .white
		nameLabel.font = UIFont(name: "Montserrat-SemiBold", size: 250)
		nameLabel.text = mySubstring
		UIGraphicsBeginImageContext(frame.size)
		if let currentContext = UIGraphicsGetCurrentContext() {
			nameLabel.layer.render(in: currentContext)
			let nameImage = UIGraphicsGetImageFromCurrentImageContext()
			return nameImage
		}
		return nil
	}
	
}

extension Double {

	func toInt() -> Int? {
		let roundedValue = rounded(.toNearestOrEven)
		return Int(exactly: roundedValue)
	}

}
