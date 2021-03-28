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
	@IBOutlet weak var searchBar: UISearchBar?
	
	private var stocks = [Stock]()
	private var trands = [Stock]()
	private var favorites = [Stock]()
	
	private var favoritesSt = [String]()
	
	private lazy var api = API()
	private lazy var fileManager = FileDataManager()
	private var currentMenuItem = 0
	
	private var pullControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView?.dataSource = self
		
		menuStack?.delegate = self
		menuStack?.configure(with: ["Stocks", "Favourite"])
		
		setupSearchBar()
		
//		pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		pullControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		tableView?.refreshControl = pullControl
		
//		getFavoritesTickers()
//		getTrands()
		
	}
	
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//
//
//	}
	
	private func setupSearchBar() {
		guard let searchBar = searchBar else { return }
		
		searchBar.searchBarStyle = .minimal
		searchBar.searchTextField.layer.cornerRadius = 18
		searchBar.searchTextField.layer.masksToBounds = true
		searchBar.searchTextField.backgroundColor = .white
		searchBar.searchTextField.borderStyle = .none
		searchBar.searchTextField.layer.borderWidth = 1
		searchBar.searchTextField.layer.borderColor = UIColor.black.cgColor
		searchBar.searchTextField.tintColor = .black
		searchBar.tintColor = .black
		
		searchBar.searchTextField.leftView = UIImageView(image: UIImage(named: "searchLeftImage"))
		searchBar.setImage(UIImage(named: "searchRightImage"), for: .clear, state: .normal)
		searchBar.searchTextField.font = UIFont(name: "Montserrat-SemiBold", size: 16)
		
//		if let searchTextField = searchBar.value(forKey: "_searchField") as? UITextField, let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton {
		   // Create a template copy of the original button image
//			clearButton.setImage(UIImage(named: "searchRightImage"), for: .normal)
			
//			let templateImage = clearButton.imageView?.image?.imageWithRenderingMode(.alwaysTemplate)
//		   // Set the template image copy as the button image
//		   clearButton.setImage(templateImage, forState: .Normal)
//		   // Finally, set the image color
//		   clearButton.tintColor = .redColor()
//		}
//		(searchBar.searchTextField.rightView as? UIButton)?.setImage(UIImage(named: "searchRightImage"), for: .normal)
	}
