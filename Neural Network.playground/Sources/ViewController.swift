import UIKit

public class ViewController: UIViewController {
    private let graph = Graph()
    
    public let net = Network(inputs: 2, structure: [2, 1])!
    public let inputs: [[Double]] = [[1, 1], [1, 0], [0, 1], [0, 0]]
    public let outputs: [[Double]] = [[0], [1], [1], [0]]
    
    public func addValue(_ value: Double) {
        graph.addValue(value)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // add graph to view
        view.backgroundColor = .white
        view.addSubview(graph)
        
        // create constraints
        graph.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graph.leftAnchor.constraint(equalTo: view.leftAnchor),
            graph.rightAnchor.constraint(equalTo: view.rightAnchor),
            graph.topAnchor.constraint(equalTo: view.topAnchor),
            graph.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }
    
    public func step() -> Double {
        // train the network
        net.batchTrain(batchInputs: inputs, batchExpectedOutputs: outputs, η: 5)
        
        // add cost to graph
        let cost = net.cost(batchInputs: inputs, batchExpectedOutputs: outputs)
        addValue(cost)
        
        return cost
    }
}
