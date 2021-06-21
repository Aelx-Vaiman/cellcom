//
//  MainAPI.swift
//  cellcomTest
//
//  Created by Alex Vaiman on 21/06/2021.
//

import Foundation
import CoreLocation

protocol MainAPIResponseDelegate: AnyObject {
    func onBranchesResponse(data: Dictionary<String, AnyObject>?, error: Error?)
}


class MainAPI {
    weak var mainAPIResponseDelegate: MainAPIResponseDelegate?
    
    internal func getBranches(location: CLLocation) {
        
        guard let token = UserDefaults.standard.string(forKey: LoginViewController.savedTokenKey) else {
            let err = NSError(domain: "LoginApi", code: 401, userInfo: [ NSLocalizedDescriptionKey: "no valid token"])
            self.mainAPIResponseDelegate?.onBranchesResponse(data: nil, error: err)
            return
        }
        
        let url =  String(format: "https://c36raxna13.execute-api.us-east-1.amazonaws.com/test/api/branches?latitude=%f&longitude=%f&calcDistance=true",location.coordinate.latitude,location.coordinate.longitude).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
      
        var request = URLRequest(url: URL(string: url ?? "")!)
   
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue( String(format:"Bearer %@", token), forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                guard let code = response?.getStatusCode(), code == 200 else {
                    let err = NSError(domain: "LoginApi", code: 401, userInfo: [ NSLocalizedDescriptionKey: "failed get branches"])
                    DispatchQueue.main.async {
                        self.mainAPIResponseDelegate?.onBranchesResponse(data: nil, error: err)
                    }
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                DispatchQueue.main.async {
                    self.mainAPIResponseDelegate?.onBranchesResponse(data: json, error: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    let err = NSError(domain: "LoginApi", code: 401, userInfo: [ NSLocalizedDescriptionKey: "failed get branches"])
                    DispatchQueue.main.async {
                        self.mainAPIResponseDelegate?.onBranchesResponse(data: nil, error: err)
                    }
                }
            }
        })

        task.resume()
    }
    
  
}
