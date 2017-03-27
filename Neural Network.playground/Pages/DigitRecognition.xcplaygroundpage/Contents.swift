import PlaygroundSupport
import UIKit

let mnistController = MNISTViewController()
let navigationController = UINavigationController(rootViewController: mnistController)
PlaygroundPage.current.liveView = navigationController
