//
//  StocksListController.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 22.03.2021.
//

import UIKit

class StocksListController: UIViewController {
	
	/*[Stock("aapl"), Stock("yndx"), Stock("googl"),
								   Stock("amzn"), Stock("bac"), Stock("MSFT"), Stock("TSLA"),
								   Stock("aapl"), Stock("yndx"), Stock("googl"),
								   Stock("amzn"), Stock("bac"), Stock("MSFT"), Stock("TSLA"),
								   Stock("aapl"), Stock("yndx"), Stock("googl"),
								   Stock("amzn"), Stock("bac"), Stock("MSFT"), Stock("TSLA")]*/

	@IBOutlet weak var tableView: UITableView?
	@IBOutlet weak var menuStack: MenuStack?
	
	private var stocks = [Stock]()
	private lazy var api = API()
	private var currentMenuItem = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView?.dataSource = self
		
		menuStack?.delegate = self
		menuStack?.configure(with: ["Stocks", "Favourite"])
//		titleCollectionView?.dataSource = self
//		titleCollectionView?.delegate = self
//		titleCollectionView?.allowsMultipleSelection = false
		
		getStocks()
		
//		let start = CFAbsoluteTimeGetCurrent()
		
//		stocks[0].changePercent = "2.1%"
//		stocks[0].changeValue = "23.3"
//		stocks[0].currentPrice = "124.33"
//		stocks[0].name = "Apple Inc."
//		stocks[0].website = URL(string: "https://logo.clearbit.com/apple.com")
//
//		stocks[1].changePercent = "4.1%"
//		stocks[1].changeValue = "23.3"
//		stocks[1].currentPrice = "425.33"
//		stocks[1].name = "Yandex company"
//		stocks[1].website = URL(string: "https://logo.clearbit.com/yandex.com")
//
//		stocks[2].changePercent = "-4.1%"
//		stocks[2].changeValue = "-23.3"
//		stocks[2].currentPrice = "425.33"
//		stocks[2].name = "alphabet company"
//		stocks[2].website = URL(string: "https://logo.clearbit.com/abc.xyz")
//
//		tableView?.reloadData()
		
//		menuScrollView?.setupWith(["hello", "it's me!"])

	}
	
	private func getStocks() {
		api.getTrands { [weak self] result in
			switch result {
			case .success(let data):
				self?.stocks = data
//				self?.tableView?.reloadData()
				self?.getSummaryInfo()
			case .failure:
				// [need fix]
				print("getStocks err")
			}
		}
	}
	
	private func getSummaryInfo() {
		
		var deletedStockIndexes = [Int]()
		
		let dispatchGroup = DispatchGroup()
		for (index, stock) in stocks.enumerated() {
			dispatchGroup.enter()
			api.getSummary(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(let data):
					self?.stocks[index] = data
//					let indexPath = IndexPath(row: index, section: 0)
//					self?.tableView?.reloadRows(at: [indexPath], with: .automatic)
				case .failure:
					deletedStockIndexes.append(index)
//					self?.stocks.remove(at: index)
					print("getSummaryInfo err")
				}
				dispatchGroup.leave()
			}
			// [need fix] anti 429 error
//			break
		}
		dispatchGroup.notify(queue: .main) {
			deletedStockIndexes.reverse()
			for index in deletedStockIndexes {
				self.stocks.remove(at: index)
			}
			self.tableView?.reloadData()
		}
	}
	
}

extension StocksListController: MenuStackDelegate {
	func changeMenu(index: Int) {
		print(index)
	}
}

extension StocksListController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stocks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell") as? StockCell
				else { return UITableViewCell() }
		
//		if indexPath.row == 0 {
		cell.configure(with: stocks[indexPath.row], isEven: indexPath.row % 2 == 0)
//		}
		
		return cell
	}
	
}
