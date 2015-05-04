//
//  obhCommentViewController.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhCommentViewController.h"
#import "obhServerManager.h"

//cell
#import "obhCommentCell.h"

//model
#import "obhComment.h"

@interface obhCommentViewController ()

@property (strong, nonatomic) NSMutableArray* commentsArray;

@property (strong, nonatomic) UIFont* myFont;
@property (strong, nonatomic) UITextField* textField;

@property (assign, nonatomic) BOOL keyboardShown;
@property (assign, nonatomic) CGFloat keyboardOverlap;

@property (strong, nonatomic) UIView* viewBelowTextField;
@property (strong, nonatomic) UIButton* sendCommentButton;

@end

@implementation obhCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Комментарии";
    
    self.myFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    self.navigationController.navigationBarHidden = NO;
    
    CGFloat offset = 8.0f;
    
    CGFloat widthDevice = CGRectGetWidth(self.view.frame);
    CGFloat heightDevice = CGRectGetHeight(self.view.frame);
    
    CGFloat viewHeight = 46.0f;
    CGFloat buttonWidth = 90.0f;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 46.0f, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    // создаем view
    
    CGRect rect = CGRectMake(0, heightDevice - viewHeight, widthDevice, viewHeight);
    UIView* view = [[UIView alloc] initWithFrame:rect];
    view.tag = 1;
    [view setBackgroundColor:[UIColor colorWithRed:90.0f/255.f green:200.0f/250.0f blue:255.f/255.f alpha:1.0f]];
    
    
    // создаем кнопку "отправить" и назначаем ей target
    
    CGRect buttonRect = CGRectMake(widthDevice - buttonWidth,
                                   heightDevice - viewHeight + offset,
                                   buttonWidth - offset,
                                   viewHeight - offset*2);
    
    UIButton* sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = buttonRect;
    sendButton.tag = 2;
    sendButton.backgroundColor = [UIColor colorWithRed:255.0f/255.f green:45.0f/250.0f blue:85.f/255.f alpha:1.0f];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sendButton.layer.cornerRadius = offset;
    [sendButton addTarget:self action:@selector(postTextAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // создаем  textField для ввода комментария
    
    CGRect rectTextField = CGRectMake(offset,
                                      heightDevice - viewHeight + offset,
                                      widthDevice - offset * 2 - buttonWidth,
                                      viewHeight - offset*2);
    
    UITextField* textField = [[UITextField alloc] initWithFrame:rectTextField];
    textField.tag = 3;
    [textField setBackgroundColor:[UIColor whiteColor]];
    textField.placeholder = @"Введите комментарий";
    textField.layer.cornerRadius = offset;
    textField.delegate = self;
    
    self.textField = textField;
    self.viewBelowTextField = view;
    self.sendCommentButton = sendButton;
    
    // добавляем на subview
    
    [self.navigationController.view addSubview:view];
    [self.navigationController.view addSubview:textField];
    [self.navigationController.view addSubview:sendButton];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // подписываемся на нотификации клавиатуры
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter             addObserver:self
                                       selector:@selector(keyboardWillShow:)
                                           name:UIKeyboardWillShowNotification
                                         object:Nil];
    
    [notificationCenter             addObserver:self
                                       selector:@selector(keyboardWillHide:)
                                           name:UIKeyboardWillHideNotification
                                         object:Nil];
    
    // отправляем запрос на получение комментариев по mediaID
    [self getCommentsFromServer:self.mediaID];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // прячем клавиатуру и отписываемся от нотификаций
    [self.textField resignFirstResponder];
    
    [[self.navigationController.view viewWithTag:1] removeFromSuperview];
    [[self.navigationController.view viewWithTag:2] removeFromSuperview];
    [[self.navigationController.view viewWithTag:3] removeFromSuperview];
    
    [self.viewBelowTextField setHidden:YES];
    [self.textField setHidden:YES];
    [self.sendCommentButton setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)postTextAction:(UIButton*) sender {
    
    [[obhServerManager sharedManager]
     postComment:self.textField.text
     onMedia:self.mediaID
     onSuccess:^(id result) {
         NSLog(@"done");
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"fail");
     }];
    
}


