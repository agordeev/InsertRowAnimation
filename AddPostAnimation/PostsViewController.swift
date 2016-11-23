//
//  ViewController.swift
//  AddPostAnimation
//
//  Created by Andrey Gordeev on 11/22/16.
//  Copyright © 2016 Andrey Gordeev (andrew8712@gmail.com). All rights reserved.
//

import UIKit

struct Post {
    var text = ""
    var image: UIImage?
}

class PostsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()

    /// If true, willDisplayCell method will tell the first cell to animate in.
    /// Used in prependPostWithAnimation method.
    var shouldAnimateFirstRow = false

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        fillDataSource()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
    }

    // MARK: - Logic

    private func fillDataSource() {
        for i in 1..<5 {
            var post = Post()
            post.text = "Test post \(i)"
            post.image = UIImage(named: "image\(i)")
            posts.append(post)
        }
        tableView.reloadData()
    }

    fileprivate func animateIn(cell: UITableViewCell, withDelay delay: TimeInterval) {
        let initialScale: CGFloat = 1.2
        let duration: TimeInterval = 0.5

        cell.alpha = 0.0
        cell.layer.transform = CATransform3DMakeScale(initialScale, initialScale, 1)
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }, completion: nil)
    }

    // MARK: - Animation

    private func prependPostWithAnimation(post: Post) {
        let animationDuration = 0.9
        // http://easings.net/#easeOutCirc
        let easeOutCirc = CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.0, 1)

        UIView.beginAnimations("addRow", context: nil)
        UIView.setAnimationDuration(animationDuration)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(easeOutCirc)

        tableView.beginUpdates()
        posts.insert(post, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
        shouldAnimateFirstRow = true
        tableView.endUpdates()

        CATransaction.commit()
        UIView.commitAnimations()
    }

    // MARK: - IBActions
    
    @IBAction func newPostButtonPressed(_ sender: UIBarButtonItem) {
        var post = Post()
        post.text = "New post"
        post.image = #imageLiteral(resourceName: "image4")
        prependPostWithAnimation(post: post)
    }

}

// MARK: - UITableViewDataSource
extension PostsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)

        let post = posts[indexPath.row]
        if let label = cell.viewWithTag(101) as? UILabel {
            label.text = post.text
        }
        if let imageView = cell.viewWithTag(102) as? UIImageView {
            imageView.image = post.image
            if let image = post.image {
                let constraint = imageView.constraints.first(where: { $0.identifier == "imageViewHeight" })
                constraint?.constant = UIScreen.main.bounds.width * image.size.height / image.size.width
            }
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension PostsViewController: UITableViewDelegate {

func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == 0 && shouldAnimateFirstRow {
        animateIn(cell: cell, withDelay: 0.7)
        shouldAnimateFirstRow = false
    }
}
    
}

