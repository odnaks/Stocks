//
//  TitleCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 24.03.2021.
//

import UIKit

// id: titleCell
class TitleCell: UICollectionViewCell {
	
	@IBOutlet weak var titleLabel: UILabel?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		titleLabel?.textColor = .gray
		titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18)
	}
	
	override var isSelected: Bool {
		didSet {
			guard let label = titleLabel else { return }
			if isSelected {
//				let newLabel = UILabel(frame: label.frame)
//				newLabel.font = UIFont(name: "Montserrat-Bold", size: 28)
//				newLabel.text = label.text
//				newLabel.adjustsFontSizeToFitWidth = true
//				newLabel.sizeToFit()
//				print(label.bounds)
//				print(newLabel.bounds)

				titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)

//				UIView.animate(withDuration: 1.5) {
//					self.titleLabel?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//				}
				titleLabel?.textColor = .black
				
				titleLabel?.updateConstraints()
				titleLabel?.adjustsFontSizeToFitWidth = true

				layoutIfNeeded()
				updateConstraints()
			} else {
				titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18)
				
				titleLabel?.adjustsFontSizeToFitWidth = true
//				UIView.animate(withDuration: 1.5) {
//					self.titleLabel?.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
//				}
				titleLabel?.textColor = .gray
				titleLabel?.updateConstraints()
				layoutIfNeeded()
				updateConstraints()
			}
		}
	}
	
}
