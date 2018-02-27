//
//  Database.swift
//  MMVPDemo
//
//  Created by hp ios on 2/27/18.
//  Copyright © 2018 andiosdev. All rights reserved.
//


import RealmSwift
class Database
{
    static let singletone = Database()
    
    private init()
    {
        
    }
    func createOrUpdate(toDoItemUpdate:String)->(Void)
    {
        let realm = try! Realm()
        
        var toDoId:Int? = 1
        
        if let lastEntity = realm.objects(ToDoItem.self).last
        {
            toDoId =  lastEntity.toDoId+1
        }
        
        let toDoItemEntity = ToDoItem()
        toDoItemEntity.toDoId = toDoId!
        toDoItemEntity.toDoValue = toDoItemUpdate
        
        try! realm.write {
            realm.add(toDoItemEntity,update:true)
        }
    }
    
    func softDelete(primarykey:Int)->(Void)
    {
        let realm = try! Realm()
        if let todoItemEntity = realm.object(ofType: ToDoItem.self, forPrimaryKey: primarykey)
        {
            try! realm.write {
                todoItemEntity.deletedAt = Date()
            }
        }
    }
    
    
    func fetch()->(Results<ToDoItem>)
    {
        let realm = try! Realm()
        let toDoItemResults = realm.objects(ToDoItem.self)
        return toDoItemResults
    }
    
    func delete(primaryKey:Int)->(Void)
    {
        let realm = try! Realm()
        if let todoItemEntity = realm.object(ofType: ToDoItem.self, forPrimaryKey: primaryKey)
        {
            try! realm.write {
                realm.delete(todoItemEntity)
            }
        }
    }
    func isDone(primaryKey:Int)->(Void)
    {
        let realm = try! Realm()
        if let todoItemEntity = realm.object(ofType: ToDoItem.self, forPrimaryKey: primaryKey)
        {
            try! realm.write {
                todoItemEntity.isDone = !todoItemEntity.isDone
            }
        }
    }
    
}












