//
//  ToDoModel.swift
//  MMVPDemo
//
//  Created by hp ios on 2/24/18.
//  Copyright © 2018 andiosdev. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

protocol ToDoMenuItemViewPresentable {
    var title : String? {get set}
    var backColor : String? {get}
}
protocol ToDoMenuItemViewDelegate
{
    func onMenuItemSelected()->()
    
}
class ToDoMenuItemViewModel:ToDoMenuItemViewPresentable,ToDoMenuItemViewDelegate
{
    var title: String?
    var backColor: String?
    weak var parent : ToDoItemViewDelegate?
    
    init(parentViewModel: ToDoItemViewDelegate)
    {
        self.parent = parentViewModel
    }
    func onMenuItemSelected() {
        
    }
}
class RemoveMenuItemToDo: ToDoMenuItemViewModel {

    override func onMenuItemSelected()
    {
        parent?.onRemoveSelected()
        
    }
}
class DoneMenuItemToDo:ToDoMenuItemViewModel
{
    override func onMenuItemSelected()
    {
        parent?.onDoneSelected()
    }
  
}

protocol ToDoItemViewDelegate:class
{
    func goToDoItemAdded()->(Void)
    func onRemoveSelected()->(Void)
    func onDoneSelected()->(Void)
    
}
protocol ToDoViewDelegate:class
{
    func onAddItem() ->(Void)
    func onRemoveSelected(toDoItem:String)->(Void)
    func onDoneSelected(toDoItem:String)->(Void)
    
}

protocol ItemS
{
    var newValue:String?{get}
}
protocol ToDoItemPresentable
{
    var id:String? { get }
    var textValue:String? { get }
    var isDone:Bool?{get set}
    var menuItems:[ToDoMenuItemViewPresentable]?{ get }
    
}

class TodoItemViewModel:ToDoItemPresentable
{
    var menuItems: [ToDoMenuItemViewPresentable]?=[]
    var isDone: Bool? = false
    var id:String? = "0"
    var textValue:String?
    weak var parent:ToDoViewDelegate?
    
    init(id1:String?,textVal:String?,parentViewModel:ToDoViewDelegate)
    {
        self.id = id1
        self.textValue = textVal
        parent=parentViewModel
      
        let removeMenuItem = RemoveMenuItemToDo(parentViewModel: self as ToDoItemViewDelegate)
        removeMenuItem.title="Remove"
        removeMenuItem.backColor="ff0000"
        
        let DoneMenuItem = DoneMenuItemToDo(parentViewModel: self as ToDoItemViewDelegate)
        DoneMenuItem.title =  isDone! ? "UnDone" : "Done"
        DoneMenuItem.backColor="00ff00"
        
        menuItems?.append(contentsOf:[removeMenuItem,DoneMenuItem])
        
       
        
    }
}
extension TodoItemViewModel:ToDoItemViewDelegate
{
    /*
     * @Discussion onItem selected Received in view model from didSelectRowAt
     * @params id
     * @return Void
     */
    func goToDoItemAdded() {
        
    }
    
    func onRemoveSelected() {
        parent?.onRemoveSelected(toDoItem: id!)
    }
    
    func onDoneSelected() {
        parent?.onDoneSelected(toDoItem: id!)
    }
    
}

class ToDoModel:ItemS
    
{
    var newValue: String?
    var items : Variable<[ToDoItemPresentable]> = Variable([])
    var database:Database?
    var notificationToken:NotificationToken? = nil

    init()
    {
        database = Database.singletone
        let toDoItemsResults = database?.fetch()
        notificationToken = toDoItemsResults?.observe({ [weak self](changes:RealmCollectionChange) in
            
            switch(changes)
            {
            case .initial:
                
                toDoItemsResults?.forEach({ (ToDoItemEntity) in
                    
                    let todoItem = ToDoItemEntity
                    
                    let itemIndex = todoItem.toDoId
                    let newValueOfItem = todoItem.toDoValue
                    
                    let newItem=TodoItemViewModel(id1: "\(itemIndex)", textVal:newValueOfItem,parentViewModel:self!)
                    self?.items.value.append(newItem)
                    
                 })
                
                break
            case .update(_,let deletions,let insertions,let modifications):
                
                insertions.forEach({ (index) in
                   
                    let todoItem = toDoItemsResults![index]
                    
                    let itemIndex = todoItem.toDoId
                    let newValueOfItem = todoItem.toDoValue
                    
                    let newItem=TodoItemViewModel(id1: "\(itemIndex)", textVal:newValueOfItem,parentViewModel:self!)
                    self?.items.value.append(newItem)
                 })
                
                modifications.forEach({ (index) in
                    
                    let todoItemEntity = toDoItemsResults![index]
                 
                    guard let index = self?.items.value.index(where: { Int($0.id!) == todoItemEntity.toDoId})
                        else { return }
                   
                    if todoItemEntity.deletedAt != nil
                    {
                         self?.items.value.remove(at: index)
                         self?.database?.delete(primaryKey: todoItemEntity.toDoId)
                    }
                    else
                    {
                        var toDoItemMo = self?.items.value[index]
                        
                        toDoItemMo?.isDone = todoItemEntity.isDone
                        
                        if var doneMenuItem = toDoItemMo?.menuItems?.filter({ (toDoMenuItem) -> Bool in
                            toDoMenuItem is DoneMenuItemToDo
                        }).first
                        {
                            doneMenuItem.title = todoItemEntity.isDone ? "UnDone" : "Done"
                        }
                    }
                    
                   
                    
                    
                })
                
                
                 break
                
            case .error(let error):
                 break
                
            }
            
            self?.items.value.sort(by:
                {
                    if !($0.isDone!) && !($1.isDone!)
                    {
                        return $0.id! < $1.id!
                    }
                    if $0.isDone! && $1.isDone!
                    {
                        return $0.id! < $1.id!
                    }
                    return !($0.isDone!) && $1.isDone!
               })
        })
    }
    deinit {
        notificationToken?.invalidate()
    }
 }


extension ToDoModel:ToDoViewDelegate
{
    func onAddItem() {
        guard let newValueOfItem = newValue else  {return }
        database?.createOrUpdate(toDoItemUpdate: newValueOfItem)
        self.newValue=""
        
    }
    
    func onRemoveSelected(toDoItem: String) {
        database?.softDelete(primarykey: Int(toDoItem)!)
       
    }
    
    func onDoneSelected(toDoItem: String) {
       
        database?.isDone(primaryKey:Int(toDoItem)!)
        
    }
    
  

}




