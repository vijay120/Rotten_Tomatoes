//
//  MovieDetailViewController.m
//  Rotten Tomatoes
//
//  Created by Vijay Ramakrishnan on 2/5/15.
//  Copyright (c) 2015 Vijay Ramakrishnan. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UITextView *movieSynopsis;
@property (weak, nonatomic) IBOutlet UIImageView *moviePoster;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat height =  [self.movieSynopsis.text sizeWithFont:self.movieSynopsis.font].height;
    self.scrollView.contentSize = CGSizeMake(320, height+300);
    
    NSString *lowResUrl = [self.movie valueForKeyPath:@"posters.thumbnail"];
    [self.moviePoster setImageWithURL:[NSURL URLWithString:lowResUrl]];
    
    NSString *highResUrl = [self.movie valueForKeyPath:@"posters.detailed"];
    highResUrl = [highResUrl stringByReplacingOccurrencesOfString:@"tmb" withString:@"ori"];
    [self.moviePoster setImageWithURL:[NSURL URLWithString: highResUrl] placeholderImage:self.moviePoster.image];
    
    self.movieTitle.text = [self.movie valueForKeyPath:@"title"];
    self.movieSynopsis.text = [self.movie valueForKeyPath:@"synopsis"];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
