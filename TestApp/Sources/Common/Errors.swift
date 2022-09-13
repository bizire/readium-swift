//
//  Errors.swift
//  TestApp
//
//  Created by Andrei on 12.09.2022.
//

import UIKit

/*
 Convenience methods to display error messages.
 */

extension UIAlertController {
    class func errorAlert(message: String) -> UIAlertController {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return errorAlert
    }
}

