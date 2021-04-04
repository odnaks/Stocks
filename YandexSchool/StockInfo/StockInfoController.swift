//
//  StockInfoController.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 03.04.2021.
//

import UIKit

// id: stockInfoController
class StockInfoController: UIViewController {
	
	@IBOutlet weak var headerView: UIView?
	@IBOutlet weak var menuStack: MenuStack?
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var subtitleLabel: UILabel?
	@IBOutlet weak var starButton: UIButton?
	@IBOutlet weak var buyButton: UIButton?
	@IBOutlet weak var collectionView: UICollectionView?
	
	private var stock: Stock?
	
	private var currentState: StockInfoState = .chart
	private var pagesCount = StockInfoState.allCases.count
	
	var delegate: FavoriteManagerDelegate?
	private var isStared: Bool = true
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		isStared = stock?.isFavorite ?? false
		
		menuStack?.delegate = self
		menuStack?.configure(with: ["Chart", "Summary", "News", "Forecast", "Ideas", "Events"],
							 minFontSize: 14, maxFontSize: 18, minHeight: 20, maxHeight: 24)

		setupStockInfo()
		setupCollectionView()
    }
	
	class func fabric(_ stock: Stock) -> Self? {
		let sb = UIStoryboard(name: "StockInfo", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "stockInfoController") as? Self
		vc?.stock = stock
		return vc
	}
	
	private func setupCollectionView() {
		collectionView?.dataSource = self
		collectionView?.delegate = self
		collectionView?.contentInsetAdjustmentBehavior = .never
		collectionView?.automaticallyAdjustsScrollIndicatorInsets = false
		collectionView?.isPagingEnabled = true
		
		collectionView?.delaysContentTouches = false
		collectionView?.contentInset = UIEdgeInsets.zero
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		layout.sectionInset = UIEdgeInsets.zero
		layout.invalidateLayout()
		guard let cv = collectionView else { return }
		var statusBarHeight: CGFloat
		if #available(iOS 13.0, *) {
			let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
			statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		} else {
			statusBarHeight = UIApplication.shared.statusBarFrame.height
		}
		layout.itemSize = CGSize(width: cv.safeAreaLayoutGuide.layoutFrame.width,
								 height: cv.safeAreaLayoutGuide.layoutFrame.height - statusBarHeight)
		collectionView?.collectionViewLayout = layout
	}
	
	private func setupStockInfo() {
		updateStarState()
		titleLabel?.text = stock?.ticker.uppercased()
		subtitleLabel?.text = stock?.name
		if let currentPrice = stock?.currentPrice {
			buyButton?.setTitle("Buy for $\(currentPrice.rounded(toPlaces: 2))", for: .normal)
		}
	}
	
	@IBAction func clickBack(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	// MARK: - Star
	private func updateStarState() {
		starButton?.setImage(isStared ? UIImage(named: "StarFill") : UIImage(named: "StarStroke"), for: .normal)
	}
	
	@IBAction func clickStar(_ sender: Any) {
		isStared = !isStared
		updateStarState()
		stock?.isFavorite = isStared
		guard let stock = stock else { return }
		isStared ? delegate?.addToFavorite(stock) : delegate?.deleteFromFavorite(stock)
	}
	
}

// MARK: - MenuStackDelegate
extension StockInfoController: MenuStackDelegate {
	
	func changeMenu(index: Int) {
		currentState = StockInfoState.init(rawValue: index) ?? .chart
		
		// ios14 bug https://developer.apple.com/forums/thread/663156
		collectionView?.isPagingEnabled = false
		collectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
		collectionView?.isPagingEnabled = true
	}
}

// MARK: - CollectionView
extension StockInfoController: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let x = targetContentOffset.pointee.x
		let item = x / view.frame.width
		menuStack?.forceUpdatePosition(Int(item))
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return pagesCount
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let index = indexPath.row
		if index == 0 {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stockChartCell", for: indexPath) as? StockChartCell else { return UICollectionViewCell() }
			cell.delegate = self
			cell.configure(with: stock)
			return cell
		} else if index == 1 {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stockSummaryCell", for: indexPath) as? StockSummaryCell else { return UICollectionViewCell() }
			cell.configure(with: stock)
			return cell
		} else if index == 2 {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stockNewsCell", for: indexPath) as? StockNewsCell else { return UICollectionViewCell() }
			cell.configure(with: stock)
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stockDefaultCell", for: indexPath) as UICollectionViewCell
			return cell
		}
	}
	
}

// MARK: - ChartDelegate
extension StockInfoController: ChartDelegate {
	func startWorkingWithGraph() {
		collectionView?.isScrollEnabled = false
	}
	
	func endWorkingWithGraph() {
		collectionView?.isScrollEnabled = true
	}
}
