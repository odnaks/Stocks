//
//  StockSummaryCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 03.04.2021.
//

import UIKit

// id: stockSummaryCell
class StockSummaryCell: UICollectionViewCell {
	@IBOutlet weak var tableView: UITableView?
	private var stock: Stock?
	@IBOutlet weak var indicator: UIActivityIndicatorView?
	private var stockSummary: StockSummary?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		tableView?.dataSource = self
	}
	
	func configure(with stock: Stock?) {
		self.stock = stock
		getSummary()
	}
	
	private func getSummary() {
		guard let ticker = stock?.ticker else { return }
		API.shared.getSummary(with: ticker) { [weak self] result in
			self?.indicator?.stopAnimating()
			switch result {
			case .success(let stockSummary):
				self?.stockSummary = stockSummary
				self?.tableView?.reloadData()
			case .failure:
				// [need fix] handle error
				break
			}
		}
	}
}

extension StockSummaryCell: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return StockSummary.summaryProperties.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "summaryTableCell") as? SummaryTableCell,
			  let stockSummary = stockSummary else { return UITableViewCell() }
		cell.configure(with: stockSummary, and: indexPath.row)
		return cell
	}
}
