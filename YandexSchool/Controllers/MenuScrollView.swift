//
//  MenuScrollView.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 26.03.2021.
//

import UIKit

class MenuScrollView: UIScrollView {

	private var currentSelected: Int = 0
	
	func setupWith(_ titles: [String]) {
		var buttonX: CGFloat = 0
		for title in titles {
			let titleLabel = UILabel()
			titleLabel.text = title
			titleLabel.font = UIFont(name: "Montserrat-Bold", size: 28)
			
			let button = UIButton(frame: CGRect(x: buttonX, y: 0, width: titleLabel.intrinsicContentSize.width, height: titleLabel.intrinsicContentSize.height))
			button.setTitle(title, for: .normal)
			button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
			button.setTitleColor(.black, for: .normal)
			self.addSubview(button)
			buttonX += button.intrinsicContentSize.width + 20
		}
	}

}
