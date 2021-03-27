//
//  UIButton+changeColor.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 27.03.2021.
//

import UIKit

extension UIButton {
	func changeColor(_ color: UIColor) {
		if let tempImage = imageView?.image?.withRenderingMode(.alwaysTemplate) {
			setImage(tempImage, for: .normal)
			tintColor = color
		}
	}
}
