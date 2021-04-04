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

    override func awakeFromNib() {
        super.awakeFromNib()
		bgView?.layer.cornerRadius = 16
    }
	
	func configure(with news: News) {
		self.news = news
	}

}
