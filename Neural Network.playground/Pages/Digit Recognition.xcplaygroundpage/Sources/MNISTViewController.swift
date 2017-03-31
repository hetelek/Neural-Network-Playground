import UIKit

public class MNISTViewController: UIViewController {
    // MARK: - Private properties
    private let mnist: MNIST = {
        let url = Bundle.main.url(forResource: "t10k-images-idx3-ubyte", withExtension: nil)!
        return MNIST(url: url)!
    }()
    private let mnistNetwork: Network = {
        let url = Bundle.main.url(forResource: "mnist-network-weights", withExtension: nil)!
        return Network(url: url)
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private let predictionLabel: UILabel = {
        let predictionLabel = UILabel()
        predictionLabel.translatesAutoresizingMaskIntoConstraints = false
        predictionLabel.textAlignment = .center
        return predictionLabel
    }()
    
    
    // MARK: - View Controller Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // main view setup
        title = "Handwritten Digit Recognition"
        view.backgroundColor = .white
        
        // image view setup (allow tapping to move to next image)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(makeNewPrediction))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // prediction label setup
        view.addSubview(predictionLabel)
        NSLayoutConstraint.activate([
            predictionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            predictionLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -10)
        ])
        
        // next image button setup
        let button = UIButton(type: .system)
        button.setTitle("Next Image", for: .normal)
        button.addTarget(self, action: #selector(makeNewPrediction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        // make the first prediction
        makeNewPrediction()
    }
    
    
    // MARK: - Button actions
    @objc private func makeNewPrediction() {
        // get an image and it's pixel intensities using MNIST object
        let (pixelIntensities, image) = mnist.getImage()
        imageView.image = image
        
        // get network's prediction
        let (_, output, _) = mnistNetwork.feed(inputs: pixelIntensities).max()
        predictionLabel.text = "The network thinks this is \(output)."
    }
}
