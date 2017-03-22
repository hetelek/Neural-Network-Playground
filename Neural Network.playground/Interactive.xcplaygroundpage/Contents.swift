import UIKit
import PlaygroundSupport

class InteractiveViewController: UIViewController, InteractiveGraphDelegate {
    private var graph: InteractiveGraph = {
        let graph = InteractiveGraph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        return graph
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        view.addSubview(graph)
        
        graph.delegate = self
        NSLayoutConstraint.activate([
            graph.leftAnchor.constraint(equalTo: view.leftAnchor),
            graph.rightAnchor.constraint(equalTo: view.rightAnchor),
            graph.topAnchor.constraint(equalTo: view.topAnchor),
            graph.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
        ])
        
        graph.setNeedsDisplay()
        view.setNeedsLayout()
    }
    
    func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint) {
        print("new point: \(newPoint)")
    }
}

let interactiveController = UIView()
PlaygroundPage.current.liveView = interactiveController
