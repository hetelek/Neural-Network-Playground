import UIKit
import PlaygroundSupport

class InteractiveViewController: UIViewController, InteractiveGraphDelegate {
    private var graph: InteractiveGraph = {
        let graph = InteractiveGraph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        return graph
    }()
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(graph)
        setupInteractiveGraph()
    }
    
    // MARK: - Interactive graph logic
    private func setupInteractiveGraph() {
        // set delegate and create constraints
        graph.delegate = self
        NSLayoutConstraint.activate([
            graph.leftAnchor.constraint(equalTo: view.leftAnchor),
            graph.rightAnchor.constraint(equalTo: view.rightAnchor),
            graph.topAnchor.constraint(equalTo: view.topAnchor),
            graph.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
        ])
        graph.setNeedsDisplay()
    }
    
    // MARK: - InteractiveGraphDelegate
    func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint) {
        print("new point: \(newPoint)")
    }
}

let interactiveController = InteractiveViewController()
PlaygroundPage.current.liveView = interactiveController
