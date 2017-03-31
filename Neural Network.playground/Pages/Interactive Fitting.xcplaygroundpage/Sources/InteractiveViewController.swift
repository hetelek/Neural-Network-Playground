import UIKit

public class InteractiveViewController: UIViewController, InteractiveGraphDelegate {
    // MARK: - Private properties
    private let graph: InteractiveGraph = {
        let graph = InteractiveGraph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        return graph
    }()
    private lazy var trainBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Train", style: .plain, target: self, action: #selector(tappedTrainButton))
        return button
    }()
    private lazy var resetBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(tappedResetButton))
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
    private let helperLabel: UILabel = {
        let helperLabel = UILabel()
        helperLabel.translatesAutoresizingMaskIntoConstraints = false
        helperLabel.textAlignment = .center
        helperLabel.textColor = .white
        return helperLabel
    }()
    private let helperLabelContainer: UIView = {
        let helperLabelContainer = UIView()
        helperLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        helperLabelContainer.backgroundColor = .black
        helperLabelContainer.alpha = 0.6
        return helperLabelContainer
    }()
    
    private var totalStepsTaken = 0
    private var totalStepsNeeded = 0
    
    
    // MARK: - Public properties
    public var η: Double = 5
    public var network: Network?
    
    
    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // main view setup
        title = "Interactive View"
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationItem.leftBarButtonItem = resetBarButton
        navigationItem.rightBarButtonItem = trainBarButton
        
        // setup interactive graph
        view.addSubview(graph)
        setupInteractiveGraph()
        
        // setup interactive graph
        view.addSubview(helperLabelContainer)
        setupHelperContainerLabel()
        
        // setup activity indicator
        view.insertSubview(activityIndicator, aboveSubview: graph)
        setupActivityIndicator()
        
        // setup progress bar
        view.insertSubview(progressView, aboveSubview: graph)
        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: view.leftAnchor),
            progressView.rightAnchor.constraint(equalTo: view.rightAnchor),
            progressView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func tappedTrainButton() {
        updateHelperText(text: "Training network...")
        trainNetwork(steps: 1000)
    }
    
    @objc private func tappedResetButton() {
        // remove all points from graph
        graph.points = []
        graph.graphContinuousFunction = false
        
        // create new network to re-initialize weights
        if let inputs = network?.inputs,
            let structure = network?.structure {
            network = Network(inputs: inputs, structure: structure)
        }
        
        // reset text
        updateHelperText(text: "Tap to add some points...")
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
        
        graph.graphContinuousFunction = false
        graph.continuousFunction = { x in
            guard let network = self.network else {
                return 0
            }
            let y = network.feed(inputs: [x])[0][0]
            return y
        }
    }
    
    private func setupActivityIndicator() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupHelperContainerLabel() {
        helperLabelContainer.layer.cornerRadius = 5
        
        NSLayoutConstraint.activate([
            helperLabelContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            helperLabelContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        helperLabelContainer.addSubview(helperLabel)
        NSLayoutConstraint.activate([
            helperLabel.centerXAnchor.constraint(equalTo: helperLabelContainer.centerXAnchor),
            helperLabel.centerYAnchor.constraint(equalTo: helperLabelContainer.centerYAnchor),
            helperLabelContainer.widthAnchor.constraint(equalTo: helperLabel.widthAnchor, constant: 50),
            helperLabelContainer.heightAnchor.constraint(equalTo: helperLabel.heightAnchor, constant: 10)
        ])
        
        updateHelperText(text: "Tap to add some points...")
    }
    
    
    // MARK: - UI logic
    private func showHelperText(animate: Bool, completionHandler: (() -> Void)? = nil) {
        if helperLabelContainer.alpha > 0 {
            completionHandler?()
        }
        
        let showContainerBlock: () -> Void = {
            self.helperLabelContainer.alpha = 0.6
        }
        
        if animate {
            UIView.animate(withDuration: 0.2, animations: {
                showContainerBlock()
            }, completion: { _ in
                completionHandler?()
            })
        }
        else {
            showContainerBlock()
        }
    }
    
    private func hideHelperText(animate: Bool, completionHandler: (() -> Void)? = nil) {
        if helperLabelContainer.alpha == 0 {
            completionHandler?()
        }
        
        let hideContainerBlock: () -> Void = {
            self.helperLabelContainer.alpha = 0
        }
        
        if animate {
            UIView.animate(withDuration: 0.2, animations: {
                hideContainerBlock()
            }, completion: { _ in
                completionHandler?()
            })
        }
        else {
            hideContainerBlock()
        }
    }
    
    private func updateHelperText(text: String, timeInterval: TimeInterval? = nil) {
        if text.isEmpty {
            helperLabelContainer.isHidden = true
        }
        else {
            helperLabel.text = text
            self.showHelperText(animate: true) {
                if let timeInterval = timeInterval {
                    Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
                        self.hideHelperText(animate: true)
                    }
                }
            }
        }
    }
    
    
    // MARK: - InteractiveGraphDelegate
    public func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint) {
        if graph.points.count < 4 {
            updateHelperText(text: "Tap to add some points...")
        }
        else {
            updateHelperText(text: "Tap \"Train\" to train the network.")
        }
    }
    
    
    // MARK: - Network logic
    private func trainNetwork(steps: Int) {
        totalStepsNeeded += steps
        
        trainingQueue.addOperation {
            guard let network = self.network else {
                return
            }
            
            // start animating
            DispatchQueue.main.sync {
                self.activityIndicator.startAnimating()
                self.resetBarButton.isEnabled = false
            }
            
            // get x and y points
            let x: [[Double]] = self.graph.points.map { [Double($0.x)] }
            let y: [[Double]] = self.graph.points.map { [Double($0.y)] }
            
            for _ in 0..<steps {
                // train step
                network.batchTrain(batchInputs: x, batchExpectedOutputs: y, η: self.η)
                
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
                    self.resetBarButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    // update helper text
                    self.updateHelperText(text: "Try training again or resetting...", timeInterval: 5)
                }
                
                // update graph
                self.graph.graphContinuousFunction = true
                self.graph.setNeedsDisplay()
            }
        }
    }
}
