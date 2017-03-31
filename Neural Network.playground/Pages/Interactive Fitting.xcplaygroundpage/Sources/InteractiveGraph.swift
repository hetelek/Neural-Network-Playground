import UIKit

@objc public protocol InteractiveGraphDelegate: class {
    @objc optional func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint)
}

public class InteractiveGraph: UIView {
    // MARK: - Public properties
    public var points: [CGPoint] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    public var circleRadius: CGFloat = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    public var dotColor: UIColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    public var strokeColor: UIColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    public var continuousFunction: ((Double) -> Double)? {
        didSet {
            setNeedsDisplay()
        }
    }
    public var graphContinuousFunction: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public weak var delegate: InteractiveGraphDelegate?
    
    
    // MARK: - Private properties
    private var tapGesture = UITapGestureRecognizer()
    
    
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
        tapGesture.addTarget(self, action: #selector(receivedTap))
        addGestureRecognizer(tapGesture)
        
        isOpaque = true
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: - Gesture actions
    @objc private func receivedTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        // scale the point from 0 to 1, make bottom left origin
        let scaledX = location.x / bounds.width
        let scaledY = 1 - location.y / bounds.height
        let scaledLocation = CGPoint(x: scaledX, y: scaledY)
        
        // update array, inform delegate
        points.append(scaledLocation)
        delegate?.didAddPoint?(graph: self, newPoint: scaledLocation)

        // force update the ui
        setNeedsDisplay()
    }
    
    
    // MARK: - Drawing logic
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // we don't want to do anything if we have no context
        if let context = UIGraphicsGetCurrentContext() {
            drawPoints(context: context)
            
            if graphContinuousFunction {
                drawContinuousFunction()
            }
        }
    }
    
    private func drawContinuousFunction() {
        // make sure we have a function to graph
        guard let continuousFunction = continuousFunction else {
            return
        }
        
        // loop each x coordinate
        let path = UIBezierPath()
        for x in stride(from: 0, to: bounds.width, by: 1) {
            // calculate x and y
            let xProportion = x / bounds.width
            let yScaled = continuousFunction(Double(xProportion))
            let y = Double(bounds.height) * (1 - yScaled)
            
            // add point
            let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
            if x == 0 {
                path.move(to: point)
            }
            else {
                path.addLine(to: point)
            }
        }
        
        // stroke the line
        strokeColor.set()
        path.stroke()
    }
    
    private func drawPoints(context: CGContext) {
        // calculate the translation and size
        let pointTranslation = CGAffineTransform(translationX: -circleRadius, y: -circleRadius)
        let circleSize = CGSize(width: circleRadius * 2, height: circleRadius * 2)
        
        // add to context
        for scaledPoint in points {
            // scale x and y back to view size, make top left origin
            let xProportion = scaledPoint.x
            let yProportion = 1 - scaledPoint.y
            let centerPoint = CGPoint(x: xProportion * bounds.width, y: yProportion * bounds.height)
            
            // get (top left) location of circle
            let point = centerPoint.applying(pointTranslation)
            let location = CGRect(origin: point, size: circleSize)
            context.addEllipse(in: location)
        }
        
        // stroke the circles
        dotColor.set()
        context.strokePath()
    }
}
