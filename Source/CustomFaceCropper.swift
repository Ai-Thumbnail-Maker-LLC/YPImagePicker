// My Mood custom

import UIKit
import Vision

public enum FaceCropResult<T> {
  case success([T])
  case notFound
  case failure(Error)
}


public class FaceCropper {
  
    func mCrop(image : CGImage, _ completion: @escaping (FaceCropResult<CGImage>) -> Void) {
    
    guard #available(iOS 11.0, *) else {
      return
    }
    
      
    let req = VNDetectFaceRectanglesRequest { request, error in
      guard error == nil else {
        completion(.failure(error!))
        return
      }
      
      let faceImages = request.results?.map({ result -> CGImage? in
        guard let face = result as? VNFaceObservation else { return nil }
    
          

          if #available(iOS 15.0, *) {
              
              print("Found Face: \(face.yaw) \(face.roll) \(face.pitch)")
              if face.yaw?.floatValue ?? 0.0 > 0.610865 || face.yaw?.floatValue ?? 0.0 < -0.610865 || face.roll?.floatValue ?? 0.0 > 0.610865 || face.roll?.floatValue ?? 0.0 < -0.610865 || face.pitch?.floatValue ?? 0.0 > 0.610865 || face.pitch?.floatValue ?? 0.0 < -0.610865 {
                  
                  completion(.notFound)
                  print("Face failed")
                  return nil
              }
              
          } else {
              // Fallback on earlier versions
          }
        //let size = CGFloat( self.detectable.width)
          
        var width = face.boundingBox.width * CGFloat(image.width)
        var height = face.boundingBox.height * CGFloat(image.height)
        
          if face.boundingBox.height < 0.25 || face.boundingBox.width < 0.25 {
              completion(.notFound)
              print("Face too small")
            return nil
          }
          
//
        let offset =  (Double(image.width) / 2.0)
          var y = ((1 - face.boundingBox.midY) * CGFloat(image.height)) - offset
         
          
          if y < 0.0 {
              y = 0.0
          }
        
        let croppingRect = CGRect(x: 0.0, y: y, width: Double(image.width), height: Double(image.width))
        let faceImage = image.cropping(to: croppingRect)
        
          
          
        return faceImage
      }).flatMap { $0 }
      

        
      guard let result = faceImages, result.count > 0 else {
        completion(.notFound)
        return
      }
      
      completion(.success(result))
    }
      
      let landmarksRequest = VNDetectFaceLandmarksRequest { request, error in
          
            
          guard let face = request.results?.first as? VNFaceObservation else { return }

          if face.landmarks?.rightEye == nil || face.landmarks?.leftEye == nil {
              
              print("Eye not found")
              completion(.notFound)
              
          }
          
      }
    
    do {
      try VNImageRequestHandler(cgImage: image, options: [:]).perform([req, landmarksRequest])
    } catch let error {
      completion(.failure(error))
    }
  }

  
  
}
