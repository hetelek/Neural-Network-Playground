import UIKit

@objc public protocol InteractiveGraphDelegate: class {
    @objc optional func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint)
}

public class InteractiveGraph: UIView {
    public var points: [CGPoint] = []
    public var circleRadius: CGFloat = 5
    public var strokeColor: UIColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    public weak var delegate: InteractiveGraphDelegate?
    
    private var tapGesture = UITapGestureRecognizer()
    
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
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    @objc private func receivedTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        points.append(location)
        delegate?.didAddPoint?(graph: self, newPoint: location)

        setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // calculate the translation and size
        let pointTranslation = CGAffineTransform(translationX: -circleRadius, y: -circleRadius)
        let circleSize = CGSize(width: circleRadius * 2, height: circleRadius * 2)
        
        // add to context
        let context = UIGraphicsGetCurrentContext()
        for centerPoint in points {
            // get (top left) location of circle
            let point = centerPoint.applying(pointTranslation)
            let location = CGRect(origin: point, size: circleSize)
            context?.addEllipse(in: location)
        }
        
        // stroke the circles
        strokeColor.set()
        context?.strokePath()
    }
}
