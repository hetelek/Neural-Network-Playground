import UIKit

@objc public protocol DrawingViewDelegate: class {
    @objc optional func didBeginDrawing()
    @objc optional func didEndDrawing()
}

public class DrawingView: UIView {
    public var strokeColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    public var strokeWidth: CGFloat = 40 {
        didSet {
            setNeedsDisplay()
        }
    }
    public weak var delegate: DrawingViewDelegate?
    
    private let path: UIBezierPath = {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        return path
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init2()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init2()
    }
    
    private func init2() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    public func clear() {
        path.removeAllPoints()
        setNeedsDisplay()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        path.move(to: location)
        delegate?.didBeginDrawing?()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        path.addLine(to: location)
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        delegate?.didEndDrawing?()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        strokeColor.set()
        path.lineWidth = strokeWidth
        path.stroke()
    }
}
