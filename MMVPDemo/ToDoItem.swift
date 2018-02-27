//
//  ToDoItem.swift
//  MMVPDemo
//
//  Created by hp ios on 2/27/18.
//  Copyright © 2018 andiosdev. All rights reserved.
//

import RealmSwift
class ToDoItem : Object
{
    @objc dynamic var toDoId:Int = 0
    @objc dynamic var toDoValue:String = ""
    @objc dynamic var isDone:Bool = false
    @objc dynamic var createdAt:Date? = Date()
    @objc dynamic var updateAt:Date?
    @objc dynamic var deletedAt:Date?
    
    override static func primaryKey() -> String?
    {
        return "toDoId"
    }
}
