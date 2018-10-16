//
//  ProfileViewController.swift
//  InstagramView
//
//  Created by ZJH on 2018/10/17.
//  Copyright © 2018年 ZJH. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class ProfileViewController: UICollectionViewController {
    
    var refresher: UIRefreshControl!
    var page: Int = 10
    var uuidArray = [String]()
    var pictureArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .white
        
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        loadPosts()
    }
    
    @objc func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    func loadPosts() {
        let query = PFQuery(className: "Post")
        query.whereKey("username", equalTo: PFUser.current()?.username!)
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.uuidArray.removeAll()
                self.pictureArray.removeAll()

                for object in objects! {
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.pictureArray.append(object.value(forKey: "picture") as! PFFile)
                }
                self.collectionView?.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeader", for: indexPath) as! ProfileHeaderView
        header.usernameLabel.text = PFUser.current()?.username!
        
        let photoQuery = PFUser.current()?.object(forKey: "profilePhoto") as! PFFile
        photoQuery.getDataInBackground { (data, error) in
            header.profilePhoto.image = UIImage(data: data!)
        }
        
        let posts = PFQuery(className: "Post")
        posts.whereKey("username", equalTo: PFUser.current()?.username!)
        posts.countObjectsInBackground { (count, error) in
            if error == nil {
                header.posts.text = "\(count)"
            }
        }
        
        let followers = PFQuery(className: "Follow")
        followers.whereKey("following", equalTo: PFUser.current()?.username!)
        followers.countObjectsInBackground { (count, error) in
            if error == nil {
                header.followers.text = "\(count)"
            }
        }
        
        let followings = PFQuery(className: "Follow")
        followings.whereKey("follower", equalTo: PFUser.current()?.username!)
        followings.countObjectsInBackground { (count, error) in
            if error == nil {
                header.followings.text = "\(count)"
            }
        }
        
        return header
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePictureCell", for: indexPath) as! ProfilePictureCell
        cell.frame.size.width = collectionView.frame.size.width / 3
        cell.frame.size.height = cell.frame.size.width
        pictureArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                cell.pictureImage.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        }
        
        return cell
    }
}
