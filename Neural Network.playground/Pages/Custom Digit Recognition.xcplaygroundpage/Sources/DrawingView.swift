import UIKit

@objc public protocol DrawingViewDelegate: class {
    @objc optional func didBeginDrawing()
    @objc optional func didEndDrawing()
}

public class DrawingView: UIView {
    // MARK: - Public properties
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
    
    
    // MARK: - Private properties
    private let path: UIBezierPath = {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        return path
    }()
    
    
    // MARK: - Initialization
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
    
    
    // MARK: - Clearing points
    public func clear() {
        path.removeAllPoints()
        setNeedsDisplay()
    }
    
    
    // MARK: - Touch events
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // get location of touch
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        // move path to point, inform delegate
        path.move(to: location)
        delegate?.didBeginDrawing?()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // get location of touch
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        // add line to point, update display
        path.addLine(to: location)
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // inform delegate that we stopped
        delegate?.didEndDrawing?()
    }
    
    
    // MARK: - Drawing
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // stroke the path
        strokeColor.set()
        path.lineWidth = strokeWidth
        path.stroke()
    }
}
