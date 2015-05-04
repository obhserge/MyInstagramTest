//
//  obhGroupWallViewController.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhFeedViewController.h"
#import "obhServerManager.h"

//cell
#import "obhPostCell.h"

//model
#import "obhUser.h"
#import "obhPost.h"

//category
#import "UIView+UITableViewCell.h"

//comment view controller
#import "obhCommentViewController.h"

@interface obhFeedViewController ()

@property (strong, nonatomic) NSMutableArray* postsArray;
@property (strong, nonatomic) NSArray *navBarItems;
@property (strong, nonatomic) UIFont* myFont;
@property (assign, nonatomic) CGFloat imageWidth;
@property (assign, nonatomic) CGFloat imageHeight;

@end

@implementation obhFeedViewController

//количество постов в запросе
static NSInteger postsInRequest = 3;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // инициализируем массив, в которые будем помещать посты
    self.postsArray = [NSMutableArray array];
    //шрифт для текста
    self.myFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    
    // ширина девайса
    self.imageWidth = CGRectGetWidth(self.view.frame);
    //высота девайса
    self.imageHeight = self.imageWidth;
    
    // создаем pull to refresh
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // если пользователь авторизовался, делаем запись в NSUserDefaults
    // и делаем запрос, получить посты с сервера.
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"firstRun"]) {
        
        [[obhServerManager sharedManager] authorizeUser:^(obhUser *user) {
            
            if (user != Nil) {
                
                NSLog(@"AUTHORIZED!");
                NSLog(@"%@ %@", user.fullName, user.username);
                
                [defaults setObject:@"YES" forKey:@"firstRun"];
                [defaults synchronize];
                [self getPostsFromServerWithMaxID:nil minID:nil count:postsInRequest];
            }
            
        }];
        
    } else {
        
        [self getPostsFromServerWithMaxID:nil minID:nil count:postsInRequest];
        
    }

}

- (void)viewDidAppear:(BOOL)animated {
    
    // скрываем navigationBar при помощи свайпа
    self.navigationController.hidesBarsOnSwipe = YES;
    
    // если navigationBar скрыт при возврате с другого контроллера,
    // показываем его
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    
}

- (BOOL)prefersStatusBarHidden
{
    // если navigationBar скрыт, то скрываем и statusBar
    if (self.navigationController.navigationBarHidden) {
        return YES;
    }
    return NO;
}


#pragma mark - Actions 

- (void)refreshFeed {

    // получаем id первого поста в массиве, и делаем запрос,
    // на получение постов, раньше чем отправленный
    
    obhPost* post = [self.postsArray firstObject];
    
    [self getPostsFromServerWithMaxID:nil minID:post.postID count:0];
    
}

- (void)commentButtonAction:(UIButton*) button {
    
    // определяем, какой ячейки таблицы, принадлежит кнопка
    UITableViewCell* cell = [button superCell];
    
    if (cell) {
        
        // получаем indexPath ячейки и пост по indexPath'у
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        obhPost* post = [self.postsArray objectAtIndex:indexPath.section];
        
        // инициализируем view controller с комментариями,
        // передаем в него id поста и пушим в navigationController
        
        obhCommentViewController* commentViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"obhCommentViewController"];
        commentViewController.mediaID = post.postID;
        
        [self.navigationController pushViewController:commentViewController animated:YES];
    }
    
}


#pragma mark - API

