import UIKit
import PlaygroundSupport

public class InteractiveViewController: UIViewController, InteractiveGraphDelegate {
    // MARK: - Private properties
    private let network = Network(inputs: 1, structure: [15, 5, 1])!
    private let graph: InteractiveGraph = {
        let graph = InteractiveGraph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        return graph
    }()
    private lazy var trainBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tappedTrainButton))
        return button
    }()
    private lazy var settingsBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(tappedSettingsButton))
        return button
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    private let trainingQueue: OperationQueue = {
        let trainingQueue = OperationQueue()
        trainingQueue.underlyingQueue = DispatchQueue.global(qos: .background)
        trainingQueue.maxConcurrentOperationCount = 1
        return trainingQueue
    }()
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private var totalStepsTaken = 0
    private var totalStepsNeeded = 0
    
    
    // MARK: - Public properties
    public var η: Double = 1
    
    
    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // main view setup
        title = "Interactive View"
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationItem.leftBarButtonItem = trainBarButton
        navigationItem.rightBarButtonItem = settingsBarButton
        
        view.addSubview(graph)
        setupInteractiveGraph()
        
        view.insertSubview(activityIndicator, aboveSubview: graph)
        setupActivityIndicator()
        
        view.insertSubview(progressView, aboveSubview: graph)
        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: view.leftAnchor),
            progressView.rightAnchor.constraint(equalTo: view.rightAnchor),
            progressView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func tappedTrainButton() {
        trainNetwork(steps: 1000)
    }
    
    @objc private func tappedSettingsButton() {
        
    }
    
    // MARK: - Interactive graph logic
    private func setupInteractiveGraph() {
        // set delegate and create constraints
        graph.delegate = self
        NSLayoutConstraint.activate([
            graph.leftAnchor.constraint(equalTo: view.leftAnchor),
            graph.rightAnchor.constraint(equalTo: view.rightAnchor),
            graph.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            graph.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ])
        
        graph.continuousFunction = { x in
            let y = self.network.feed(inputs: [x])[0][0]
            return y
        }
        
        graph.setNeedsDisplay()
    }
    
    private func setupActivityIndicator() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    // MARK: - InteractiveGraphDelegate
    public func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint) {
        print("point added")
    }
    
    
    // MARK: - Network logic
    private func trainNetwork(steps: Int) {
        totalStepsNeeded += steps
        
        trainingQueue.addOperation {
            // start animating
            DispatchQueue.main.sync {
                self.activityIndicator.startAnimating()
            }
            
            // get x and y points
            let x: [[Double]] = self.graph.points.map { [Double($0.x)] }
            let y: [[Double]] = self.graph.points.map { [Double($0.y)] }
            
            for _ in 0..<steps {
                // train step
                self.network.batchTrain(batchInputs: x, batchExpectedOutputs: y, η: self.η)
                
                // update progress bar
                self.totalStepsTaken += 1
                DispatchQueue.main.async {
                    let progress = Float(self.totalStepsTaken) / Float(self.totalStepsNeeded)
                    self.progressView.progress = progress
                }
            }
            
            DispatchQueue.main.sync {
                // if we're completely finished training, reset everything
                if self.totalStepsTaken == self.totalStepsNeeded {
                    self.totalStepsTaken = 0
                    self.totalStepsNeeded = 0
                    self.progressView.progress = 0
                    self.activityIndicator.stopAnimating()
                }
                
                // update graph
                self.graph.setNeedsDisplay()
            }
        }
    }
}

let interactiveController = InteractiveViewController()
let navigationController = UINavigationController(rootViewController: interactiveController)
PlaygroundPage.current.liveView = navigationController
