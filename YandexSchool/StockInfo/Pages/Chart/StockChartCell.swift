//
//  StockChartCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 03.04.2021.
//

import UIKit

protocol ChartDelegate {
	func startWorkingWithGraph()
	func endWorkingWithGraph()
}

// id: stockChartCell
class StockChartCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var subtitleLabel: UILabel?
	@IBOutlet weak var graphView: GraphView?
	@IBOutlet var rangeButtons: [UIButton]?
	var delegate: ChartDelegate?
	private var stock: Stock?
	
	private var currentRangeState: StockChartRangeState = .month
	
	override func awakeFromNib() {
		super.awakeFromNib()
		graphView?.delegate = self
		updateRangeButtons()
	}
	
	func configure(with stock: Stock?) {
		self.stock = stock
		guard let stock = stock,
			  let currentPrice = stock.currentPrice,
			  let changeValue = stock.changeValue,
			  let changePercent = stock.changePercent else { return }
		titleLabel?.text = "$\(currentPrice.rounded(toPlaces: 2))"
		if changeValue < 0 {
			subtitleLabel?.text = "-$\(abs(changeValue.rounded(toPlaces: 2))) (\(abs(changePercent.rounded(toPlaces: 2)))%)"
			subtitleLabel?.textColor = UIColor(red: 0.70, green: 0.14, blue: 0.14, alpha: 1.00)
		} else {
			subtitleLabel?.text = "+$\(changeValue.rounded(toPlaces: 2)) (\(changePercent.rounded(toPlaces: 2))%)"
			subtitleLabel?.textColor = UIColor(red: 0.14, green: 0.70, blue: 0.36, alpha: 1.00)
		}
		
		getChart()
	}
	
	private func getChart() {
		guard let ticker = stock?.ticker else { return }
		API.shared.getChart(with: ticker, and: currentRangeState) { result in
			switch result {
			case .success((let timespampes, let prices)):
				let (datesFormated, pricesFormated) = self.screeningApiData(timestampes: timespampes, prices: prices)
				self.graphView?.configure(prices: pricesFormated, dates: datesFormated)
			case .failure:
				// [need fix] handle error
				break
			}
		}
	}
	
	private func screeningApiData(timestampes: [Int?], prices: [Double?]) -> ([String], [CGFloat]) {
		var datesFormated = [String]()
		var pricesFormated = [CGFloat]()
		for index in 0..<timestampes.count {
			guard let timestamp = timestampes[index],
				  let price = prices[index], let priceFloat = (price as NSNumber) as? CGFloat else { continue }
			datesFormated.append(Date(timeIntervalSince1970: TimeInterval(timestamp)).getFormattedDate(format: "dd MMM yyyy"))
			pricesFormated.append(priceFloat)
		}
		return (datesFormated, pricesFormated)
	}
	
	private func updateRangeButtons() {
		guard let buttons = rangeButtons else { return }
		for button in buttons {
			if button.tag == currentRangeState.rawValue {
				// selected button
				button.backgroundColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.00)
				button.setTitleColor(.white, for: .normal)
			} else {
				button.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00)
				button.setTitleColor(UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.00), for: .normal)
			}
		}
	}
	
	@IBAction func clickRangeButton(_ sender: Any) {
		guard let button = sender as? UIButton else { return }
		currentRangeState = StockChartRangeState.init(rawValue: button.tag) ?? .month
		updateRangeButtons()
		getChart()
	}
	
}

extension StockChartCell: GraphDelegate {
	func startWorkingWithGraph() {
		delegate?.startWorkingWithGraph()
	}
	
	func endWorkingWithGraph() {
		delegate?.endWorkingWithGraph()
	}
}
