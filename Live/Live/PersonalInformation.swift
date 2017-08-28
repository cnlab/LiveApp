//
//  PersonalInformation.swift
//  Live
//
//  Created by Denis Bohm on 1/4/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class PersonalInformation: JSONConvertable {

    let age: Int?
    let gender: String?
    let weight: Int?
    let weightPerception: String?
    let height: Int?
    let zipCode: String?
    let studyId: String?
    let comment: String?

    init(age: Int? = nil, gender: String? = nil, weight: Int? = nil, weightPerception: String? = nil, height: Int? = nil, zipCode: String? = nil, studyId: String? = nil, comment: String? = nil) {
        self.age = age
        self.gender = gender
        self.weight = weight
        self.weightPerception = weightPerception
        self.height = height
        self.zipCode = zipCode
        self.studyId = studyId
        self.comment = comment
    }

    required init(json: [String: Any]) throws {
        let age: Int? = try JSON.jsonOptionalInt(json: json, key: "age")
        let gender: String? = try JSON.jsonOptionalString(json: json, key: "gender")
        let weight: Int? = try JSON.jsonOptionalInt(json: json, key: "weight")
        let weightPerception: String? = try JSON.jsonOptionalString(json: json, key: "weightPerception")
        let height: Int? = try JSON.jsonOptionalInt(json: json, key: "height")
        let zipCode: String? = try JSON.jsonOptionalString(json: json, key: "zipCode")
        let studyId: String? = try JSON.jsonOptionalString(json: json, key: "studyId")
        let comment: String? = try JSON.jsonOptionalString(json: json, key: "comment")

        self.age = age
        self.gender = gender
        self.weight = weight
        self.weightPerception = weightPerception
        self.height = height
        self.zipCode = zipCode
        self.studyId = studyId
        self.comment = comment
    }

    func json() -> [String: Any] {
        var json: [String: Any] = [:]
        if let age = age {
            json["age"] = JSON.json(int: age)
        }
        if let gender = gender {
            json["gender"] = JSON.json(string: gender)
        }
        if let weight = weight {
            json["weight"] = JSON.json(int: weight)
        }
        if let weightPerception = weightPerception {
            json["weightPerception"] = JSON.json(string: weightPerception)
        }
        if let height = height {
            json["height"] = JSON.json(int: height)
        }
        if let zipCode = zipCode {
            json["zipCode"] = JSON.json(string: zipCode)
        }
        if let studyId = studyId {
            json["studyId"] = JSON.json(string: studyId)
        }
        if let comment = comment {
            json["comment"] = JSON.json(string: comment)
        }
        return json
    }

    func bySetting(age: Int? = nil, gender: String? = nil, weight: Int? = nil, weightPerception: String? = nil, height: Int? = nil, zipCode: String? = nil, studyId: String? = nil, comment: String? = nil) -> PersonalInformation {
        let newAge = age != nil ? age : self.age
        let newGender = gender != nil ? gender : self.gender
        let newWeight = weight != nil ? weight : self.weight
        let newWeightPerception = weightPerception != nil ? weightPerception : self.weightPerception
        let newHeight = height != nil ? height : self.height
        let newZipCode = zipCode != nil ? zipCode : self.zipCode
        let newStudyId = studyId != nil ? studyId : self.studyId
        let newComment = comment != nil ? comment : self.comment
        return PersonalInformation(age: newAge, gender: newGender, weight: newWeight, weightPerception: newWeightPerception, height: newHeight, zipCode: newZipCode, studyId: newStudyId, comment: newComment)
    }

}
