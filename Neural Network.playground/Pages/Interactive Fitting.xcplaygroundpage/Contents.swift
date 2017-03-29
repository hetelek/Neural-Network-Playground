import UIKit
import PlaygroundSupport
/*:
 [Back to Constructing a Neural Network](@previous)
 
 ## Fitting to Points
 
 Try plotting a few points by tapping the white area. Once you have a few points plotted, hit train a couple times to see how the network "learns" to fit those points. As you add points, the amount of training needed will increase.
 
 Try changing the learning rate to see how it affects the network's learning:
 */
let learningRate: Double = 15

/*:
 [Continue to Digit Recognition](@next)
 */
// Our network takes 1 input, has 2 hidden layers (15 hidden neurons first, then 5 hidden neurons), and outputs 1 value.
let network = Network(inputs: 1, structure: [15, 5, 1])

// Setup the view.
let interactiveController = InteractiveViewController()
interactiveController.network = network
interactiveController.η = learningRate

let navigationController = UINavigationController(rootViewController: interactiveController)
PlaygroundPage.current.liveView = navigationController
