import UIKit
import PlaygroundSupport
/*:
 [Back to Handwritten Digit Recognition](@previous)
 
 ## Drawing Digits
 Here you can try drawing your own digits and see how the network performs. You can see that it's not perfect, but works quite well for being so simple.
 
 Keep in mind that the network is making guesses based on its training data. The images on the [previous page](@previous) give a good representation of the training data. The closer your drawings look to those, the better the network's guesses will get.
 
 **For the best performance, make sure the digit fills the space and is centered.**
 
 ---
 
 If you'd like to learn the basics of how the network is created, check out the [next page](@next) (**optional**).
 */

let drawingController = DrawingViewController()
let navigationController = UINavigationController(rootViewController: drawingController)
PlaygroundPage.current.liveView = navigationController
