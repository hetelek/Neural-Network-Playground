import UIKit

public class ViewController: UIViewController {
    private let colors = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)]
    private let mainCostGraph: Graph = {
        let graph = Graph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        return graph
    }()
    private var otherGraphs: [Graph] = []
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    private var scrollViewPages: [UIView] = []
    
    public let net = Network(inputs: 2, structure: [2, 1])!
    public let inputs: [[Double]] = [[1, 1], [1, 0], [0, 1], [0, 0]]
    public let outputs: [[Double]] = [[0], [1], [1], [0]]
    
    // MARK: - View Controller Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // add subviews
        view.addSubview(scrollView)
        
        // create constraints
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        ])
        
        // add main cost graph
        scrollViewPages.append(mainCostGraph)
        
        // create graph for each input
        for index in 0..<inputs.count {
            let graph = Graph()
            graph.translatesAutoresizingMaskIntoConstraints = false
            graph.strokeColor = colors[index]
            otherGraphs.append(graph)
        }
        scrollViewPages.append(contentsOf: otherGraphs as [UIView])
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateScrollView()
    }
    
    // MARK: - Scroll view logic
    private func updateScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        for (index, view) in scrollViewPages.enumerated() {
            // add view to scroll view
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
            
            // add constraints
            let currentLocation = CGFloat(index) * scrollView.bounds.width
            NSLayoutConstraint.activate([
                view.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: currentLocation),
                view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
        }
        
        // update content size
        scrollView.contentSize.width = CGFloat(scrollViewPages.count) * scrollView.bounds.width
    }

    // MARK: - Graph logic
    public func step() -> Double {
        // train the network
        net.batchTrain(batchInputs: inputs, batchExpectedOutputs: outputs, η: 5)
        
        // add cost to graph
        let cost = net.cost(batchInputs: inputs, batchExpectedOutputs: outputs)
        mainCostGraph.addValue(cost)
        
        for (index, input) in inputs.enumerated() {
            let inputCost = net.feed(inputs: input)[0][0] - outputs[index][0]
            otherGraphs[index].addValue(inputCost)
        }
        
        return cost
    }
}
