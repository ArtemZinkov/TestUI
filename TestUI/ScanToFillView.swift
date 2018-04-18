//
//  ViewController.swift
//  TestUI
//
//  Created by Artem on 13.04.2018.
//  Copyright © 2018 Artem. All rights reserved.
//

import UIKit

class ScanToFillView: UIView {
    
    var dictOfCenters = [Dots: CGPoint]() { didSet { setNeedsDisplay() } }
    var dictOfSidesRects = [Sides: CGRect]()
    let dictOfDotsForSides: [Sides:(Dots, Dots)] = [
        .up: (.upperLeft, .upperRight),
        .down: (.lowerLeft, .lowerRight),
        .left: (.upperLeft, .lowerLeft),
        .right: (.upperRight, .lowerRight)
    ]
    let sideDragerLenghtMod: CGFloat = 5 // means width side drager = 1/(mod + 1)

    override func draw(_ rect: CGRect) {
        if dictOfCenters.count != 4 {
            print("Dot centers are not setted!")
            return
        }
        
        drawDot(with: dictOfCenters[.upperLeft]!)
        drawDot(with: dictOfCenters[.upperRight]!)
        drawDot(with: dictOfCenters[.lowerLeft]!)
        drawDot(with: dictOfCenters[.lowerRight]!)
        drawMainRect()

        let upBeziarPath = getSideRect(between: .upperLeft, and: .upperRight)
        let downBeziarPath = getSideRect(between: .lowerRight, and: .lowerLeft)
        let leftBeziarPath = getSideRect(between: .lowerLeft, and: .upperLeft)
        let rightBeziarPath = getSideRect(between: .upperRight, and: .lowerRight)

        
        dictOfSidesRects[.up] = upBeziarPath.bounds.insetBy(dx: -10, dy: -10)
        dictOfSidesRects[.down] = downBeziarPath.bounds.insetBy(dx: -10, dy: -10)
        dictOfSidesRects[.left] = leftBeziarPath.bounds.insetBy(dx: -10, dy: -10)
        dictOfSidesRects[.right] = rightBeziarPath.bounds.insetBy(dx: -10, dy: -10)
        
        upBeziarPath.stroke()
        downBeziarPath.stroke()
        leftBeziarPath.stroke()
        rightBeziarPath.stroke()
        
        // Uncomment to show sides touch-zones
        for keyValue in dictOfSidesRects {
            let bp = UIBezierPath(rect: keyValue.value)
            bp.lineWidth = 3
            UIColor.red.setStroke()
            bp.stroke()
        }

    }
    
    func isConvex(with newDictOfCenters: [Dots: CGPoint]) -> Bool {
 
        return intersection(ofLineFrom: newDictOfCenters[.upperLeft]!, to: newDictOfCenters[.lowerRight]!, withLineFrom: newDictOfCenters[.upperRight]!, to: newDictOfCenters[.lowerLeft]!)
        
    }
        
    func intersection(ofLineFrom p1: CGPoint, to p2: CGPoint, withLineFrom p3: CGPoint, to p4: CGPoint) -> Bool {
        let d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x)
        if (d == 0) {
            return false // parallel lines
        }
        let u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
        let v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
        if (u < 0.0 || u > 1.0) {
            return false // intersection point not between p1 and p2
        }
        if (v < 0.0 || v > 1.0) {
            return false // intersection point not between p3 and p4
        }

        return true //CGPoint(x: p1.x + u * (p2.x - p1.x), y: p1.y + u * (p2.y - p1.y))
    }
    
    func drawDot(with center: CGPoint) {
        let path = UIBezierPath()
        path.addDot(withCenter: center)
        UIColor.azure.setFill()
        path.fill()
    }
    
    func drawMainRect() {
        let path = UIBezierPath()
        path.move(to: dictOfCenters[.upperLeft]!)
        path.addLine(to: dictOfCenters[.upperRight]!)
        path.addLine(to: dictOfCenters[.lowerRight]!)
        path.addLine(to: dictOfCenters[.lowerLeft]!)
        path.close()
        path.lineWidth = 5.0
        UIColor.azure.setStroke()
        UIColor.azure.withAlphaComponent(0.2).setFill()
        path.stroke()
        path.fill()
    }

    private func getSideRect(between firstDot: Dots, and secondDot: Dots) -> UIBezierPath {

        let centerOfSideRect = CGPoint(x: (dictOfCenters[firstDot]!.x + dictOfCenters[secondDot]!.x) / 2,
                                       y: (dictOfCenters[firstDot]!.y + dictOfCenters[secondDot]!.y) / 2)
        let startPoint = getSidePoint(betweenCenter: centerOfSideRect, andPoint: dictOfCenters[firstDot]!)
        let endPoint = getSidePoint(betweenCenter: centerOfSideRect, andPoint: dictOfCenters[secondDot]!)

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.close()
        UIColor.azure.setStroke()
        path.lineWidth = 15
        
        return path
    }
    
    private func getSidePoint(betweenCenter center: CGPoint, andPoint anotherPoint: CGPoint) -> CGPoint {
        return CGPoint(x: ((sideDragerLenghtMod * center.x) + anotherPoint.x) / (sideDragerLenghtMod + 1),
                y: ((sideDragerLenghtMod * center.y) + anotherPoint.y) / (sideDragerLenghtMod + 1))
    }
    
    func getDistance(between first: CGPoint, and second: CGPoint) -> Double {
        return sqrt(pow(Double(first.x - second.x), 2) + pow(Double(first.y - second.y),2))
    }
}

extension UIBezierPath {
    func addDot(withCenter center: CGPoint) {
        self.addArc(withCenter: center,
                    radius: 10,
                    startAngle: 0,
                    endAngle: 2*CGFloat.pi,
                    clockwise: true)
        self.close()
    }
}

extension UIColor {
    class var azure: UIColor {
        return UIColor(red: 0, green: 1/2, blue: 5/6, alpha: 1)
    }
}

enum Dots {
    case upperLeft
    case upperRight
    case lowerLeft
    case lowerRight
}

enum Sides {
    case up
    case down
    case left
    case right
}
