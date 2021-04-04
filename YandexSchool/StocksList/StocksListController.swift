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
	@IBOutlet weak var constraintTableToSearchBarTop: NSLayoutConstraint?
	
	private var pullControl = UIRefreshControl()
	
	var stocks = [Stock]()
	private var trands = [Stock]()
	private var favorites = [Stock]()
	private var favoritesSt = [String]()

	private lazy var fileManager = FileDataManager()
	var currentState: StocksListState = .trands
	
	// search bar
	var backSearchButton: UIButton?
	var searchSearchButton: UIImageView?
	var searchWorkItem: DispatchWorkItem?
	
	private var favoritesIsLoaded: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView?.dataSource = self
		tableView?.delegate = self
		
		menuStack?.delegate = self
		menuStack?.configure(with: ["Trands", "Favourite"])
		
		searchBar?.delegate = self
		setupSearchBar()
		
		pullControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		tableView?.refreshControl = pullControl
		
		getFavoritesTickers()
//		getTrands()
		
		// keyboard
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false // avoid table view selection and this gesture conflict
		view.addGestureRecognizer(tap)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func hideTitles() {
		constraintTableToSearchBarTop?.constant = 0
		menuStack?.isHidden = true
	}
	
	func showTitles() {
		constraintTableToSearchBarTop?.constant = 60
		menuStack?.isHidden = false
	}
	
	override func viewDidLayoutSubviews() {
		setupSearchBar()
	}
	
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
		searchBar.searchTextField.textColor = .black
		searchBar.tintColor = .black
		searchBar.setImage(UIImage(named: "closeSearch"), for: .clear, state: .normal)
		searchBar.searchTextField.font = UIFont(name: "Montserrat-SemiBold", size: 16)
		
		backSearchButton = UIButton()
		backSearchButton?.setImage(UIImage(named: "backSearch"), for: .normal)
		backSearchButton?.addTarget(self, action: #selector(clickLeftButton), for: .touchUpInside)
		
		searchSearchButton = UIImageView(image: UIImage(named: "searchSearch"))
		searchBar.searchTextField.leftView = searchSearchButton
	}
	
	@objc func refresh() {
		pullControl.endRefreshing()
		if currentState == .trands {
			getTrands()
		} else {
			getFavorites()
		}
	}
	
	// MARK: - get trands
	private func getTrands() {
		trands = []
		indicator?.startAnimating()
		API.shared.getTrands { [weak self] result in
			self?.indicator?.stopAnimating()
			switch result {
			case .success(let data):
				self?.trands = data
				self?.checkFavoritesInTrands()
				guard self?.currentState == .trands, let trands = self?.trands else { return }
				self?.stocks = trands
				self?.tableView?.reloadData()
				self?.getWebsitesForTrands {
					guard self?.currentState == .trands, let trands = self?.trands else { return }
					self?.menuStack?.isBlocked = true
					self?.stocks = trands
					self?.tableView?.reloadData()
					self?.menuStack?.isBlocked = false
				}
			case .failure:
				// [need fix] handle error
				break
			}
		}
	}
	
	private func getWebsitesForTrands(_ completion: (() -> Void)?) {
		let dispatchGroup = DispatchGroup()
		for (index, stock) in stocks.enumerated() {
			dispatchGroup.enter()
			API.shared.getWebsite(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(let website):
					guard self?.trands.count ?? 0 > index else { break }
					self?.trands[index].website = website
				case .failure:
					// [need fix] handle error
					break
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.notify(queue: .main) {
			completion?()
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
	
	// MARK: - get favorites
	private func getFavorites() {
		favorites = []
		indicator?.startAnimating()
		for ticker in favoritesSt {
			self.favorites.append(Stock(ticker))
		}
		self.getFavoriteSummary {
			self.indicator?.stopAnimating()
			if self.currentState == .favorites {
				self.menuStack?.isBlocked = true
				self.stocks = self.favorites
				self.tableView?.reloadData()
				self.menuStack?.isBlocked = false
				self.favoritesIsLoaded = true
			}
		}
	}
	
	private func getFavoritesTickers() {
		fileManager.loadFavoriteData { [weak self] res in
			guard let self = self else { return }
			switch res {
			case .success(let data):
				self.favoritesSt = data
			case .failure:
				// [need fix] handle error
				break
			}
		}
	}
	
	private func getFavoriteSummary(_ completion: (() -> Void)?) {
		let dispatchGroup = DispatchGroup()
		for (index, stock) in favorites.enumerated() {
			dispatchGroup.enter()
			API.shared.getStockInfo(with: stock.ticker) { [weak self] result in
				switch result {
				case .success(let data):
					guard self?.favorites.count ?? 0 > index else { break }
					self?.favorites[index] = data
					self?.favorites[index].isFavorite = true
				case .failure:
					// [need fix] handle error
					break
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.notify(queue: .main) {
			completion?()
		}
	}
	
	// MARK: - utils
	func updateState() {
		indicator?.stopAnimating()
		stocks = []
		tableView?.reloadData()
	
		switch currentState {
		case .trands:
			if !trands.isEmpty {
				checkFavoritesInTrands()
				stocks = trands
				tableView?.reloadData()
			} else {
				getTrands()
			}
		case .favorites:
			if !favorites.isEmpty && favoritesIsLoaded {
				stocks = favorites
				tableView?.reloadData()
			} else {
				getFavorites()
			}
		case .search:
			break
		}
	}
	
	func checkFavoritesInStocks() {
		for (index, trand) in stocks.enumerated() {
			if favoritesSt.contains(trand.ticker) {
				stocks[index].isFavorite = true
			} else {
				stocks[index].isFavorite = false
			}
		}
	}
	
	// MARK: - keyboard show/hide handler
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
									as? NSValue)?.cgRectValue else { return }
		additionalSafeAreaInsets.bottom = keyboardSize.height
	}

	@objc func keyboardWillHide(notification: NSNotification) {
		additionalSafeAreaInsets.bottom = 0
	}
}

// MARK: - MenuStackDelegate
extension StocksListController: MenuStackDelegate {
	func changeMenu(index: Int) {
		currentState = index == 0 ? .trands : .favorites
		updateState()
	}
}

// MARK: - UITableViewDataSource
extension StocksListController: UITableViewDataSource, UITableViewDelegate {
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? StockCell,
			  let stock = cell.stock,
			  let vc = StockInfoController.fabric(stock) else { return }
		vc.delegate = self
		navigationController?.pushViewController(vc, animated: true)
	}
}

// MARK: - StockCellDelegate
extension StocksListController: StockCellDelegate, StockInfoDelegate {
	func updateChanges() {
		updateState()
	}
	
	func addToFavorite(_ stock: Stock) {
		favorites.append(stock)
		favoritesSt.append(stock.ticker)
		// [need fix] handle save error
		fileManager.saveFavoriteData(favorites: favoritesSt) { _ in }
	}
	
	func deleteFromFavorite(_ stock: Stock) {
		favorites.removeAll { $0.ticker == stock.ticker }
		favoritesSt.removeAll { $0 == stock.ticker }
		// [need fix] handle save error
		fileManager.saveFavoriteData(favorites: favoritesSt) { _ in }
	}
}
