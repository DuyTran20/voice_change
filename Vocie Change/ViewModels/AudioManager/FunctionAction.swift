//
//  FetcherRecording .swift
//  Vocie Change
//
//  Created by Tran Duc Duy on 26/10/2022.
//

import Foundation
import AVFoundation
import UIKit
import Combine
import SwiftUI

class FunctionAction: ObservableObject{
 
    func  shared(url: URL){
        let av =  UIActivityViewController(activityItems: [url as Any], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        
        windowScene?.keyWindow?.rootViewController?.present(av, animated: true, completion: nil)
    }
    func getFileRealm(appenConponent: String) -> URL{
        let fm = FileManager.default
        let documentDirectory = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let url = documentDirectory.appendingPathComponent(appenConponent)
        return url
    }
    
    
    
}
extension Binding{
    func onChange(perform action: @escaping (Value) -> ()) -> Self where Value: Equatable {
      return .init(
        get: { self.wrappedValue },
        set: { newValue in
          let oldValue = self.wrappedValue
          self.wrappedValue = newValue
          if newValue != oldValue  {
            action(newValue)
          }
        }
      )
    }
    
    func asAnyPublisher() -> AnyPublisher<Value, Never> where Value: Equatable {
      let passthroughSubject = PassthroughSubject<Value, Never>()
      self.onChange{ value in
        passthroughSubject.send(value)
      }
      return passthroughSubject.eraseToAnyPublisher()
    }
}
