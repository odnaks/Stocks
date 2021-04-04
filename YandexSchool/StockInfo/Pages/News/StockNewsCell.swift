//
//  StockNewsCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import UIKit

// id: stockNewsCell
class StockNewsCell: UICollectionViewCell {
	@IBOutlet weak var tableView: UITableView?
	@IBOutlet weak var indicator: UIActivityIndicatorView?
	
	private var stock: Stock?
	private var news = [News]()
	
	func configure(with stock: Stock?) {
		tableView?.dataSource = self
		tableView?.delegate = self
		
		self.stock = stock
		getNews()
	}
	
	private func getNews() {
		guard let ticker = stock?.ticker else { return }
		API.shared.getNews(with: ticker) { [weak self] result in
			self?.indicator?.stopAnimating()
			switch result {
			case .success(let data):
				self?.news = data
				self?.tableView?.reloadData()
			case .failure:
				// [need fix] handle error
				break
				
			}
		}
	}
}

extension StockNewsCell: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return news.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row % 2 == 0 ? "newsRightTableCell" : "newsLeftTableCell")
														as? NewsTableCell else { return UITableViewCell() }
		cell.configure(with: news[indexPath.row])
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? NewsTableCell,
			  let link = cell.news?.link,
			  let url = URL(string: link) else { return }
		UIApplication.shared.open(url)
	}
	
}
