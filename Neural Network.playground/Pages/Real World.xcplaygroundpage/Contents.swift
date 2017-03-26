import Foundation
import PlaygroundSupport
import UIKit

let url = Bundle.main.url(forResource: "t10k-images-idx3-ubyte", withExtension: nil)!
let mnist = MNIST(url: url)!

let (intensity, image) = mnist.getImage()
let imageView = UIImageView(image: image)
PlaygroundPage.current.liveView = imageView

let url2 = Bundle.main.url(forResource: "mnist-network-weights", withExtension: nil)!

let network = Network(url: url2)
let results = network.feed(inputs: intensity)

var maxValueIndex = -1
var maxValue: Double = 0
for row in 0..<results.rows {
    let value = results[row][0]
    if value > maxValue {
        maxValue = value
        maxValueIndex = row
    }
}

print("I think this is a \(maxValueIndex).")