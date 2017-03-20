import UIKit

public class NetworkCostView: UIView {
    private let colors = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)]
    private let mainCostGraph: Graph = {
        let graph = Graph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.titleLabel.text = "Total Cost"
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
    
    public let network = Network(inputs: 2, structure: [12, 1])!
    public let inputs: [[Double]] = [[1, 1], [1, 0], [0, 1], [0, 0]]
    public let outputs: [[Double]] = [[0], [1], [1], [0]]
    
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        init2()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init2()
    }
    
    private func init2() {
        // main view setup
        backgroundColor = .white
        addSubview(scrollView)
        
        // create constraints
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
            ])
        
        // add main cost graph
        scrollViewPages.append(mainCostGraph)
        
        // create graph for each input
        for index in 0..<inputs.count {
            let graph = Graph()
            graph.translatesAutoresizingMaskIntoConstraints = false
            graph.strokeColor = colors[index % colors.count]
            graph.titleLabel.text = "Cost for \(inputs[index])"
            otherGraphs.append(graph)
        }
        scrollViewPages.append(contentsOf: otherGraphs as [UIView])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
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
        network.batchTrain(batchInputs: inputs, batchExpectedOutputs: outputs, η: 5)
        
        // add cost to graph
        let cost = network.cost(batchInputs: inputs, batchExpectedOutputs: outputs)
        mainCostGraph.addValue(cost)
        
        for (index, input) in inputs.enumerated() {
            let inputs: [[Double]] = [input]
            let expectedOutputs: [[Double]] = [outputs[index]]
            let inputCost = network.cost(batchInputs: inputs, batchExpectedOutputs: expectedOutputs)
            otherGraphs[index].addValue(inputCost)
        }
        
        return cost
    }
}
