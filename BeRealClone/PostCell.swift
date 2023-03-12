//
//  CustomTableViewCell.swift
//  BeRealClone
//
//  Created by mohamad amroush.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
   
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentText: UITextField!
    
    private var imageDataRequest: DataRequest?
    var postId: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postId?.comments?.count ?? 0
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        cell.textLabel?.text = postId?.comments?[indexPath.row]
        print("PostId", postId!)
        print("Comments", postId?.comments)
        return cell
    }
    
    func formatDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func configure(with post: Post) {
        postId = post
        // Username
        if let user = post.user {
            if (post.location != nil){
                usernameLabel.text = user.username! + " is in " + post.location!
            }else{
                usernameLabel.text = user.username
            }
            //Profile
            if let profileImage = user.image,
               let imageUrl = profileImage.url {
                print("Profile", imageUrl)
                // Use AlamofireImage helper to fetch remote image from URL
                imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                    switch response.result {
                    case .success(let image):
                        // Set image view image with fetched image
                        self?.profileImageView.image = image
                    case .failure(let error):
                        print("❌❌ Error fetching image: \(error.localizedDescription)")
                        break
                    }
                }
            }
        }
        
        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            print("Post", imageUrl)
            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }

        // Caption
        captionLabel.text = post.caption

        // Date
//        print("❌", post.createdAt)
//        if let date = post.createdAt {
//            dateLabel.text = DateFormatter.postFormatter.string(from: date)
//        }
        let dateString = formatDateString(post.createdAt!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
//            print(formattedDate)
        }
        // A lot of the following returns optional values so we'll unwrap them all together in one big `if let`
        // Get the current user.
        if let currentUser = User.current,

            // Get the date the user last shared a post (cast to Date).
           let lastPostedDate = currentUser.lastPostedDate,

            // Get the date the given post was created.
           let postCreatedDate = post.createdAt,

            // Get the difference in hours between when the given post was created and the current user last posted.
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {

            // Hide the blur view if the given post was created within 24 hours of the current user's last post. (before or after)
            blurView.isHidden = abs(diffHours) < 24
        } else {

            // Default to blur if we can't get or compute the date's above for some reason.
            blurView.isHidden = false
        }


    }
    
    
    @IBAction func didTapComment(_ sender: Any) {
        print("Tap", postId!)
        guard var postId = postId,
          let commentText = commentText.text else { return }
        // Create a new Comment object with the comment text and current user.
        guard let currentUser = User.current else { return }
        if postId.comments != nil{
            postId.comments?.append("\(currentUser.username ?? ""): \(commentText)")

        } else{
            postId.comments = ["\(currentUser.username ?? ""): \(commentText)"]
        }
//        postId.comments?.append("\(String(describing: currentUser.username)): \(commentText)")
        
        // Clear the comment text field.
//        commentText.text = ""
        postId.save{[weak self] result in
            switch result {
            case .success(let user):
                print("✅ Comment Saved! \(user)")

            case .failure(_):
                print("Error")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset image view image.
        postImageView.image = nil

        // Cancel image request.
        imageDataRequest?.cancel()

    }
    
}
extension DateFormatter {
    static let postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
