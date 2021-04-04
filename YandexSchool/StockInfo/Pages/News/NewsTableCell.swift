//
//  NewsTableCell.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import UIKit

// id: newsRightTableCell
// id: newsLeftTableCell
class NewsTableCell: UITableViewCell {
	@IBOutlet weak var bgView: UIView?
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var introLabel: UILabel?
	@IBOutlet weak var photoImageView: UIImageView?
	@IBOutlet weak var dateLabel: UILabel?
	
	private var news: News?
	
	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel?.text = nil
		introLabel?.text = nil
		photoImageView?.image = nil
		dateLabel?.text = nil
	}

    override func awakeFromNib() {
        super.awakeFromNib()
		bgView?.layer.cornerRadius = 16
		photoImageView?.layer.cornerRadius = 16
		photoImageView?.layer.masksToBounds = true
    }
	
	func configure(with news: News) {
		self.news = news
		titleLabel?.text = news.title
		introLabel?.text = news.summary
		
		if let urlString = news.photoUrl, let url = URL(string: urlString) {
			photoImageView?.kf.setImage(with: url)
		}
		
		if let timestamp = news.date {
			let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
			let formatter = DateFormatter()
			formatter.dateFormat = isToday(date) ? "HH:mm" : "dd MMM"
			dateLabel?.text = formatter.string(from: date)
		}

	}
	
	private func isToday(_ date: Date) -> Bool {
		return Calendar.current.isDateInToday(date)
	}

}
