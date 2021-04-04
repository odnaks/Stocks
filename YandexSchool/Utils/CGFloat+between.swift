//
//  CGFloat+between.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import UIKit

extension CGFloat {
	func between(a: CGFloat, b: CGFloat) -> Bool {
		return self >= Swift.min(a, b) && self <= Swift.max(a, b)
	}
}
