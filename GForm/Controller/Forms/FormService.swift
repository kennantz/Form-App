//
//  FormService.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 29/01/21.
//

import LBTAComponents
import Firebase

public func checkFormTitleAvailability(newtitle: String, type: String) -> Bool {
    
    var counter = 0
    
    if type == "Private" {
        
        for item in privateForms {
            if newtitle.lowercased() == item.title?.lowercased() {
                return false
            } else {
                counter += 1
                if counter == privateForms.count {
                    item.title = newtitle
                    return true
                }
            }
        }
        
    } else {
        
        for item in developerForms {
            if newtitle.lowercased() == item.title?.lowercased() {
                return false
            } else {
                counter += 1
                if counter == developerForms.count {
                    item.title = newtitle
                    return true
                }
            }
        }
        
    }
    
    return false
    
}
