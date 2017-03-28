import UIKit

public class DrawingViewController: UIViewController, DrawingViewDelegate {
    // MARK: - Private properties
    private let drawingView: DrawingView = {
        let drawingView = DrawingView()
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        return drawingView
    }()
    private let resultsLabel: UILabel = {
        let resultsLabel = UILabel()
        resultsLabel.translatesAutoresizingMaskIntoConstraints = false
        resultsLabel.textAlignment = .center
        resultsLabel.text = "Draw a digit below..."
        return resultsLabel
    }()
    private let network: Network = {
        let url = Bundle.main.url(forResource: "mnist-network-weights", withExtension: nil)!
        return Network(url: url)
    }()
    
    
    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // main view setup
        title = "Drawing Digits"
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
        
        // setup results label
        view.addSubview(resultsLabel)
        NSLayoutConstraint.activate([
            resultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultsLabel.bottomAnchor.constraint(equalTo: drawingView.topAnchor, constant: -10)
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
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set stroke width to 10% of the width
        let strokeWidth = drawingView.bounds.width * 0.10
        drawingView.strokeWidth = strokeWidth
    }
    
    
    // MARK: - Delegate methods
    @objc private func clearDrawingView() {
        // clear view and reset label
        drawingView.clear()
        resultsLabel.text = "Draw a digit below..."
    }
    
    public func didEndDrawing() {
        // get image and resize it
        let image = UIImage(view: drawingView)
        let resized = image.resize(newSize: CGSize(width: 28, height: 28))
        
        // get pixel intesities in MNIST format
        let intensities = resized.grayScalePixelIntensities()
        
        // feed the network and set label's text
        let results = network.feed(inputs: intensities)
        let (_, output, _) = results.max()
        resultsLabel.text = "The network thinks this is \(output)."
    }
}
