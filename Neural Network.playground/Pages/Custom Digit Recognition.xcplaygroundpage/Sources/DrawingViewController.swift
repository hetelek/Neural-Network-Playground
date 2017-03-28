import UIKit

public class DrawingViewController: UIViewController, DrawingViewDelegate {
    private var drawingView: DrawingView = {
        let drawingView = DrawingView()
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        return drawingView
    }()
    private let network: Network = {
        let url = Bundle.main.url(forResource: "mnist-network-weights", withExtension: nil)!
        return Network(url: url)
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // setup drawing view
        drawingView.delegate = self
        view.addSubview(drawingView)
        NSLayoutConstraint.activate([
            drawingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            drawingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            drawingView.heightAnchor.constraint(equalTo: drawingView.widthAnchor),
            drawingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // setup clear button
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearDrawingView), for: .touchUpInside)
        view.addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearButton.topAnchor.constraint(equalTo: drawingView.bottomAnchor)
        ])
    }
    
    @objc private func clearDrawingView() {
        drawingView.clear()
    }
    
    public func didEndDrawing() {
        let image = UIImage(view: drawingView)
        let resized = image.resize(newSize: CGSize(width: 28, height: 28))
        let intensities = resized.grayScalePixelIntensities()
        
        let (_, value, _) = network.feed(inputs: intensities).max()
        print(value)
    }
}
