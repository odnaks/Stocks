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
	
	// tmp
	private var isStared: Bool = true
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		menuStack?.delegate = self
		menuStack?.configure(with: ["Chart", "Summary", "News", "Forecast", "Ideas", "Events"],
							 minFontSize: 14, maxFontSize: 18, minHeight: 20, maxHeight: 24)
		
		collectionView?.dataSource = self
		
		updateStarState()
		titleLabel?.text = stock?.ticker.uppercased()
		subtitleLabel?.text = stock?.name
		buyButton?.layer.cornerRadius = 16
    }

	class func fabric(_ stock: Stock) -> Self? {
		let sb = UIStoryboard(name: "StockInfo", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "stockInfoController") as? Self
		vc?.stock = stock
		return vc
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
	}
	
}

// MARK: - MenuStackDelegate
extension StockInfoController: MenuStackDelegate {
	func updateState() {
		print(#function)
	}
	
	func changeMenu(index: Int) {
		currentState = StockInfoState.init(rawValue: index) ?? .chart
		updateState()
	}
}

extension StockInfoController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		2
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.row == 0 {
			guard let cell = collectionView.
		}
	}
}
