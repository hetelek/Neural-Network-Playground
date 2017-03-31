import UIKit
import PlaygroundSupport
/*:
 [Back to Handwritten Digit Recognition](@previous)
 
 ## Drawing Digits
 
 **Goal:** Draw a digit and have our network guess what it is.
 
 Here you can try drawing your own digits and see how the network performs. You can see that it's not perfect, but works quite well for being so simple. If we were to use more advanced neural network techniques, we could bring the accuracy up to near-human performance.
 
 Keep in mind that the network is making guesses based on its training data. The images on the [previous page](@previous) give a good representation of the training data. The closer your drawings look to those, the better the network's guesses will get.
 
 **For the best performance, make sure the digit is centered and a reasonable size.**
 
 ---
 
 If you'd like to learn the basics of how the network is created, check out the [next page](@next) (**optional**).
 */

let drawingController = DrawingViewController()
let navigationController = UINavigationController(rootViewController: drawingController)
PlaygroundPage.current.liveView = navigationController
