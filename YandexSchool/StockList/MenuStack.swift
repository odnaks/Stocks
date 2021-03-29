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
	var isBlocked: Bool = false
	private var currentPosition: Int = 0
	private var nominalHeight: CGFloat = 0
	
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
		for (index, title) in titles.enumerated() {
			let button = createButton(title: title, index: index)
			addArrangedSubview(button)
		}
		nominalHeight = bounds.size.height
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
		button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = .clear
		button.tag = index
		button.addTarget(self, action: #selector(clickMenuTitle), for: .touchUpInside)
		return button
	}
	
	private func updateButtons() {
		arrangedSubviews.forEach({ button in
			if let button = button as? UIButton {
				if button.tag == currentPosition {
					button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
					button.setTitleColor(.black, for: .normal)
					button.bounds.size.height = 32
				} else {
					button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18)
					button.setTitleColor(.gray, for: .normal)
					button.bounds.size.height = 24
				}
			}
		})
	}
	
	@objc func clickMenuTitle(_ sender: UIButton) {
		guard !isBlocked else { return }
		currentPosition = sender.tag
		updateButtons()
		delegate?.changeMenu(index: sender.tag)
	}
	
	func forceUpdatePosition(_ index: Int) {
		currentPosition = index
		updateButtons()
	}
	
}
