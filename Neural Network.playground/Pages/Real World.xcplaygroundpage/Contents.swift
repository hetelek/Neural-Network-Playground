import Foundation
import PlaygroundSupport
import UIKit

let url = Bundle.main.url(forResource: "t10k-images-idx3-ubyte", withExtension: nil)!
let mnist = MNIST(url: url)!

let imageView = UIImageView(image: mnist.getImage())
PlaygroundPage.current.liveView = imageView