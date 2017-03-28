import UIKit

public class NetworkCostView: UIView {
    // MARK: - Graph properties
    private let colors = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
    private let mainCostGraph: Graph = {
        let graph = Graph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.titleLabel.text = "Total Cost"
        graph.minValue = 0
        return graph
    }()
    private var otherGraphs: [Graph] = []
    
    
    // MARK: - Scroll view properties
    fileprivate let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    private var scrollViewPages: [UIView] = []
    
    
    // MARK: - Tableview Properties
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    // MARK: - Network properties
    public var network: Network
    public var inputs: [[Double]]
    public var outputs: [[Double]]
    public var learningRate: Double = 1
    
    
    // MARK: - Initialization
    public init(frame: CGRect, network: Network, inputs: [[Double]], outputs: [[Double]]) {
        self.network = network
        self.inputs = inputs
        self.outputs = outputs
        
        super.init(frame: frame)
        init2()
    }
    
    public override init(frame: CGRect) {
        fatalError("This initializer is not supported.")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("This initializer is not supported.")
    }
    
    private func init2() {
        // main view setup
        backgroundColor = .white
        
        // scroll view setup
        addSubview(scrollView)
        setupScrollView()
        
        // table view setup
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateScrollView()
    }
    
    
    // MARK: - Scroll view logic
    private func setupScrollView() {
        // create constraints
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65)
        ])
        
        // add main cost graph
        scrollViewPages.append(mainCostGraph)
        
        // create graph for each input
        for index in 0..<inputs.count {
            let graph = Graph()
            graph.translatesAutoresizingMaskIntoConstraints = false
            graph.titleLabel.text = "Cost for \(inputs[index])"
            graph.minValue = 0
            
            otherGraphs.append(graph)
            scrollViewPages.append(graph)
        }
    }
    
    private func updateScrollView() {
        // clear subviews
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
        var contentSize = scrollView.bounds.size
        contentSize.width = CGFloat(scrollViewPages.count) * scrollView.bounds.width
        scrollView.contentSize = contentSize
    }
    

    // MARK: - Network logic
    public func train() -> Double {
        // train the network
        network.batchTrain(batchInputs: inputs, batchExpectedOutputs: outputs, η: learningRate)
        
        // add cost to graph
        let cost = network.cost(batchInputs: inputs, batchExpectedOutputs: outputs)
        mainCostGraph.addValue(cost)
        
        // add costs for individual values
        for (index, input) in inputs.enumerated() {
            let inputs: [[Double]] = [input]
            let expectedOutputs: [[Double]] = [outputs[index]]
            let inputCost = network.cost(batchInputs: inputs, batchExpectedOutputs: expectedOutputs)
            
            // add cost to main graph and individuals
            let errorColor = colors[index]
            otherGraphs[index].addValue(inputCost, stream: errorColor)
            mainCostGraph.addValue(inputCost, stream: errorColor.withAlphaComponent(0.2))
        }
        
        return cost
    }
}

extension NetworkCostView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Outputs"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputs.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // feed network inputs
        let input = inputs[indexPath.row]
        let output = network.feed(inputs: input)[0][0].roundTo(places: 4)
        
        // create cell with output
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "\(input)"
        cell.detailTextLabel?.text = "\(output)"
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // calculate page location
        let page = indexPath.row + 1
        var rect = self.scrollView.bounds
        rect.origin.x = CGFloat(page) * rect.width
        
        // scroll to page
        scrollView.scrollRectToVisible(rect, animated: true)
        
        // deselect row
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NetworkCostView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // create view
        let view = UIView()
        view.backgroundColor = UIColor(colorLiteralRed: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        
        // block for creating labels
        let createLabel: (String) -> UILabel = { text in
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = text
            return label
        }
        
        // create left and right labels, pinned to their corresponding sides, centered vertically
        let labelPadding: CGFloat = 20
        
        let leftLabel = createLabel("Input")
        view.addSubview(leftLabel)
        NSLayoutConstraint.activate([
            leftLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: labelPadding),
            leftLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let rightLabel = createLabel("Network Output")
        view.addSubview(rightLabel)
        NSLayoutConstraint.activate([
            rightLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -labelPadding),
            rightLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        
        return view
    }
}
