import UIKit

public class Graph: UIView {
    var values: [Double] = []
    var strokeColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    var minValue: Double?
    var maxValue: Double?
    
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
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])
        
        addSubview(topLabel)
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            topLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5)
        ])
        
        addSubview(bottomLabel)
        NSLayoutConstraint.activate([
            bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            bottomLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5)
        ])
    }
    
    public func addValue(_ value: Double) {
        values.append(value)
        setNeedsDisplay()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        // get or calculate scales
        let yMin: Double
        let yMax: Double
        if let minValue = minValue,
            let maxValue = maxValue {
            yMin = minValue
            yMax = maxValue
        }
        else if let minValue = values.min(),
            let maxValue = values.max() {
            yMin = minValue
            yMax = maxValue
        }
        else {
            return
        }
        
        // update scales
        minValue = yMin
        maxValue = yMax
        
        // update scale labels
        bottomLabel.text = String(format: "%.2f", yMin)
        topLabel.text = String(format: "%.2f", yMax)
        
        // get range and number of points (index based)
        let range = yMax - yMin
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
            let yProportion = (value - yMin) / range
            
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