#pragma mark - API

- (void)getCommentsFromServer:(NSString*) mediaID{
    
    [[obhServerManager sharedManager]
     getCommentsWithMediaID:mediaID
     onSuccess:^(NSArray *comments) {
         
         if (comments) {
             
             self.commentsArray = [NSMutableArray array];
             [self.commentsArray addObjectsFromArray:comments];

             [self.tableView reloadData];
         }
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"failure!");
         
     }];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"CommentCell";
    
    obhCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[obhCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    obhComment* comment = [self.commentsArray objectAtIndex:indexPath.row];
    
    CGFloat offset = 8.0f;
    
    //создаем imageView с ранее созданным image
    UIImageView *imageView = [[UIImageView alloc] init];
    
    CGFloat imageViewHeight = 30.0f;
    CGFloat imageViewWidht = 30.f;
    
    imageView.frame = CGRectMake(offset,offset,imageViewWidht,imageViewHeight);
    imageView.layer.cornerRadius = 15.f;
    imageView.layer.masksToBounds = YES;
    [imageView setTag:1];
    imageView.image = nil;
    
    
    //создаем textLabel c username пользователя
    UILabel *usernameLabel = [[UILabel alloc]init];
    
    //высчитываем высоту лэйбла с количеством лайков
    CGFloat usernameLabelHeight = [obhCommentCell heightForText:comment.username withFont:self.myFont];
    
    usernameLabel.frame = CGRectMake(offset*2 + imageViewWidht,
                                       0,
                                       CGRectGetWidth(self.view.frame) - offset*3 - imageViewWidht,
                                       usernameLabelHeight);
    
    usernameLabel.text = comment.username;
    [usernameLabel setNumberOfLines:0];
    [usernameLabel setTag:2];
    [usernameLabel setFont:self.myFont];
    
    //создаем textLabel, где будет текст
    UILabel *textLabel = [[UILabel alloc]init];
    
    //высчитываем высоту лэйбла с текстом поста
    CGFloat textLabelHeight = [obhCommentCell heightForText:comment.commentText withFont:self.myFont];
    textLabel.frame = CGRectMake(offset*2 + imageViewWidht,
                                     usernameLabelHeight,
                                     CGRectGetWidth(self.view.frame) - offset*3 - imageViewWidht,
                                     textLabelHeight);
    
    textLabel.text = comment.commentText;
    [textLabel setNumberOfLines:0];
    [textLabel setTag:3];
    [textLabel setFont:self.myFont];
    
    NSCache *memoryCache;
    
    // отправляем асинхронный запрос, на получение изображения
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:comment.userProfilePictureURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imgData)
            {
                
                // сохраняем в файловую систему
                NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *file = [cachesDirectory stringByAppendingPathComponent:comment.userProfilePictureURL];
                [imgData writeToFile:file atomically:YES];
                
                // сохраняем в кэш
                [memoryCache setObject:imgData forKey:comment.userProfilePictureURL];
                
                
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
         ([cell.contentView viewWithTag:3])))
    {
        [[cell.contentView viewWithTag:1]removeFromSuperview];
        [[cell.contentView viewWithTag:2]removeFromSuperview];
        [[cell.contentView viewWithTag:3]removeFromSuperview];
    }
    
    // добавляем на view label с username, комментарием и изображением пользователя
    
    [cell.contentView addSubview:usernameLabel];
    [cell.contentView addSubview:textLabel];
    [cell.contentView addSubview:imageView];
    
    return cell;
    
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //берем пост из массива по indexPath.section
    obhComment* comment = [self.commentsArray objectAtIndex:indexPath.row];
    
    //считаем высоту текста в посте
    CGFloat heightPostText = [obhCommentCell heightForText:comment.commentText withFont:self.myFont];
    //считаем высоту username
    CGFloat heightUsername = [obhCommentCell heightForText:comment.username withFont:self.myFont];
    
    //все складываем и получаем высоту ячейки
    return heightPostText+heightUsername;
    
}


