//
//  VC+SIFT.swift
//  Fenestra
//
//  Created by Andrew Jay Zhou on 10/29/17.
//  Copyright © 2017 Andrew Jay Zhou. All rights reserved.
//

import Foundation
import UIKit

// SIFT Detector functions
extension ViewController {
    // grayscale images
    func rgb2gray(inputImage: CIImage) -> CIImage {
        let grayscale = CIFilter(name: "rgb2gray")
        grayscale?.setValue(inputImage, forKey: kCIInputImageKey)
        return (grayscale?.outputImage)!
    }
    
    // downsample by factor of 2
    func downSampleBy2(inputImage: CIImage) -> CIImage {
        let halve = CIFilter(name: "halve")
        halve?.setValue(inputImage, forKey: kCIInputImageKey)
        return (halve?.outputImage)!
    }
    
    // Filter that gaussian blurs then downsample by 2
    // radius is the half-width of filter - default should be 3 * sigma 
    func applyGaussianFilter(inputImage: CIImage, sigma: Int) -> CGImage {
        let context = CIContext()
        
        // Gaussian Convolution
        let gaussian1X = CIFilter(name: "gaussian1X")
        gaussian1X?.setValue(inputImage, forKey: kCIInputImageKey)
        gaussian1X?.setValue(sigma, forKey: "inputSigma")
        let output1X = gaussian1X?.outputImage
        
        let gaussian1Y = CIFilter(name: "gaussian1Y")
        gaussian1Y?.setValue(output1X, forKey: kCIInputImageKey)
        gaussian1Y?.setValue(sigma, forKey: "inputSigma")
        let convolvedImg = gaussian1Y?.outputImage
        
        // Downsample to N/2
        let halve = CIFilter(name: "halve")
        halve?.setValue(convolvedImg, forKey: kCIInputImageKey)
        let output = halve?.outputImage
        
        return context.createCGImage(output!, from: (output!.extent))!
    }
    
    // Gaussian Blur
    func gaussianBlur(inputImage: CIImage, sigma: Double) -> CIImage {
        // Gaussian Convolution
        let gaussian1X = CIFilter(name: "gaussian1X")
        gaussian1X?.setValue(inputImage, forKey: kCIInputImageKey)
        gaussian1X?.setValue(sigma, forKey: "inputSigma")
        let output1X = gaussian1X?.outputImage
                
        let gaussian1Y = CIFilter(name: "gaussian1Y")
        gaussian1Y?.setValue(output1X, forKey: kCIInputImageKey)
        gaussian1Y?.setValue(sigma, forKey: "inputSigma")
        let convolvedImg = gaussian1Y?.outputImage

        return convolvedImg!
    }
    
    // Difference of Gaussian
    // inputImageHi has the higher sigma value 
    func diffOfGaussian(inputImageLo: CIImage, inputImageHi: CIImage) -> CIImage {
        let diff = CIFilter(name: "difference")
        diff?.setValue(inputImageLo, forKey: "inputImageLo")
        diff?.setValue(inputImageHi, forKey: "inputImageHi")
        guard let output = diff?.outputImage else {
            print("error with Difference of Gaussian Function")
            return inputImageLo
        }
        return output
    }
    
    // Detect local extrema in one octave
    func detectKeypoints(inputImage: CIImage, sigma: Double, r: Double)-> [CIImage]{
        var extrema = [CIImage]()
        let image = rgb2gray(inputImage: inputImage)
        let k = 1.41421356237 // sqrt(2)
        
        // Stack of blurred images
        let blurredImage1 = gaussianBlur(inputImage: image, sigma: sigma)
        let blurredImage2 = gaussianBlur(inputImage: image, sigma: sigma * k)
        let blurredImage3 = gaussianBlur(inputImage: image, sigma: sigma * k * k)
        let blurredImage4 = gaussianBlur(inputImage: image, sigma: sigma * k * k * k)
        let blurredImage5 = gaussianBlur(inputImage: image, sigma: sigma * k * k * k * k)
        
        // Stack of Difference of Gaussian images
        let diffGauss1 = diffOfGaussian(inputImageLo: blurredImage1, inputImageHi: blurredImage2)
        let diffGauss2 = diffOfGaussian(inputImageLo: blurredImage2, inputImageHi: blurredImage3)
        let diffGauss3 = diffOfGaussian(inputImageLo: blurredImage3, inputImageHi: blurredImage4)
        let diffGauss4 = diffOfGaussian(inputImageLo: blurredImage4, inputImageHi: blurredImage5)
        
        // Extrema extraction through comparison of 26(9+8+9) neighbors
        let comp26 = CIFilter(name: "extractExtrema")
        // First compare diffGauss1,2,3 | with diffGauss2 in the middle of stack
        comp26?.setValue(diffGauss2, forKey: "inputImage")
        comp26?.setValue(diffGauss1, forKey: "inputComparison1")
        comp26?.setValue(diffGauss3, forKey: "inputComparison2")
        comp26?.setValue(sigma * k, forKey: "inputSigma")
        let extrema1 = (comp26?.outputImage)!
        extrema.append(extrema1)
        
        // Next compare diffGauss2,3,4 | with diffGauss3 in the middle of stack
        comp26?.setValue(diffGauss3, forKey: "inputImage")
        comp26?.setValue(diffGauss2, forKey: "inputComparison1")
        comp26?.setValue(diffGauss4, forKey: "inputComparison2")
        comp26?.setValue(sigma * k * k * k, forKey: "inputSigma")
        let extrema2 = (comp26?.outputImage)!
        extrema.append(extrema2)
        
        // reject edges
        let edger = CIFilter(name: "edgeRejection")
        edger?.setValue(extrema1, forKey: "inputMap")
        edger?.setValue(diffGauss2, forKey: "inputImage")
        edger?.setValue(r, forKey: "inputThreshold")
        let kp1 = (edger?.outputImage)!
        
        edger?.setValue(extrema2, forKey: "inputMap")
        edger?.setValue(diffGauss3, forKey: "inputImage")
        edger?.setValue(r, forKey: "inputThreshold") 
        let kp2 = (edger?.outputImage)!
        
        // ImageView display
        let context = CIContext()
        imageView2.image = UIImage(cgImage: cg(image: extrema1, context: context))
        imageView3.image = UIImage(cgImage: cg(image: extrema2, context: context))
        imageView4.image = UIImage(cgImage: cg(image: kp1, context: context))
        imageView5.image = UIImage(cgImage: cg(image: kp2, context: context))
//        imageView6.image = UIImage(cgImage: cg(image: diffGauss4, context: context))
        
        
        // save images to photos
//        UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: cg(image: image, context: context)), nil, nil, nil)
//        UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: cg(image: extrema1, context: context)), nil, nil, nil)
        
        return extrema
    }
    
    // convert CIImage to CGImage
    func cg(image: CIImage, context: CIContext) -> CGImage{
        return context.createCGImage(image, from: image.extent)!
    }
    
    func findMagAndOri(image: CIImage) -> CIImage{
        let mNo = CIFilter(name: "magNori")
        mNo?.setValue(image, forKey: "inputImage")
        return (mNo?.outputImage)!
    }

}
