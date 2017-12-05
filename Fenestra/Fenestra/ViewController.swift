//
//  ViewController.swift
//  CIKernel
//
//  Created by Andrew Jay Zhou on 10/11/17.
//  Copyright © 2017 Andrew Jay Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()
    var imageView3 = UIImageView()
    var imageView4 = UIImageView()
    var imageView5 = UIImageView()
    var imageView6 = UIImageView()
    var image : CIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize image
        image = CIImage(image: UIImage.init(named: "butterfly")!)
//        image = rgb2gray(inputImage: image!)
        
        // setup ImageView
        let container1 = UIStackView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3))
        container1.axis = .horizontal
        container1.addArrangedSubview(imageView1)
        container1.addArrangedSubview(imageView2)
        container1.distribution = .fillEqually
        let container2 = UIStackView.init(frame: CGRect(x: 0 , y: UIScreen.main.bounds.height / 3, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3))
        container2.axis = .horizontal
        container2.addArrangedSubview(imageView3)
        container2.addArrangedSubview(imageView4)
        container2.distribution = .fillEqually
        let container3 = UIStackView.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height / 3 * 2, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3))
        container3.axis = .horizontal
        container3.addArrangedSubview(imageView5)
        container3.addArrangedSubview(imageView6)
        container3.distribution = .fillEqually
        view.addSubview(container1)
        view.addSubview(container2)
        view.addSubview(container3)

        imageView1.contentMode = .scaleAspectFit
        imageView2.contentMode = .scaleAspectFit
        imageView3.contentMode = .scaleAspectFit
        imageView4.contentMode = .scaleAspectFit
        imageView5.contentMode = .scaleAspectFit
        imageView6.contentMode = .scaleAspectFit
        
        // setup Tap
        setupTap()
        
        // Display Original Image
//        imageView1.image =  UIImage(ciImage: rgb2gray(inputImage:image!))
        imageView1.image = UIImage(ciImage: image!)
    
    }
    
    func setupTap() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        let context = CIContext()
        let kps = detectSIFT(inputImage: image!, sigma: 1.0, r: 10.0, numberOctave: 5)
        let kp  = convertCIImagetoCGImage(image: kps[0], context: context)
        saveAsPNG(image: kps[0], context: context)
        let locations = getKeypointLocationsFromImage(fromImage: kp)
        let locImg = drawLocationImage(locations: locations)
        print("------------------------")
        print(locations)
        let res = getKeypointLocationsFromImage(fromImage: convertCIImagetoCGImage(image: locImg, context: context))
//        saveAsPNG(image: locImg, context: context)
        
//        detectSIFTtest(inputImage: image!, sigma: 0.5, k: sqrt(2), r: 10.0, numberExtrema: 10)
// ------------------------------------------------------------------------------------------------
        
//        let k = 1.41421356237 // sqrt(2)
//        
//        // Stack of blurred images
//        let blurredImage1 = rgb2gray(inputImage: gaussianBlur(inputImage: image!, sigma: sigma))
//        let blurredImage2 = rgb2gray(inputImage: gaussianBlur(inputImage: image!, sigma: sigma * k))
//        let blurredImage3 = rgb2gray(inputImage: gaussianBlur(inputImage: image!, sigma: sigma * k * k))
//        let blurredImage4 = rgb2gray(inputImage: gaussianBlur(inputImage: image!, sigma: sigma * k * k * k))
//        let blurredImage5 = rgb2gray(inputImage: gaussianBlur(inputImage: image!, sigma: sigma * k * k * k * k))
////
//        let output = eliminateUnstableKeypoints(map: extrema[1], src: blurredImage3, hiImg: blurredImage4, hiHiImg: blurredImage5, loImg: blurredImage2, loLoImg: blurredImage1)
        
//        imageView1.image = UIImage.init(ciImage: output)

//        findPeakOrientation(inputKP: image!, inputMO: image!, inputSigma: 10)
        
//        let test = testKernel(image: image!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension UIView{
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}


