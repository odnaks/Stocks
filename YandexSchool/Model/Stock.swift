//
//  Stock.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 22.03.2021.
//

import UIKit

struct Stock {
	var ticker: String
	var name: String?
	var currentPrice: String?
	var changeValue: String?
	var changePercent: String?
	var symbol: String?
	var website: URL?
//	var image: UIImage?
	
	init(_ ticker: String) {
		self.ticker = ticker
	}
	
	init(ticker: String, name: String, currentPrice: String, changeValue: String, changePercent: String, symbol: String, website: URL) {
		self.ticker = ticker
		self.name = name
		self.currentPrice = currentPrice
		self.changeValue = changeValue
		self.changePercent = changePercent
		self.symbol = symbol
		self.website = website
	}
}