#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if(_keyboardShown)
        return;
    
    _keyboardShown = YES;
    
    // Получаем размер клавиатуры
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    // Получаем детали анимации клавиатуры
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    // Определяем сколько слоев находится между клавиатурой и таблицей
    CGRect tableFrame = tableView.frame;
    CGFloat tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height;
    _keyboardOverlap = tableLowerYCoord - keyboardRect.origin.y;
    if(self.inputAccessoryView && _keyboardOverlap>0)
    {
        CGFloat accessoryHeight = self.inputAccessoryView.frame.size.height;
        _keyboardOverlap -= accessoryHeight;
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
    }
    
    if(_keyboardOverlap < 0)
        _keyboardOverlap = 0;
    
    if(_keyboardOverlap != 0)
    {
        tableFrame.size.height -= _keyboardOverlap;
        
        UIView* viewBelowTextField = self.viewBelowTextField;
        
        viewBelowTextField.frame = CGRectMake(0, viewBelowTextField.frame.origin.y - keyboardRect.size.height,          viewBelowTextField.frame.size.width, viewBelowTextField.frame.size.height);
        
        UITextField* textField = self.textField;
        
        textField.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y - keyboardRect.size.height, textField.frame.size.width, textField.frame.size.height);
        
        UIButton* button = self.sendCommentButton;
        
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y - keyboardRect.size.height, button.frame.size.width, button.frame.size.height);
        
        NSTimeInterval delay = 0;
        if(keyboardRect.size.height)
        {
            delay = (1 - _keyboardOverlap/keyboardRect.size.height)*animationDuration;
            animationDuration = animationDuration * _keyboardOverlap/keyboardRect.size.height;
        }
        //CGFloat viewHeight = 46.0f;CGFloat heightDevice = CGRectGetHeight(self.view.frame);
        [UIView animateWithDuration:animationDuration delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             tableView.frame = tableFrame;
                             self.viewBelowTextField.frame = viewBelowTextField.frame;
                             self.textField.frame = textField.frame;
                             self.sendCommentButton.frame = button.frame;
                             //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                             //self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                             //self.tableView.frame = CGRectMake(0, 0, 320, heightDevice - viewHeight - keyboardRect.size.height);
                         }
                         completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if (!_keyboardShown)
        return;
    
    _keyboardShown = NO;
    
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    if(self.inputAccessoryView)
    {
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    if(_keyboardOverlap == 0)
        return;
    
    // Получаем размеры клавиатуры и параметры анимации
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height += _keyboardOverlap;
    
    UIView* viewBelowTextField = self.viewBelowTextField;
    
    viewBelowTextField.frame = CGRectMake(0, viewBelowTextField.frame.origin.y + keyboardRect.size.height,          viewBelowTextField.frame.size.width, viewBelowTextField.frame.size.height);
    
    UITextField* textField = self.textField;
    
    textField.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y + keyboardRect.size.height, textField.frame.size.width, textField.frame.size.height);
    
    UIButton* button = self.sendCommentButton;
    
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y + keyboardRect.size.height, button.frame.size.width, button.frame.size.height);
    
    if(keyboardRect.size.height)
        animationDuration = animationDuration * _keyboardOverlap/keyboardRect.size.height;
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         tableView.frame = tableFrame;
                         self.viewBelowTextField.frame = viewBelowTextField.frame;
                         self.textField.frame = textField.frame;
                         self.sendCommentButton.frame = button.frame;
                     }
                     completion:nil];
}

- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.commentsArray count]-1 inSection:0];
    
    // Скролим к последней ячейке
    if(indexPath && [self.commentsArray count] != 0)
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // скрываем клавиатуры при нажатии на кнопку Return
    [textField resignFirstResponder];
    
    return YES;
    
}


@end
