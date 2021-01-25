//
//  Model.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import Foundation

var privateForms = [Form]()
var developerForms = [Form]()

class Form: NSObject {
    var id: String?
    var title: String?
    var creationTimestamp: NSNumber?
    var numberOfResponse: Int?
}

var userDatas = [UserData]()

class UserData: NSObject {
    var uid: String?
    var name: String?
    var email: String?
}

var elementsDictionary = [String: Element]()

var elements = [Element]()

class Element: NSObject {
    var id: String?
    var title: String?
    var dataType: String?
    var seqNo: String?
    var color: String?
}

var elementMenus = [ElementMenu]()

class ElementMenu: NSObject {
    var element: String?
    var selectedOption: String?
}

var responseElementsDictionary = [String: ResponseElement]()

var responseElements = [ResponseElement]()

class ResponseElement: NSObject {
    var id: String?
    var title: String?
    var dataType: String?
    var seqNo: String?
    var color: String?
    var response: String?
    var responses: [String]?
}

var fillElementsDictionary = [String: FillElement]()

var fillElements = [FillElement]()

class FillElement: NSObject {
    var id: String?
    var title: String?
    var dataType: String?
    var seqNo: String?
    var color: String?
    var response: String?
    var responses: [String]?
}

var developerMenus = [DeveloperMenu]()

class DeveloperMenu: NSObject {
    var id: String?
    var title: String?
}

var userResponseLists = [UserResponseList]()

class UserResponseList: NSObject {
    var id: String?
    var name: String?
    var email: String?
}

var userResponses = [UserResponse]()

class UserResponse: NSObject {
    var title: String?
    var response: String?
}


