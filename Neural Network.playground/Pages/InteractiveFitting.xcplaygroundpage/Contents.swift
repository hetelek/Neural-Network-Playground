import UIKit
import PlaygroundSupport
/*:
 [Back to Constructing a Neural Network](@previous)
 
 ## Fitting to Points
 
 Try plotting a few points by tapping the white area. Once you have a few points plotted, hit train a few times to see how the network "learns" how to fit those points. As you add points, the amount of training will also increase.
 
 Try changing the learning rate to see how it affects the network's learning:
 */
let learningRate: Double = 15

/*:
 [Continue to Digit Recognition](@next)
 */
let interactiveController = InteractiveViewController()
interactiveController.network = Network(inputs: 1, structure: [15, 5, 1])
interactiveController.η = learningRate

let navigationController = UINavigationController(rootViewController: interactiveController)
PlaygroundPage.current.liveView = navigationController
