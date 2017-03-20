import Foundation
import UIKit
import PlaygroundSupport

let controller = ViewController()
PlaygroundPage.current.liveView = controller

for _ in 0..<10000 {
    controller.step()
}

for index in 0..<controller.inputs.count {
    let inputs = controller.inputs[index]
    let outputs = controller.outputs[index]
    
    let got = controller.net.feed(inputs: inputs)
    print("got \(got), expected \(outputs)")
}
