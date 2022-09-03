//
//  CommentTableViewCell.swift
//  Joopel
//
//  Created by Яков Левен on 15.08.2022.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    static let identifier = "CommentTableViewCell"
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    // init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(avatarImageView)
        contentView.addSubview(commentLabel)
        contentView.addSubview(dateLabel )
        
        
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commentLabel.sizeToFit()
        dateLabel.sizeToFit()
        
        // Asign frames
        
        let imageSize: CGFloat = 40
        avatarImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        
        
        let commentLabelHeight = min(contentView.height - dateLabel.top, commentLabel.height)
        
        commentLabel.frame = CGRect(x: avatarImageView.right + 10,
                                    y: 5,
                                    width: contentView.width - avatarImageView.height - 10,
                                    height: commentLabelHeight
        )
        
        dateLabel.frame = CGRect(x: avatarImageView.right + 10,
                                 y: commentLabel.bottom,
                                 width: dateLabel.width,
                                 height: dateLabel.height
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        avatarImageView.image = nil
        commentLabel .text = nil
    }
    
    public func configure(with model: PostComment){
        commentLabel.text = model.text
        dateLabel.text = .date(with: model.date)
        if let url = model.user.profilePictureURL{
            print(url)
        }
        else {
            avatarImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