- (void)getPostsFromServerWithMaxID:(NSString*) maxID minID:(NSString*)minID count:(NSInteger) count {
    
    [[obhServerManager sharedManager]
     getSelfFeedWithCount:count
     maxID:maxID
     minID:minID
     onSuccess:^(NSArray *posts) {
         
         if (maxID) {
             
             // если запрос был отправлен с maxID, и мы получили массив posts,
             // добавляем новые посты в self.postsArray и вставляем новые секции
             
             [self.postsArray addObjectsFromArray:posts];
             [self.tableView beginUpdates];
             
             NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
             
             for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                 [indexSet addIndex:i];
             }
             
             [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
             [self.tableView endUpdates];
             
         } else if (minID) {
             
             // если запрос был отправлен с minID, и мы получили массив posts,
             // добавляем новые посты в self.postsArray и обновляем таблицу
             
             if ([posts count] > 0) {
                 
                 for (int i = (int)[posts count]; i > 0; i--) {
                     
                     [self.postsArray insertObject:[posts objectAtIndex:i-1] atIndex:0];
                     
                 }
                 
                 [self.tableView reloadData];

                 [self.refreshControl endRefreshing];
                 
             } else {
                 
                 [self.refreshControl endRefreshing];
                 
             }
             
             
         } else {
             
             // если запрос был отправлен без параметров maxID или minID, и мы получили массив posts,
             // добавляем новые посты в self.postsArray и вставляем новые секции
             
             self.postsArray = [NSMutableArray array];
             [self.postsArray addObjectsFromArray:posts];
             
             [self.tableView beginUpdates];
             NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
             
             for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                 [indexSet addIndex:i];
             }
             
             [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
             [self.tableView endUpdates];
             
         }
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"failure!");
         
     }];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // количество постов равно количеству ячеек
    return [self.postsArray count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"PostCell";
    
    obhPostCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[obhPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    obhPost* post = [self.postsArray objectAtIndex:indexPath.section];
    
    CGFloat offset = 5.0f;
    
    //создаем imageView, где будет фото
    UIImageView *imageView = [[UIImageView alloc]
                              initWithFrame:
                              CGRectMake(0, 0, self.imageWidth, self.imageHeight)];
    [imageView setTag:1];
    imageView.image = [UIImage imageNamed:@"mountains13.png"];
    
    //создаем textLabel, где будет количество лайков
    UILabel *likesCountLabel = [[UILabel alloc]init];
    
    //высчитываем высоту лэйбла с количеством лайков
    CGFloat likesCountLabelHeight = [obhPostCell heightForText:post.likesCount withFont:self.myFont];
    
    likesCountLabel.frame = CGRectMake(offset,                                                  /*   x    */
                                       self.imageHeight,                                        /*   y    */
                                       self.imageWidth-offset*2,                                /* width  */
                                       likesCountLabelHeight);                                  /* height */
    
    likesCountLabel.text = [NSString stringWithFormat:@"Нравится: %@", post.likesCount];
    [likesCountLabel setTag:2];
    [likesCountLabel setFont:self.myFont];
    
    //создаем textLabel, где будет текст
    UILabel *postTextLabel = [[UILabel alloc]init];
    
    //высчитываем высоту лэйбла с текстом поста
    CGFloat postTextLabelHeight = [obhPostCell heightForText:post.postText withFont:self.myFont];
    postTextLabel.frame = CGRectMake(offset,
                                     self.imageHeight + likesCountLabelHeight,
                                     self.imageWidth-offset*2,
                                     postTextLabelHeight);
    
    postTextLabel.text = [NSString stringWithFormat:@"%@: %@", post.username, post.postText];
    [postTextLabel setNumberOfLines:0];
    [postTextLabel setTag:3];
    [postTextLabel setFont:self.myFont];
    
    CGRect rectForButton = CGRectMake(0,
                                      self.imageHeight + likesCountLabelHeight + postTextLabelHeight,
                                      self.imageWidth,
                                      likesCountLabelHeight);
    
    UIButton* commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    commentButton.frame = rectForButton;
    [commentButton setTitle:@"Комментарии" forState:UIControlStateNormal];
    [commentButton setTintColor:[UIColor blackColor]];
    [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [commentButton setBackgroundColor:[UIColor grayColor]];
    [commentButton addTarget:self action:@selector(commentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [commentButton setTag:4];
    
    NSCache *memoryCache;
    
    // отправляем асинхронный запрос, на получение изображения
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:post.standardResolutionImageURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imgData)
            {
                // сохраняем в файловую систему
                NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *file = [cachesDirectory stringByAppendingPathComponent:post.standardResolutionImageURL];
                [[NSFileManager defaultManager] createFileAtPath:file contents:imgData attributes:nil];
                [imgData writeToFile:file atomically:YES];
                
                // сохраняем в кэш
                [memoryCache setObject:imgData forKey:post.standardResolutionImageURL];
                
                UIImage *image = [UIImage imageWithData:imgData];
                
                // Проверяем изображение
                if (image)
                {
                    imageView.image = image;
                }
                else
                {
                    // если не получили изображение
                    imageView.image = [UIImage imageNamed:@"round54.png"];
                }
            }
            else
            {
                // если не получили изображение
                imageView.image = [UIImage imageNamed:@"round54.png"];
            }
        });
    });
    
    // удаляем с superview view предыдущей ячейки
    if ((([cell.contentView viewWithTag:1]) &&
         ([cell.contentView viewWithTag:2]) &&
         ([cell.contentView viewWithTag:3]) &&
         ([cell.contentView viewWithTag:4])))
    {
        [[cell.contentView viewWithTag:1]removeFromSuperview];
        [[cell.contentView viewWithTag:2]removeFromSuperview];
        [[cell.contentView viewWithTag:3]removeFromSuperview];
        [[cell.contentView viewWithTag:4]removeFromSuperview];
    }
    
    // добавляем на view label с текстом, лайками, кнопку и изображение
    [cell.contentView addSubview:likesCountLabel];
    [cell.contentView addSubview:postTextLabel];
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:commentButton];
    
    if (indexPath.section == [self.postsArray count] - 1)
    {
        // если мы на последней ячейке, делаем запрос, на получение новых постов
        [self getPostsFromServerWithMaxID:post.postID minID:nil count:3];
    }
    
    return cell;
    
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //получаем пост по номеру
    obhPost* post = [self.postsArray objectAtIndex:section];
    
    //создаем image с картинкой профиля пользователя
    UIImage *myImage =
    [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:post.userProfilePictureURL]]];
    
    //создаем imageView с ранее созданным image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    imageView.frame = CGRectMake(10,5,30,30);
    imageView.layer.cornerRadius = 15.f;
    imageView.layer.masksToBounds = YES;
    
    //создаем label с username пользователя
    UILabel* usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 250, 30)];
    [usernameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:16.0f]];
    usernameLabel.text = post.username;
    
    //создаем label с createdTime поста
    UILabel* createdTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 75, 30)];
    createdTimeLabel.text = post.createdTime;
    
    //создаем вьюху, на которую вешаем все ранее созданное и добавляем ее на self.view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(1,1,3,4)];
    view.backgroundColor = [UIColor whiteColor];
    
    [view addSubview:imageView];
    [view addSubview:usernameLabel];
    [view addSubview:createdTimeLabel];
    
    [self.view addSubview:view];
    
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // высота секции
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    //берем пост из массива по indexPath.section
    obhPost* post = [self.postsArray objectAtIndex:indexPath.section];
    
    //считаем высоту текста в посте
    CGFloat heightPostText = [obhPostCell heightForText:post.postText withFont:self.myFont];
    //считаем высоту строки с количеством лайков
    CGFloat heightLikesCount = [obhPostCell heightForText:post.likesCount withFont:self.myFont];
    //считаем высоту фотки
    CGFloat heightImage = CGRectGetWidth(self.view.frame);
    
    //все складываем и получаем высоту ячейки
    return heightPostText+heightImage+heightLikesCount*2;
    
}


