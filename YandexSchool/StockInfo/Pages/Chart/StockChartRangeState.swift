//
//  StockChartRangeState.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import Foundation

protocol ApiConvert {
	var apiRangeStr: String { get }
	var apiIntervalStr: String { get }
}

enum StockChartRangeState: Int, ApiConvert {
	case day = 0
	case week
	case month
	case sixMonth
	case year
	case all
	
	var apiRangeStr: String {
		switch self {
		case .day:
			return "1d"
		case .week:
			return "5d"
		case .month:
			return "1mo"
		case .sixMonth:
			return "6mo"
		case .year:
			return "1y"
		case .all:
			return "max"
		}
	}
	
	var apiIntervalStr: String {
		switch self {
		case .day:
			return "60m"
		default:
			return "1d"
		}
	}
}
