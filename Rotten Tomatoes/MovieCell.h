//
//  MovieCell.h
//  Rotten Tomatoes
//
//  Created by Vijay Ramakrishnan on 2/4/15.
//  Copyright (c) 2015 Vijay Ramakrishnan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (weak, nonatomic) IBOutlet UILabel *runtime;
@property (weak, nonatomic) IBOutlet UILabel *criticRating;
@property (weak, nonatomic) IBOutlet UILabel *peopleRating;
@property (weak, nonatomic) IBOutlet UILabel *cast;



@end
