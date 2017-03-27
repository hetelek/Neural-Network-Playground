import PlaygroundSupport
import UIKit


/*:
 I have trained a neural network to recognize handwritten digits using a [large dataset](http://yann.lecun.com/exdb/mnist/). I have pre-trained the network becuase training the network on such a large dataset can take lots of time. The pre-trained weights and the images being displayed are being loaded from resource files.
 */
let mnistController = MNISTViewController()
let navigationController = UINavigationController(rootViewController: mnistController)
PlaygroundPage.current.liveView = navigationController
