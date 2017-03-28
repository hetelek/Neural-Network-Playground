import UIKit
import PlaygroundSupport

let drawingController = DrawingViewController()
let navigationController = UINavigationController(rootViewController: drawingController)
PlaygroundPage.current.liveView = navigationController
