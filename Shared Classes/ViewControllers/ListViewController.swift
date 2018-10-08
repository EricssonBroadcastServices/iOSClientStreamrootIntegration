//
//  ListViewController.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-13.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit

protocol ListContent {
    var title: String { get }
    var type: String { get }
    var desc: String? { get }
}

struct ListItem: ListContent {
    let title: String
    let type: String
    let desc: String?
    
    init(title: String, type: String, desc: String? = nil) {
        self.title = title
        self.type = type
        self.desc = desc
    }
}

class ListViewController: UIViewController {

    var content: [ListContent] = []
    var onDidSelect: (ListContent) -> Void = { _ in }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
        // Do any additional setup after loading the view.
        
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = content[indexPath.row].title
        cell.detailTextLabel?.text = content[indexPath.row].desc
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onDidSelect(content[indexPath.row])
    }
}
