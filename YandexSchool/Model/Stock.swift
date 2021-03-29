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
	var currentPrice: Double?
	var changeValue: Double?
	var changePercent: Double?
//	var symbol: String?
	var website: URL?
	var isFavorite: Bool
//	var image: UIImage?
	
	init(_ ticker: String) {
		self.ticker = ticker
		self.isFavorite = false
	}
	
	// summary
	init(ticker: String, name: String, currentPrice: Double, changeValue: Double, changePercent: Double, website: URL?) {
		self.ticker = ticker
		self.name = name
		self.currentPrice = currentPrice
		self.changeValue = changeValue
		self.changePercent = changePercent
		self.website = website
		self.isFavorite = false
	}
	
	// trands
	init(ticker: String, name: String, currentPrice: Double, changeValue: Double, changePercent: Double) {
		self.ticker = ticker
		self.name = name
		self.currentPrice = currentPrice
		self.changeValue = changeValue
		self.changePercent = changePercent
		self.isFavorite = false
	}
	
	// search
	init(ticker: String, name: String) {
		self.ticker = ticker
		self.name = name
		self.isFavorite = false
	}
}
