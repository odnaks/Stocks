//
//  StocksListController+SearchBarDelegate.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 29.03.2021.
//

import UIKit

extension StocksListController: UISearchBarDelegate {
	// [need fix] bug: isHidden/change constraints not working
	// correctly with searchBar.leftView update
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		hideTitles()
		self.searchBar?.searchTextField.leftView = backSearchButton
		
		searchWorkItem?.cancel()
		searchWorkItem = nil
	
		// 	dispatchWorkItem - для отмены операции после ввода следующей буквы.
		// 	dispatchGroup - для группы задач, получающий дополнительную
		// информацию (getSummary) по списку акций, полученному из autoComplete.
		searchWorkItem = DispatchWorkItem { [weak self] in
			API.shared.autoComplete(with: searchText) { result in
				switch result {
				case .success(let data):
					let dg = DispatchGroup()
					self?.stocks = data
					self?.tableView?.reloadData()
						guard let stocks = self?.stocks else { return }
						for (index, stock) in stocks.enumerated() {
							dg.enter()
							API.shared.getStockInfo(with: stock.ticker) { summaryResult in
								dg.leave()
								switch summaryResult {
								case .success(let summaryStock):
									guard let count = self?.stocks.count, count > index,
										  self?.stocks[index].ticker == summaryStock.ticker else { break }
									let exchange = self?.stocks[index].exchange
									self?.stocks[index] = summaryStock
									self?.stocks[index].exchange = exchange
								case .failure:
									break
								}
							}
						}
					dg.notify(queue: .main) {
						self?.checkFavoritesInStocks()
						self?.tableView?.reloadData()
					}
				case .failure:
					break
				}
			}
		}
		guard let workItem = searchWorkItem else { return }
		DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: workItem)
	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		currentState = .search
		updateState()
		
		self.searchBar?.searchTextField.leftView = backSearchButton
		return true
	}
	
	@objc func clickLeftButton() {
		searchBar?.text = ""
		searchBar?.endEditing(false)
		
		currentState = .trands
		menuStack?.forceUpdatePosition(0)
		updateState()
		showTitles()
		
		self.searchBar?.searchTextField.leftView = searchSearchButton
	}

}
