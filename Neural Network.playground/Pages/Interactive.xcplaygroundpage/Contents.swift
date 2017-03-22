import UIKit
import PlaygroundSupport

public class InteractiveViewController: UIViewController, InteractiveGraphDelegate {
    private var graph: InteractiveGraph = {
        let graph = InteractiveGraph()
        graph.translatesAutoresizingMaskIntoConstraints = false
        return graph
    }()
    
    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Interactive View"
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
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
            graph.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            graph.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ])
        graph.setNeedsDisplay()
    }
    
    // MARK: - InteractiveGraphDelegate
    public func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint) {
        print("new point: \(newPoint)")
        
        graph.continuousFunction = { sqrt($0) }
    }
}

let interactiveController = InteractiveViewController()
let navigationController = UINavigationController(rootViewController: interactiveController)
PlaygroundPage.current.liveView = navigationController
