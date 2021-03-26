//
//  StocksListController.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 22.03.2021.
//

import UIKit
import Kingfisher

class StocksListController: UIViewController {
	
	/*[Stock("aapl"), Stock("yndx"), Stock("googl"),
								   Stock("amzn"), Stock("bac"), Stock("MSFT"), Stock("TSLA"),
								   Stock("aapl"), Stock("yndx"), Stock("googl"),
								   Stock("amzn"), Stock("bac"), Stock("MSFT"), Stock("TSLA"),
								   Stock("aapl"), Stock("yndx"), Stock("googl"),
								   Stock("amzn"), Stock("bac"), Stock("MSFT"), Stock("TSLA")]*/

	@IBOutlet weak var tableView: UITableView?
//	@IBOutlet weak var titleCollectionView: UICollectionView?
	
	@IBOutlet weak var menuScrollView: MenuScrollView?
	private var stocks = [Stock]()
	private lazy var api = API()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView?.dataSource = self
//		titleCollectionView?.dataSource = self
//		titleCollectionView?.delegate = self
//		titleCollectionView?.allowsMultipleSelection = false
		
//		getStocks()
		
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
		
		menuScrollView?.setupWith(["hello", "it's me!"])

	}
	
	private func getStocks() {
		api.getTrands { [weak self] result in
			switch result {
			case .success(let data):
				self?.stocks = data
				self?.tableView?.reloadData()
				self?.getSummaryInfo()
			case .failure:
				// [need fix]
				print("err")
			}
		}
	}
	
	private func getSummaryInfo() {
		for (index, stock) in stocks.enumerated() {
			api.getSummary(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(let data):
					self?.stocks[index] = data
					let indexPath = IndexPath(row: index, section: 0)
					self?.tableView?.reloadRows(at: [indexPath], with: .automatic)
				case .failure:
					// [need fix]
					print("err")
					
				}
			}
			// [need fix] anti 429 error
			break
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
		let stock = stocks[indexPath.row]
		cell.tickerLabel?.text = stock.ticker
		cell.nameLabel?.text = stock.name
		cell.currentPriceLabel?.text = stock.currentPrice
		cell.changeValueLabel?.text = stock.changeValue
		cell.changePercentLabel?.text = stock.changePercent
		cell.logoImageView?.kf.setImage(with: stock.website)
		return cell
	}
	
}

//extension StocksListController: UICollectionViewDataSource, UICollectionViewDelegate {
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		2
//	}
//
//	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		guard let cell = titleCollectionView?.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath) as? TitleCell else { return UICollectionViewCell() }
//		cell.isSelected = indexPath.row == 0 ? true : false
//		cell.titleLabel?.text = indexPath.row == 0 ? "Stocks" : "Favourite"
//
//		return cell
//	}
//
//	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		guard let cell = collectionView.cellForItem(at: indexPath) as? TitleCell else { return }
//
//		cell.isSelected = true
//	}
//
//}
