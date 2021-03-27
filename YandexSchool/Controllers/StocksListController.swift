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
	@IBOutlet weak var indicator: UIActivityIndicatorView?
	
	private var stocks = [Stock]()//[Stock("adddd"), Stock("."), Stock("bmp"), Stock("sdfsfdsfsdf"), Stock("yndx"), Stock("")]
	private var trands = [Stock]() //[Stock("adddd"), Stock("."), Stock("bmp"), Stock("sdfsfdsfsdf"), Stock("yndx"), Stock("")]
	private var favorites = [Stock]()
	
	
	private var favoritesSt = ["YNDX", "AAPL", "GOOGL", "AMZN" ]//, "BAC", "MSFT", "TSLA", "MA"]
	
	private lazy var api = API()
	private var currentMenuItem = 0
	
	
	private var pullControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView?.dataSource = self
		
//		indicator?.startAnimating()
		
		menuStack?.delegate = self
		menuStack?.configure(with: ["Stocks", "Favourite"])
//		titleCollectionView?.dataSource = self
//		titleCollectionView?.delegate = self
//		titleCollectionView?.allowsMultipleSelection = false
		
		

//		pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		pullControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		tableView?.refreshControl = pullControl
		
		
		getTrands()
		
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
//		api.getTrands { [weak self] result in
//			switch result {
//			case .success(let data):
//				self?.stocks = data
////				self?.tableView?.reloadData()
//				self?.getSummaryInfo()
//			case .failure:
//				// [need fix]
//				self?.indicator?.stopAnimating()
//				print("getStocks err")
//			}
//		}
		
		for ticker in favoritesSt {
			stocks.append(Stock(ticker))
		}
		getSummaryInfo {
			self.indicator?.stopAnimating()
			self.favorites = self.stocks
		}
	}
	
	private func getTrands() {
//		stocks = []
		indicator?.startAnimating()
		api.getTrands { [weak self] result in
			switch result {
			case .success(let data):
				self?.stocks = data
//				self?.tableView?.reloadData()
				self?.getSummaryInfo {
					self?.indicator?.stopAnimating()
					guard let stocks = self?.stocks else { return }
					self?.trands = stocks
				}
			case .failure:
				// [need fix]
				self?.indicator?.stopAnimating()
				print("getStocks err")
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
					self?.stocks[index] = data
//					let indexPath = IndexPath(row: index, section: 0)
//					self?.tableView?.reloadRows(at: [indexPath], with: .automatic)
				case .failure:
					deletedStockIndexes.append(index)
					print("getSummaryInfo err")
				}
//				print(CFAbsoluteTimeGetCurrent() - start)
				dispatchGroup.leave()
			}
			// [need fix] anti 429 error
//			break
		}
		dispatchGroup.notify(queue: .main) {
			self.indicator?.stopAnimating()
			deletedStockIndexes.sort { $0 > $1 }
			for index in deletedStockIndexes {
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
		
		cell.configure(with: stocks[indexPath.row], isEven: indexPath.row % 2 == 0)
		return cell
	}
	
}
