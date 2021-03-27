//
//  MenuStack.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 27.03.2021.
//

import UIKit

protocol MenuStackDelegate: NSObject {
	func changeMenu(index: Int)
}

class MenuStack: UIStackView {
	
	var delegate: MenuStackDelegate?
	var currentPosition: Int = 0
	
	required init(coder: NSCoder) {
		super.init(coder: coder)
		
		axis = .horizontal
		alignment = .bottom
		spacing = 20
	}
	
	func configure(with titles: [String]) {
		arrangedSubviews.forEach({
			removeArrangedSubview($0)
			$0.removeFromSuperview()
		})
//		var seasonButtons = []
		for (index, title) in titles.enumerated() {
			let button = createButton(title: title, index: index)
//			seasonButtons.append(button)
			addArrangedSubview(button)
		}

		updateButtons()
	}
	
	private func createButton(title: String, index: Int) -> UIButton {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(title, for: .normal)
		
		let label = UILabel()
		label.text = title
		label.font = UIFont(name: "Montserrat-Bold", size: 28)
		let labelSize = label.intrinsicContentSize

		button.frame = CGRect(x: 0, y: 0, width: labelSize.width, height: 32)
//		button.layer.borderWidth = 1
//		button.layer.borderColor = UIColor.startMainProductTextColor.withAlphaComponent(0.43).cgColor
//		button.layer.cornerRadius = 4
//		button.widthConstr = button.widthAnchor.constraint(equalToConstant: 41) //.isActive = true  //.c  constraint(equalToConstant: isIPad ? 124 : 41).isActive = true
//		button.widthConstr?.isActive = true
		button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
		button.setTitleColor(.black, for: .normal)
//		button.setTitleColor(.red, for: .selected)
		button.backgroundColor = .clear
		button.tag = index
		button.addTarget(self, action: #selector(clickMenuTitle), for: .touchUpInside)
//        c.isActive = true
//        c.priority = UILayoutPriority(rawValue: 750)
		return button
	}
	
	private func updateButtons() {
		arrangedSubviews.forEach({ button in
			if let button = button as? UIButton {
				if button.tag == currentPosition {
					button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
					button.setTitleColor(.black, for: .normal)
//					seasonButton.widthConstr?.constant = 80
//					seasonButton.backgroundColor = UIColor.startMainProductTextColor
//					seasonButton.setTitleColor(UIColor(netHex: 0x1D1F23), for: .normal)
//					seasonButton.setTitle("\(seasonButton.season.num ?? 1) сезон", for: .normal)
				} else {
					button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18)
					button.setTitleColor(.gray, for: .normal)
//					seasonButton.widthConstr?.constant = 41
//					seasonButton.backgroundColor = .clear
//					seasonButton.setTitleColor(UIColor.startMainProductTextColor, for: .normal)
//					seasonButton.setTitle("\(seasonButton.season.num ?? 1)", for: .normal)
				}
			}
		})
	}
	
	@objc func clickMenuTitle(_ sender: UIButton) {
		print(sender.tag)
		currentPosition = sender.tag
		updateButtons()
	}
	
}
