//
//  UIViewController+Extensions.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-14.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showMessage(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        #if DEBUG
        print(message)
        #endif
        let alertController = UIAlertController(title: title, message: message, preferredStyle:UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: handler))
        self.present(alertController, animated: true, completion: nil)
    }
}
