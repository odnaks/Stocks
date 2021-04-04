//
//  GraphView.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 04.04.2021.
//

import UIKit

protocol GraphDelegate {
	func startWorkingWithGraph()
	func endWorkingWithGraph()
}

class GraphView: UIView {
	
	var delegate: GraphDelegate?
	
	private var thumb = CAShapeLayer()
	private var graphLabelView: GraphLabelView?
	private let graphLabelWidth: CGFloat = 100
	private let graphLabelHeight: CGFloat = 70
	private var step: CGFloat = 1
	private var graphPadding: CGFloat = 2

	private var prices = [CGFloat]()
	private var dates = [String]()
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	private func commonInit() {
		// graph label view
		let graphLabelView = GraphLabelView(frame: CGRect(x: 50, y: 50, width: graphLabelWidth, height: graphLabelHeight))
		addSubview(graphLabelView)
		self.graphLabelView = graphLabelView
		
		// thumb
		let radius: CGFloat = 6
		let center = CGPoint(x: 0, y: 0)
		let thumbPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
		thumb.path = thumbPath.cgPath
		thumb.fillColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.00).cgColor
		thumb.strokeColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00).cgColor
		thumb.lineWidth = 2
		layer.addSublayer(thumb)
	}

	override func draw(_ rect: CGRect) {
		graphLabelView?.isHidden = true
		thumb.isHidden = true
		guard prices.count > 3 else { return }
		thumb.isHidden = false
		graphLabelView?.isHidden = false
		
		backgroundColor = .clear
		let path = quadCurvedPath()

		UIColor.black.setStroke()
		path.lineWidth = 2
		path.stroke()
		
		updateSublayer(by: prices.count / 2)
	}
	
	func configure(prices: [CGFloat], dates: [String]) {
		self.prices = prices
		self.dates = dates
		
		setNeedsDisplay()
	}

	private func quadCurvedPath() -> UIBezierPath {
		let path = UIBezierPath()
		step = bounds.width / CGFloat(prices.count - 1)

		var p1 = CGPoint(x: 0, y: coordYFor(index: 0))
		path.move(to: p1)

		if prices.count == 2 {
			path.addLine(to: CGPoint(x: step, y: coordYFor(index: 1)))
			return path
		}

		var oldControlP: CGPoint?

		for i in 1..<prices.count {
			let p2 = CGPoint(x: step * CGFloat(i), y: coordYFor(index: i))
			var p3: CGPoint?
			if i < prices.count - 1 {
				p3 = CGPoint(x: step * CGFloat(i + 1), y: coordYFor(index: i + 1))
			}

			let newControlP = controlPointForPoints(p1: p1, p2: p2, next: p3)

			path.addCurve(to: p2, controlPoint1: oldControlP ?? p1, controlPoint2: newControlP ?? p2)

			p1 = p2
			oldControlP = antipodalFor(point: newControlP, center: p2)
		}
		return path
	}
	
	// MARK: - calculate
	private func coordYFor(index: Int) -> CGFloat {
		guard index < prices.count else { return 0 }
		let maxHeight = bounds.height - 2 * graphPadding
		let priceMin = prices.min() ?? 0
		let priceMax = prices.max() ?? 0
		let floorYPosition = prices[index] - priceMin
		return maxHeight - maxHeight * (floorYPosition / (priceMax - priceMin)) + graphPadding
	}

	//	located on the opposite side from the center point
	private func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
		guard let p1 = point, let center = center else {
			return nil
		}
		let newX = 2 * center.x - p1.x
		let diffY = abs(p1.y - center.y)
		let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)

		return CGPoint(x: newX, y: newY)
	}

	// halfway of two points
	func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
		return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
	}

	//	Find controlPoint2 for addCurve
	//	- Parameters:
	//	- p1: first point of curve
	//	- p2: second point of curve whose control point we are looking for
	//	- next: predicted next point which will use antipodal control point for finded
	private func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
		guard let p3 = p3 else {
			return nil
		}

		let leftMidPoint  = midPointForPoints(p1: p1, p2: p2)
		let rightMidPoint = midPointForPoints(p1: p2, p2: p3)

		var controlPoint = midPointForPoints(p1: leftMidPoint, p2: antipodalFor(point: rightMidPoint, center: p2)!)

		if p1.y.between(a: p2.y, b: controlPoint.y) {
			controlPoint.y = p1.y
		} else if p2.y.between(a: p1.y, b: controlPoint.y) {
			controlPoint.y = p2.y
		}

		let imaginContol = antipodalFor(point: controlPoint, center: p2)!
		if p2.y.between(a: p3.y, b: imaginContol.y) {
			controlPoint.y = p2.y
		}
		if p3.y.between(a: p2.y, b: imaginContol.y) {
			let diffY = abs(p2.y - p3.y)
			controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
		}

		// make lines easier
		controlPoint.x += (p2.x - p1.x) * 0.1

		return controlPoint
	}

	private func drawPoint(point: CGPoint, color: UIColor, radius: CGFloat) {
		let ovalPath = UIBezierPath(ovalIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
		color.setFill()
		ovalPath.fill()
	}
	
	private func updateSublayer(by index: Int) {
		// thumb
		let xPoint = CGFloat(index) * step
		let yPoint = coordYFor(index: index)
		thumb.position = CGPoint(x: xPoint, y: yPoint)
		
		// graph label
		var xGraphPoint = xPoint - self.graphLabelWidth / 2.0
		let yGraphPoint = yPoint - self.graphLabelHeight - 20.0 // 20 - vertical padding
		
		// boundary value handle
		xGraphPoint = max(0, xGraphPoint)
		if xGraphPoint + graphLabelWidth > bounds.width {
			xGraphPoint = bounds.width - graphLabelWidth
		}
		
		if let price = (prices[index] as NSNumber) as? Double {
			graphLabelView?.titleLabel?.text = "$\(price.rounded(toPlaces: 2))"
		}
		graphLabelView?.subtitleLabel?.text = dates[index]
		UIView.animate(withDuration: 0.4) {
			self.graphLabelView?.frame = CGRect(x: xGraphPoint, y: yGraphPoint,
												width: self.graphLabelWidth, height: self.graphLabelHeight)
		}
	}
	
	// MARK: - touches
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		delegate?.startWorkingWithGraph()
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		if let touch = touches.first {
			let position = touch.location(in: self)
			let xPosition = position.x
			
			var index: Int = Int(floor(xPosition / step))
			let mode = xPosition.truncatingRemainder(dividingBy: step)
			if  mode > step / 2 {
				index += 1
			}
			if index < prices.count {
				updateSublayer(by: index)
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		delegate?.endWorkingWithGraph()
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		delegate?.endWorkingWithGraph()
	}

}
