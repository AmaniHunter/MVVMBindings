//
//  ViewController.swift
//  MVVMBindings
//
//  Created by Amani Hunter on 5/1/21.
//

import UIKit
// Observable
    class Observable<T> {
        var value: T? {
            didSet{
                listener?(value)
            }
        }
        
        init(_ value: T?){
            self.value = value
        }
        
        private var listener: ((T?) -> Void)?
        
        func bind(_ listener: @escaping (T?) -> Void){
            listener(value)
            self.listener = listener
        }
    }
// Model
    struct User: Codable{
        let name: String
    }
// ViewModels
    struct UserListViewModel{
        var userViewModels: Observable<[UserTableViewCellViewModel]> = Observable([])
    }
    
    struct UserTableViewCellViewModel {
        let name: String
    }
// Controller
    
class ViewController: UIViewController, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,forCellReuseIdentifier: "Cell")
        return table
    }()
    
    private var viewModel = UserListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        viewModel.userViewModels.bind{ [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        fetchData()
    }

    func fetchData(){
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {return}
        let task = URLSession.shared.dataTask(with: url){ (data, _, _) in
            guard let data = data else {return}
            do{
                let userModels = try JSONDecoder().decode([User].self, from: data)
                self.viewModel.userViewModels.value = userModels.compactMap({
                    UserTableViewCellViewModel(name: $0.name)
                })
            }catch{
                
            }
        }
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userViewModels.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.userViewModels.value?[indexPath.row].name
        return cell
    }
    
    
}

