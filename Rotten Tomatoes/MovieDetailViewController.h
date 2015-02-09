//
//  MovieDetailViewController.h
//  Rotten Tomatoes
//
//  Created by Vijay Ramakrishnan on 2/5/15.
//  Copyright (c) 2015 Vijay Ramakrishnan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (weak, nonatomic) IBOutlet UITextView *synopsis;

@property (weak, nonatomic) NSArray *movie;

@end
