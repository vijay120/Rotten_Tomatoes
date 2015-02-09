//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by Vijay Ramakrishnan on 2/3/15.
//  Copyright (c) 2015 Vijay Ramakrishnan. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailViewController.h"
#import "SVProgressHUD.h"

@interface MoviesViewController () <UITableViewDelegate,
                                    UITableViewDataSource,
                                    UISearchBarDelegate,
                                    UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (atomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UILabel *networkError;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *boxOfficeUrl;
@property (nonatomic, strong) NSString *dvdUrl;
@property (nonatomic, strong) NSString *selectedUrl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Rotten Tomatoes";
    self.boxOfficeUrl = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?limit=20&country=uk&apikey=36p5qjmqrj48pn3hv43awfcq";
    self.dvdUrl = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/current_releases.json?apikey=36p5qjmqrj48pn3hv43awfcq&page_limit=20";
    
    
    [self.networkError setHidden:YES];
    
    //[self.tabBar selectedItem]
    
    [SVProgressHUD show];
    
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.tabBar.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    self.tableView.rowHeight = 100;
    
    //Pull to refresh functionality
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    //default the first tab selection to be movies
    [self tabBar:self.tabBar didSelectItem:[self.tabBar.items objectAtIndex:0]];
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *movie = self.movies[indexPath.row];
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    cell.title.text = movie[@"title"];

    //Cast
    if ([movie[@"abridged_cast"] count] > 1){
        // we need atleast two cast members
        cell.cast.text = [NSString stringWithFormat:@"%@, %@", movie[@"abridged_cast"][0][@"name"], movie[@"abridged_cast"][1][@"name"]];
    } else {
        cell.cast.text = @"Cast not available";
    }
    
    // Ratings
    cell.criticRating.text = [NSString stringWithFormat:@"%@ ", [movie valueForKeyPath:@"ratings.critics_score"]];
    cell.peopleRating.text = [NSString stringWithFormat:@"%@ ", [movie valueForKeyPath:@"ratings.audience_score"]];
    
    //Runtime
    cell.runtime.text = [NSString stringWithFormat:@"%@ min", [movie valueForKeyPath:@"runtime"]];
    
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    //[cell.poster setImageWithURL:[NSURL URLWithString:url]];
    
    [cell.poster setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        //came from the network
        if ([response statusCode] != 0) {
            //animate only if its the first 5 entries since they make up the top of the list
            if (indexPath.row < 6) {
                cell.poster.alpha = 0.0;
                cell.poster.image = image;
                [UIView animateWithDuration:0.40
                                 animations:^{
                                     cell.poster.alpha = 1.0;
                                 }];
            } else {
                //failure case
            }
        }
        
        cell.poster.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //
    }];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailViewController *vc = [[MovieDetailViewController alloc] init];
    vc.movie = self.movies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Search bar stuff

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        NSString* rootSearchUrl = @"http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=36p5qjmqrj48pn3hv43awfcq";
        NSString* searchParam = [@"&q=" stringByAppendingString:searchText];
        NSString* pageLimit = @"&page_limit=10";
        NSString* finalUrl = [[rootSearchUrl stringByAppendingString:searchParam] stringByAppendingString:pageLimit];
        [self fetchAndDownloadURLAndDisplayLoadingSymbol:finalUrl];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.tableView.allowsSelection = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text=@"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    [self fetchAndDownloadURLAndDisplayLoadingSymbol:self.selectedUrl];
    self.tableView.allowsSelection = YES;
}

#pragma mark - Network methods

- (void) fetchAndDownloadURLAndDisplayLoadingSymbol:(NSString*) urlArg {
    NSURL *url = [NSURL URLWithString:urlArg];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == NULL) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            self.movies = responseDictionary[@"movies"];
            [self.networkError setHidden:YES];
            [self.tableView reloadData];
        } else {
            [self.networkError setHidden:NO];
        }
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
    }];
}

- (void)onRefresh {
    [self fetchAndDownloadURLAndDisplayLoadingSymbol:self.selectedUrl];
}

#pragma mark - TabBar

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if (item.tag == 0) {
        // Movie category
        self.selectedUrl = self.boxOfficeUrl;
    } else {
        // DVD category
        self.selectedUrl = self.dvdUrl;
    }
    
    [self fetchAndDownloadURLAndDisplayLoadingSymbol:self.selectedUrl];
}

@end
