//
//  StockSummary.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import Foundation

struct StockSummary {
	static let summaryProperties = [ "Previous Close", "Open", "Bid", "Ask",
									 "Day’s range", "52 Week Range", "Volume",
									 "Avarage volume", "Market Cap",
									 "Beta (5Y Monthly)", "Dividend Rate" ]
	
	var previousClose: String?
	var open: String?
	
	var bid: String?
	var bidSize: String?
	
	var ask: String?
	var askSize: String?
	
	var dayLow: String?
	var dayHigh: String?
	
	var fiftyTwoWeekLow: String?
	var fiftyTwoWeekHigh: String?
	
	var volume: String?
	
	var averageVolume: String?
	
	var marketCap: String?
	
	var beta: String?
	
	var dividendRate: String?
}
