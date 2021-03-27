//
//  StocksListController.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 22.03.2021.
//

import UIKit

class StocksListController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView?
	@IBOutlet weak var menuStack: MenuStack?
	@IBOutlet weak var indicator: UIActivityIndicatorView?
	
	private var stocks = [Stock]()
	private var trands = [Stock]()
	private var favorites = [Stock]()
	
	private var favoritesSt = ["YNDX", "AAPL", "GOOGL", "AMZN"]
	
	private lazy var api = API()
	private var currentMenuItem = 0
	
	private var pullControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView?.dataSource = self
		
		menuStack?.delegate = self
		menuStack?.configure(with: ["Stocks", "Favourite"])
		
//		pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		pullControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		tableView?.refreshControl = pullControl
		
		getTrands()
	}
	
	@objc func refresh() {
		pullControl.endRefreshing()
		if currentMenuItem == 0 {
			getTrands()
		} else {
			getFavorites()
		}
	}
	
	private func getFavorites() {
		stocks = []
		indicator?.startAnimating()
		// [need fix] load favorites
		
		for ticker in favoritesSt {
			stocks.append(Stock(ticker))
		}
		getSummaryInfo {
			self.indicator?.stopAnimating()
			self.favorites = self.stocks
		}
	}
	
	private func getTrands() {
		indicator?.startAnimating()
		api.getTrands { [weak self] result in
			switch result {
			case .success(let data):
				self?.stocks = data
				self?.getSummaryInfo {
					self?.indicator?.stopAnimating()
					guard let stocks = self?.stocks else { return }
					self?.trands = stocks
				}
			case .failure:
				// [need fix] handle error
				self?.indicator?.stopAnimating()
			}
		}
	}
	
	private func getSummaryInfo(_ completion: (() -> Void)?) {
//		let start = CFAbsoluteTimeGetCurrent()
		var deletedStockIndexes = [Int]()
		
		let dispatchGroup = DispatchGroup()
		for (index, stock) in stocks.enumerated() {
			dispatchGroup.enter()
			api.getSummary(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(let data):
					guard self?.stocks.count ?? 0 > index else { break }
					self?.stocks[index] = data
//					let indexPath = IndexPath(row: index, section: 0)
//					self?.tableView?.reloadRows(at: [indexPath], with: .automatic)
				case .failure:
					deletedStockIndexes.append(index)
				}
//				print(CFAbsoluteTimeGetCurrent() - start)
				dispatchGroup.leave()
			}
			// [need fix] anti 429 error
			break
		}
		dispatchGroup.notify(queue: .main) {
			self.indicator?.stopAnimating()
			deletedStockIndexes.sort { $0 > $1 }
			for index in deletedStockIndexes {
				guard self.stocks.count > index else { break }
				self.stocks.remove(at: index)
			}
			self.tableView?.reloadData()
			completion?()
		}
	}
}

extension StocksListController: MenuStackDelegate {
	func changeMenu(index: Int) {
		currentMenuItem = index
		if index == 0 {
			// trands
			if !trands.isEmpty {
				stocks = trands
				tableView?.reloadData()
			} else {
				getTrands()
			}
		} else {
			// favorites
			if !favorites.isEmpty {
				stocks = favorites
				tableView?.reloadData()
			} else {
				getFavorites()
			}
		}
	}
}

extension StocksListController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stocks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell") as? StockCell
				else { return UITableViewCell() }
		
		guard stocks.count > indexPath.row else { return cell }
		cell.configure(with: stocks[indexPath.row], isEven: indexPath.row % 2 == 0)
		return cell
	}
	
}
