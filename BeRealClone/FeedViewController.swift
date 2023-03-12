//
//  FeedViewController.swift
//  BeRealClone
//
//  Created by mohamad amroush.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tapLogOutButton(_ sender: Any) {
        User.logout { [weak self] result in

            switch result {
            case .success:

                // Make sure UI updates are done on main thread when initiated from background thread.
                DispatchQueue.main.async {
                    // Unregister for notifications when the user logs out
                    let center = UNUserNotificationCenter.current()
                    center.removeAllPendingNotificationRequests()
                    center.removeAllDeliveredNotifications()

                    // Instantiate the LoginViewController from the storyboard
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
//                    let navigationController = UINavigationController(rootViewController: loginViewController)
                    
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "loginNav") as! UINavigationController
                    navigationController.viewControllers = [storyboard.instantiateViewController(withIdentifier: "LoginViewController")]
//                    self.window?.rootViewController = navigationController
                    
                    // Present the LoginViewController modally
                    navigationController.modalPresentationStyle = .fullScreen
                    self?.present(navigationController, animated: true, completion: nil)
//                    self?.window?.rootViewController = viewController
                    self?.navigationController?.setViewControllers([], animated: false)
                }
            case .failure(let error):
                print("❌ Log out error: \(error)")
            }
        }

    }
    
    private var posts = [Post]() {
        didSet {
            // Reload table view data any time the posts variable gets updated.
            tableView.reloadData()
        }
    }
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        self.tableView.rowHeight = 500;
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
        
        
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshFeed(send: UIRefreshControl) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        queryCsomments()
        queryPosts()
    }
    
//    private func queryComments() {
//        // 1. Create a query to fetch Posts
//        // 2. Any properties that are Parse objects are stored by reference in Parse DB and as such need to explicitly use `include_:)` to be included in query results.
//        // 3. Sort the posts by descending order based on the created at date
//        let query = Comment.query()
//            .include("user")
//            .order([.descending("createdAt")])
//            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
//            .limit(10) // <- Limit max number of returned posts to 10
//
//        // Fetch objects (posts) defined in query (async)
//        query.find { [weak self] result in
//            switch result {
//            case .success(let posts):
//                // Update local posts property with fetched posts
//                self?.posts = posts
//            case .failure(let error):
//                self?.showAlert(description: error.localizedDescription)
//            }
//        }
//    }

    
    private func queryPosts() {
        // 1. Create a query to fetch Posts
        // 2. Any properties that are Parse objects are stored by reference in Parse DB and as such need to explicitly use `include_:)` to be included in query results.
        // 3. Sort the posts by descending order based on the created at date
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
//            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
        
        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update local posts property with fetched posts
                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}
