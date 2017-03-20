import UIKit

public class Graph: UIView {
    var values: [Double] = []
    var strokeColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        init2()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init2()
    }
    
    private func init2() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    public func addValue(_ value: Double) {
        values.append(value)
        setNeedsDisplay()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // get extremes from values
        guard let minValue = values.min(),
            let maxValue = values.max() else {
                return
        }
        
        // get range and number of points (index based)
        let range = maxValue - minValue
        let xAxisCount = Double(values.count - 1)
        
        // calculate stride for faster/effecient drawing
        let strideTo = CGFloat(values.count)
        let strideBy = max(1, strideTo / bounds.width)
        
        // create path
        let path = UIBezierPath()
        for indexFloat in stride(from: 0, to: strideTo, by: strideBy) {
            let index = Int(indexFloat)
            let value = values[index]
            
            // get where the point lies in terms of width/height percentages
            let xProportion = Double(index) / xAxisCount
            let yProportion = (value - minValue) / range
            
            // calculate true x and ys
            let x = CGFloat(xProportion) * bounds.width
            let y = CGFloat(1 - yProportion) * bounds.height
            
            // create point and add to path
            let point = CGPoint(x: x, y: y)
            if index == 0 {
                path.move(to: point)
            }
            else {
                path.addLine(to: point)
            }
        }
        
        // stroke path
        strokeColor.set()
        path.lineWidth = 2
        path.stroke()
    }
}
