import UIKit
import PlaygroundSupport

let interactiveController = InteractiveViewController()
interactiveController.network = Network(inputs: 1, structure: [15, 5, 1])

let navigationController = UINavigationController(rootViewController: interactiveController)
PlaygroundPage.current.liveView = navigationController