//
//	func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
//		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//		UIGraphicsBeginImageContextWithOptions(size, false, 0)
//		color.setFill()
//		UIRectFill(rect)
//		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//		UIGraphicsEndImageContext()
//		return image
//	}
	
	override func viewDidLayoutSubviews() {
		setupSearchBar()
	}
	
	@objc func refresh() {
		pullControl.endRefreshing()
		if currentMenuItem == 0 {
			getTrands()
		} else {
			getFavorites()
		}
	}
	
	private func getFavoritesTickers() {
		fileManager.loadFavoriteData { [weak self] res in
			guard let self = self else { return }
			switch res {
			case .success(let data):
				self.favoritesSt = data
			case .failure(let error):
				// [need fix] handle error
				print(error)
			}
		}
	}
	
	private func checkFavoritesInTrands() {
		for (index, trand) in trands.enumerated() {
			if favoritesSt.contains(trand.ticker) {
				trands[index].isFavorite = true
			} else {
				trands[index].isFavorite = false
			}
		}
	}
	
	private func checkFavoritesInStocks() {
		for (index, trand) in stocks.enumerated() {
			if favoritesSt.contains(trand.ticker) {
				stocks[index].isFavorite = true
			} else {
				stocks[index].isFavorite = false
			}
		}
	}
	
	private func getFavorites() {
		favorites = []
		stocks = []
		for ticker in favoritesSt {
			self.stocks.append(Stock(ticker))
		}
		self.getSummaryInfo(isFavorite: true) {
			self.indicator?.stopAnimating()
			self.favorites = self.stocks
		}
	}
	
	private func getTrands() {
		trands = []
		stocks = []
		indicator?.startAnimating()
		api.getTrands { [weak self] result in
			switch result {
			case .success(let data):
				self?.stocks = data
				self?.tableView?.reloadData()
				self?.getSummaryInfo {
					self?.indicator?.stopAnimating()
//					self?.checkFavoritesInTrands()
					guard let stocks = self?.stocks else { return }
					self?.trands = stocks
				}
			case .failure:
				// [need fix] handle error
				print("get trands error")
				self?.indicator?.stopAnimating()
			}
		}
	}
	
	private func getSummaryInfo(isFavorite: Bool = false, _ completion: (() -> Void)?) {
		let start = CFAbsoluteTimeGetCurrent()
		var deletedStockIndexes = [Int]()
		
		let dispatchGroup = DispatchGroup()
		for (index, stock) in stocks.enumerated() {
//			sleep(2)
			print("index = \(index), ticker = \(stock.ticker)")
			dispatchGroup.enter()
			api.getSummary(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(var data):
					print(CFAbsoluteTimeGetCurrent() - start)
					guard self?.stocks.count ?? 0 > index else { break }
					data.isFavorite = isFavorite ? true : false
					self?.stocks[index] = data
					dispatchGroup.leave()
//					guard let numberOfRows = self?.tableView?.numberOfRows(inSection: 0), numberOfRows > index else { return }
//					let indexPath = IndexPath(row: index, section: 0)
//					self?.tableView?.reloadRows(at: [indexPath], with: .automatic)
				case .failure:
					print("get summaray error")
					print(CFAbsoluteTimeGetCurrent() - start)
					deletedStockIndexes.append(index)
					dispatchGroup.leave()
//					guard let numberOfRows = self?.tableView?.numberOfRows(inSection: 0), numberOfRows > index else { return }
//					let indexPath = IndexPath(row: index, section: 0)
//					self?.tableView?.deleteRows(at: [indexPath], with: .automatic)
//					print(stock)
//					print("get summary error")
				}
			}
			// [need fix] anti 429 error
			break
		}
		dispatchGroup.notify(queue: .main) {
			print("notify")
			self.indicator?.stopAnimating()
			deletedStockIndexes.sort { $0 > $1 }
			for index in deletedStockIndexes {
				guard self.stocks.count > index else { break }
				self.stocks.remove(at: index)
				
				guard let numberOfRows = self.tableView?.numberOfRows(inSection: 0), numberOfRows > index else { return }
				let indexPath = IndexPath(row: index, section: 0)
				self.tableView?.deleteRows(at: [indexPath], with: .automatic)
			}
			self.checkFavoritesInStocks()
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
				checkFavoritesInTrands()
				stocks = trands
				tableView?.reloadData()
			} else {
				getTrands()
				tableView?.reloadData()
			}
		} else {
			// favorites
			if !favorites.isEmpty {
				stocks = favorites
				tableView?.reloadData()
			} else {
				getFavorites()
				tableView?.reloadData()
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
		cell.delegate = self
		return cell
	}
	
}

extension StocksListController: StockCellDelegate {
	func addToFavorite(_ stock: Stock) {
		favorites.append(stock)
		favoritesSt.append(stock.ticker)
		fileManager.saveFavoriteData(favorites: favoritesSt) { result in
			// [need fix] handle save error
		}
	}
	
	func deleteFromFavorite(_ stock: Stock) {
		favorites.removeAll { $0.ticker == stock.ticker }
		favoritesSt.removeAll { $0 == stock.ticker }
		fileManager.saveFavoriteData(favorites: favoritesSt) { result in
			// [need fix] handle save error
		}
//
//		guard let index = try? stocks.firstIndex(where: { $0.ticker == stock.ticker }),
//			  let numberOfRows = tableView?.numberOfRows(inSection: 0), numberOfRows > index else { return }
//		let indexPath = IndexPath(row: index, section: 0)
//		tableView?.deleteRows(at: [indexPath], with: .automatic)
	}
}

extension UIImage {
	func imageWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
		let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
		let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
		imageView.contentMode = .center
		imageView.image = self
		imageView.layer.borderWidth = width
		imageView.layer.borderColor = color.cgColor
		UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		imageView.layer.render(in: context)
		let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return result
	}
	
	func outline() -> UIImage? {



			UIGraphicsBeginImageContext(size)
			let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
			self.draw(in: rect, blendMode: .normal, alpha: 1.0)
			let context = UIGraphicsGetCurrentContext()
			context?.setStrokeColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 1.0)
			context?.setLineWidth(5.0)
			context?.stroke(rect)
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()



			return newImage



		}
}
