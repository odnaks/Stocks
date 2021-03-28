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
		
		searchBar?.delegate = self
		setupSearchBar()
		
//		pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		pullControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		tableView?.refreshControl = pullControl
		
		getFavoritesTickers()
		getTrands()
		
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
		indicator?.startAnimating()
		for ticker in favoritesSt {
			self.favorites.append(Stock(ticker))
		}
		self.getFavoriteSummary {
			self.indicator?.stopAnimating()
			if self.menuStack?.currentPosition == 1 {
				self.stocks = self.favorites
				self.tableView?.reloadData()
			}
		}
	}
	
	private func getTrands() {
		trands = []
		indicator?.startAnimating()
		api.getTrands { [weak self] result in
			self?.indicator?.stopAnimating()
			switch result {
			case .success(let data):
				self?.trands = data
				self?.checkFavoritesInTrands()
				guard let trands = self?.trands else { return }
				self?.stocks = trands
				self?.tableView?.reloadData()
				self?.getWebsitesForTrands {
					guard self?.menuStack?.currentPosition == 0, let trands = self?.trands else { return }
					self?.stocks = trands
					self?.tableView?.reloadData()
				}
			case .failure:
				// [need fix] handle error
				print("get trands error")
			}
		}
	}
	
	private func getWebsitesForTrands(_ completion: (() -> Void)?) {
		let dispatchGroup = DispatchGroup()
		for (index, stock) in stocks.enumerated() {
			dispatchGroup.enter()
			api.getWebsite(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(let website):
					guard self?.trands.count ?? 0 > index else { break }
					self?.trands[index].website = website
				case .failure:
					// [need fix] handle error
					print("get website error")
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.notify(queue: .main) {
			completion?()
		}
	}
	
	private func getFavoriteSummary(_ completion: (() -> Void)?) {
		let dispatchGroup = DispatchGroup()
		for (index, stock) in stocks.enumerated() {
			dispatchGroup.enter()
			api.getSummary(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(let data):
					guard self?.favorites.count ?? 0 > index else { break }
					self?.favorites[index] = data
					self?.favorites[index].isFavorite = true
				case .failure:
					// [need fix] handle error
					print("getFavoriteSummary error")
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.notify(queue: .main) {
			completion?()
		}
	}
}

extension StocksListController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		menuStack?.isHidden = true
		if searchText == "text" {
			menuStack?.isHidden = false
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
				stocks = []
				tableView?.reloadData()
				getTrands()
			}
		} else {
			// favorites
			if !favorites.isEmpty {
				stocks = favorites
				tableView?.reloadData()
			} else {
				stocks = []
				tableView?.reloadData()
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
	}
}
