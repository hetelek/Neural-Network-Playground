import UIKit

public class Graph: UIView {
    // MARK: - Value properties
    var minValue: Double?
    var maxValue: Double?
    var valueStreams: [UIColor:[Double]] = [:]
    
    
    // MARK: - Label properties
    private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    private(set) var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    private(set) var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    
    // MARK: - Initialization
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
        
        // title label
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])
        
        // top scale label
        addSubview(topLabel)
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            topLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5)
        ])
        
        // bottom scale label
        addSubview(bottomLabel)
        NSLayoutConstraint.activate([
            bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            bottomLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5)
        ])
    }
    
    
    // MARK: - Data logic
    public func addValue(_ value: Double, stream: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) {
        if valueStreams[stream] != nil {
            valueStreams[stream]?.append(value)
        }
        else {
            valueStreams[stream] = [value]
        }
        
        setNeedsDisplay()
    }
    
    private func getMin() -> Double? {
        var minValue: Double?
        
        for values in valueStreams.values {
            guard let newMin = values.min() else {
                continue
            }
            
            if let previousMin = minValue {
                minValue = min(previousMin, newMin)
            }
            else {
                minValue = newMin
            }
        }
        
        return minValue
    }
    
    private func getMax() -> Double? {
        var maxValue: Double?
        
        for values in valueStreams.values {
            guard let newMax = values.max() else {
                continue
            }
            
            if let previousMax = maxValue {
                maxValue = max(previousMax, newMax)
            }
            else {
                maxValue = newMax
            }
        }
        
        return maxValue
    }
    
    
    // MARK: - Drawing logic
    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        // get y axis scale
        let yMin: Double
        let yMax: Double
        if let minValue = minValue {
            yMin = minValue
        }
        else if let minValue = getMin() {
            yMin = minValue
        }
        else {
            return
        }
        
        if let maxValue = maxValue {
            yMax = maxValue
        }
        else if let maxValue = getMax() {
            yMax = maxValue
        }
        else {
            return
        }
        
        // update scales
        minValue = yMin
        maxValue = yMax
        let range = yMax - yMin
        
        // update scale labels
        bottomLabel.text = String(format: "%.2f", yMin)
        topLabel.text = String(format: "%.2f", yMax)
        
        for (strokeColor, values) in valueStreams {
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
}
