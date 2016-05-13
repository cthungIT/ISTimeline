//
//  ISTimeline.swift
//  ISTimeline
//
//  Created by Max Holzleitner on 07.05.16.
//  Copyright © 2016 instant:solutions. All rights reserved.
//

import UIKit

class ISTimeline: UIView {

    var pointDiameter:CGFloat = 6.0 {
        didSet {
            if (pointDiameter < 0.0) {
                pointDiameter = 0.0
            } else if (pointDiameter > 100.0) {
                pointDiameter = 100.0
            }
        }
    }
    
    var lineWidth:CGFloat = 2.0 {
        didSet {
            if (lineWidth < 0.0) {
                lineWidth = 0.0
            } else if(lineWidth > 20.0) {
                lineWidth = 20.0
            }
        }
    }
    
    var bubbleHeight:CGFloat = 30.0 {
        didSet {
            if (bubbleHeight < 20.0) {
                bubbleHeight = 20.0
            } else if (bubbleHeight > 100.0) {
                bubbleHeight = 100.0
            }
        }
    }
    
    var bubbleRadius:CGFloat = 2.0 {
        didSet {
            if (bubbleRadius < 0.0) {
                bubbleRadius = 0.0
            } else if (bubbleRadius > 6.0) {
                bubbleRadius = 6.0
            }
        }
    }
    
    var lineColor = UIColor.lightGrayColor()
    var bubbleColor = UIColor.lightGrayColor()
    var textColor = UIColor.whiteColor()
    
    var points:[ISPoint] = [ISPoint(title: "", description: "", touchUpInside: nil), ISPoint(title: "", description: "", touchUpInside: nil)] {
        didSet {
            switch points.count {
            case 0:
                points = [ISPoint(title: "", description: "", touchUpInside: nil), ISPoint(title: "", description: "", touchUpInside: nil)]
            case 1:
                points.append(ISPoint(title: "", description: "", touchUpInside: nil))
            default:
                // nothing to do :)
                break
            }
        }
    }
    
    private var bubbleRects:[CGRect] = []
    
    override func drawRect(rect: CGRect) {
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(ctx)
        
        let arr = buildPointArray()
        
        for i in 0 ..< arr.count {
            if (i < arr.count - 1) {
                var start = arr[i]
                start.x += pointDiameter / 2
                start.y += pointDiameter
                
                var end = arr[i + 1]
                end.x = start.x
                
                drawLine(start, end: end, color: lineColor)
            }
            drawPoint(arr[i], color: UIColor.clearColor())
            let text = points[i].title
            if (text.characters.count > 0) {
                drawBubble(arr[i], color: bubbleColor, text: text)
            }
        }
        
        CGContextClosePath(ctx)
        CGContextRestoreGState(ctx)
    }
    
    private func buildPointArray() -> [CGPoint] {
        var arr = [CGPoint]()
        for i in 0 ..< points.count {
            var offset:CGFloat
            switch i {
            case 0:
                offset = 0.0
            case points.count - 1:
                offset = pointDiameter
            default:
                offset = pointDiameter / 2.0
            }
            offset -= self.bounds.origin.y
            offset -= bubbleHeight / 2.0
            
            let segment:CGFloat = (self.bounds.height - bubbleHeight) / CGFloat(points.count - 1)
            let y:CGFloat = segment * CGFloat(i) - offset
            let p = CGPointMake(self.bounds.origin.x + lineWidth / 2, y)
            arr.append(p)
        }
        return arr
    }
    
    private func drawLine(start:CGPoint, end:CGPoint, color:UIColor) {
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = color.CGColor
        shapeLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(shapeLayer)
    }
    
    private func drawPoint(point:CGPoint, color:UIColor) {
        let path = UIBezierPath(ovalInRect: CGRect(x: point.x, y: point.y, width: pointDiameter, height: pointDiameter))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.fillColor = color.CGColor
        shapeLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(shapeLayer)
    }
    
    private func drawBubble(point:CGPoint, color:UIColor, text:String) {
        var cPoint = point
        cPoint.x += pointDiameter + lineWidth / 2 + 5
        cPoint.y -= bubbleHeight / 2 - pointDiameter / 2
        
        let label = UILabel()
        label.text = text
        label.textColor = textColor
        label.font = UIFont.boldSystemFontOfSize(12.0)
        
        let rect = CGRectMake(cPoint.x + 8, cPoint.y, label.intrinsicContentSize().width + 20, bubbleHeight)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: bubbleRadius)
        
        let startPoint = CGPointMake(cPoint.x + 8, cPoint.y + rect.height / 2 - 8)
        path.moveToPoint(startPoint)
        path.addLineToPoint(startPoint)
        path.addLineToPoint(CGPointMake(cPoint.x, cPoint.y + rect.height / 2))
        path.addLineToPoint(CGPointMake(cPoint.x + 8, cPoint.y + rect.height / 2 + 8))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = color.CGColor
        
        self.layer.addSublayer(shapeLayer)
        bubbleRects.append(rect)
        
        let labelRect = CGRectMake(rect.origin.x + 10, rect.origin.y + 1, rect.size.width - 10, rect.size.height - 1)
        label.frame = labelRect
        self.addSubview(label)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = touches.first!.locationInView(self)
        for (index, rect) in bubbleRects.enumerate() {
            if (rect.contains(point)) {
                points[index].touchUpInside?(point: points[index])
                break
            }
        }
    }
}
