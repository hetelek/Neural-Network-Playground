import Foundation
import UIKit
import PlaygroundSupport

let controller = ViewController()
PlaygroundPage.current.liveView = controller

for _ in 0..<1000 {
    controller.step()
}
