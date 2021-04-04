//
//  GraphLabelView.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import UIKit

class GraphLabelView: UIView {
	
	@IBOutlet weak var contentView: UIView?
	@IBOutlet weak var baloonView: UIView?
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var subtitleLabel: UILabel?
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	private func commonInit() {
		Bundle.main.loadNibNamed("GraphLabel", owner: self, options: nil)
		guard let contentView = contentView else { return }
		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(contentView)
		baloonView?.layer.cornerRadius = 16
	}

}
