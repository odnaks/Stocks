//
//  StockChartController.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 03.04.2021.
//

import UIKit

// id: stockChartController
class StockChartController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		let graphView = GraphView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
		graphView.backgroundColor = .clear
		view.addSubview(graphView)
		
    }

}

class GraphView: UIView {
	
	private var thumb = CAShapeLayer()
	private var step: CGFloat = 0

	var data: [CGFloat] = [2, 6, 12, 4, 5, 7, 5, 6, 6, 3] {
		didSet {
			setNeedsDisplay()
		}
	}

	func coordYFor(index: Int) -> CGFloat {
		return bounds.height - bounds.height * data[index] / (data.max() ?? 0)
	}

	override func draw(_ rect: CGRect) {

		let path = quadCurvedPath()

		UIColor.black.setStroke()
		path.lineWidth = 2
		path.stroke()
		print(thumb.position)
		print(thumb.bounds)
		print(thumb.frame)
		thumb.fillColor = UIColor.white.cgColor
//		thumb.frame = self.bounds
		let radius: CGFloat = 4
		let center = CGPoint(x: 0, y: 0)
		let path2 = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
		thumb.path = path2.cgPath
		thumb.strokeColor = UIColor(red: 0.878, green: 0.039, blue: 0.118, alpha: 1).cgColor
		thumb.lineWidth = radius / 3
		thumb.zPosition = 1
		layer.addSublayer(thumb)
		print(thumb.position)
		print(thumb.bounds)
		print(thumb.frame)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let position = touch.location(in: self)
//			print(position)
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let position = touch.location(in: self)
			let xPosition = position.x
			
			var index: Int = Int(floor(xPosition / step))
			let mode = xPosition.truncatingRemainder(dividingBy: step)
			if  mode > step / 2 {
				index += 1
			}
			if index < data.count {
				thumb.position = CGPoint(x: CGFloat(index) * step, y: coordYFor(index: index))
			}
		}
	}

	func quadCurvedPath() -> UIBezierPath {
		let path = UIBezierPath()
		step = bounds.width / CGFloat(data.count - 1)

		var p1 = CGPoint(x: 0, y: coordYFor(index: 0))
		path.move(to: p1)

//		drawPoint(point: p1, color: UIColor.red, radius: 3)

		if data.count == 2 {
			path.addLine(to: CGPoint(x: step, y: coordYFor(index: 1)))
			return path
		}

		var oldControlP: CGPoint?

		for i in 1..<data.count {
			let p2 = CGPoint(x: step * CGFloat(i), y: coordYFor(index: i))
//			drawPoint(point: p2, color: UIColor.red, radius: 3)
			var p3: CGPoint?
			if i < data.count - 1 {
				p3 = CGPoint(x: step * CGFloat(i + 1), y: coordYFor(index: i + 1))
			}

			let newControlP = controlPointForPoints(p1: p1, p2: p2, next: p3)

			path.addCurve(to: p2, controlPoint1: oldControlP ?? p1, controlPoint2: newControlP ?? p2)

			p1 = p2
			oldControlP = antipodalFor(point: newControlP, center: p2)
		}
		return path
	}

	//	located on the opposite side from the center point
	func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
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
	func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
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

	func drawPoint(point: CGPoint, color: UIColor, radius: CGFloat) {
		let ovalPath = UIBezierPath(ovalIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
		color.setFill()
		ovalPath.fill()
	}

}

extension CGFloat {
	func between(a: CGFloat, b: CGFloat) -> Bool {
		return self >= Swift.min(a, b) && self <= Swift.max(a, b)
	}
}