#pragma mark - UIScrollViewDelegate

/*
-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f){
        return;
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = 20;
    
    if(self.navBarItems.count > 0){
        [self.navigationController.navigationBar setItems:self.navBarItems];
    }
    
    [self.navigationController.navigationBar setFrame:frame];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f){
        return;
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    
    if([scrollView.panGestureRecognizer translationInView:self.view].y < 0)
    {
        frame.origin.y = -size;
        
        if(self.navigationController.navigationBar.items.count > 0){
            self.navBarItems = [self.navigationController.navigationBar.items copy];
            
            [UIView animateWithDuration:0.2f animations:^{
                
                self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
                self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0);
                
            }];
            
            [self.navigationController.navigationBar setItems:nil];

        }
    }
    else if([scrollView.panGestureRecognizer translationInView:self.view].y > 0)
    {
        frame.origin.y = 20;
        
        if(self.navBarItems.count > 0){
            
            [UIView animateWithDuration:0.2f animations:^{
                self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
                self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
            }];
            
            [self.navigationController.navigationBar setItems:self.navBarItems];
        }
    }
    
    [UIView beginAnimations:@"toggleNavBar" context:nil];
    [UIView setAnimationDuration:0.2f];
    [self.navigationController.navigationBar setFrame:frame];
    [UIView commitAnimations];
}

*/




 

@end
