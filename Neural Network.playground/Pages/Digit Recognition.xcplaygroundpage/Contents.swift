import UIKit
import PlaygroundSupport
/*:
 [Back to Fitting to Points](@previous)
 
 ## Handwritten Digit Recognition
 I have trained a neural network to recognize handwritten digits using a [large dataset](http://yann.lecun.com/exdb/mnist/). I have pre-trained the network because training the network on such a large dataset can take up to 30 minutes. The pre-trained weights and the images being displayed are being loaded from resource files.
 
 [Continue to Drawing Digits](@next)
 */
let mnistController = MNISTViewController()
let navigationController = UINavigationController(rootViewController: mnistController)
PlaygroundPage.current.liveView = navigationController
