import Foundation
import UIKit
import PlaygroundSupport

let costView = NetworkCostView(frame: CGRect(x: 0, y: 0, width: 600, height: 500))

let stepCount = 1000
for _ in 0..<stepCount {
    costView.step()
}

for index in 0..<costView.inputs.count {
    let input = costView.inputs[index]
    let output = costView.outputs[index][0]
    
    let got = costView.network.feed(inputs: input)[0][0]
    print("got \(got), expected \(output)")
}

PlaygroundPage.current.liveView = costView
