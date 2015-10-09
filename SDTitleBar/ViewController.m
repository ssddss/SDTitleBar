//
//  ViewController.m
//  SDTitleBar
//
//  Created by ssdd on 15/10/9.
//  Copyright © 2015年 ssdd. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "SDTitleLabel.h"
#import "SDContentViewController.h"

static CGFloat const TitleBarHeight = 40;

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *titleScrollView;/**< 头部滚动视图*/
@property (nonatomic,strong) UIScrollView *contentScrollView;/**< 内容滚动视图*/
@property (nonatomic,strong) NSMutableArray *titleLists;/**< 标题源*/
@end

@implementation ViewController
#pragma mark - life cycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.titleScrollView];
    [self.view addSubview:self.contentScrollView];
    
    [self layoutPageSubviews];
    
    
    [self.titleLists addObjectsFromArray:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"NewsURLs.plist" ofType:nil]]];

    [self addControllers];
    [self addTitleLabels];
    
    CGFloat contentSizeWidth = self.childViewControllers.count * [UIScreen mainScreen].bounds.size.width;
    self.contentScrollView.contentSize = CGSizeMake(contentSizeWidth, 0);
    
    // 添加默认控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = self.contentScrollView.bounds;
    [self.contentScrollView addSubview:vc.view];
    SDTitleLabel *lablel = [self.titleScrollView.subviews firstObject];
    lablel.scale = 1.0;

}
#pragma mark - delegates
#pragma mark - ******************** scrollView代理方法

/** 滚动结束后调用（代码导致） */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.contentScrollView.frame.size.width;
    
    // 滚动标题栏
    SDTitleLabel *titleLable = (SDTitleLabel *)self.titleScrollView.subviews[index];
    
    CGFloat offsetx = titleLable.center.x - self.titleScrollView.frame.size.width * 0.5;
    
    CGFloat offsetMax = self.titleScrollView.contentSize.width - self.titleScrollView.frame.size.width;
    if (offsetx < 0) {
        offsetx = 0;
    }else if (offsetx > offsetMax){
        offsetx = offsetMax;
    }
    
    CGPoint offset = CGPointMake(offsetx, self.titleScrollView.contentOffset.y);
    [self.titleScrollView setContentOffset:offset animated:YES];
    // 添加控制器
    SDContentViewController *newsVc = self.childViewControllers[index];
    
    [self.titleScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {

            UIView *subview = self.titleScrollView.subviews[idx];
            if ([subview isKindOfClass:[SDTitleLabel class]]) {
                SDTitleLabel *temlabel = (SDTitleLabel *)subview;
                temlabel.scale = 0.0;

            }
        }
    }];
    
    if (newsVc.view.superview) return;
    
    newsVc.view.frame = scrollView.bounds;
    [self.contentScrollView addSubview:newsVc.view];
}

/** 滚动结束（手势导致） */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/** 正在滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 取出绝对值 避免最左边往右拉时形变超过1
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    SDTitleLabel *labelLeft = self.titleScrollView.subviews[leftIndex];
    labelLeft.scale = scaleLeft;
    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
    if (rightIndex < self.titleScrollView.subviews.count) {
         UIView *subview = self.titleScrollView.subviews[rightIndex];
        if ([subview isKindOfClass:[SDTitleLabel class]]) {
            SDTitleLabel *labelRight = (SDTitleLabel *)subview;
            labelRight.scale = scaleRight;
        }
       
    }
    
}
#pragma mark - notifications

#pragma mark - event response
/** 标题栏label的点击事件 */
- (void)lblClick:(UITapGestureRecognizer *)recognizer
{
    SDTitleLabel *titlelable = (SDTitleLabel *)recognizer.view;
    
    CGFloat offsetX = titlelable.tag * self.contentScrollView.frame.size.width;
    
    CGFloat offsetY = self.contentScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    
    [self.contentScrollView setContentOffset:offset animated:YES];
    
    
}
#pragma mark - public methods

#pragma mark - private methods
- (void)layoutPageSubviews {
    [self.titleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.and.right.equalTo(self.view);
        make.height.equalTo(@(TitleBarHeight));
    }];
    
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(self.view);
        make.top.equalTo(self.titleScrollView.mas_bottom);
    }];
}
- (void)addControllers {
    for (int i = 0; i<self.titleLists.count;i++) {
        SDContentViewController *contentVC = [[SDContentViewController alloc]init];
        NSDictionary *dict = self.titleLists[i];
        
        contentVC.contentDict = dict;
        
        [self addChildViewController:contentVC];
    }
}
- (void)addTitleLabels {
    CGFloat nextLblX = 0;/**< 下一个label的起始点*/
    CGFloat lblY = 0;/**< label的y点*/
    CGFloat lblH = TitleBarHeight;/**< label的高度*/
    
    for (int i = 0; i<self.titleLists.count; i++) {
        NSString *titleText = self.titleLists[i][@"title"];
        SDTitleLabel *lbl = [[SDTitleLabel alloc]init];
        lbl.text = titleText;
        lbl.font = [UIFont systemFontOfSize:18];
        lbl.tag = i;
        lbl.userInteractionEnabled = YES;
        [lbl addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
         //宽度稍微大一点
        CGSize titleSize = [titleText sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(MAXFLOAT, 40)];
        lbl.frame = CGRectMake(nextLblX, lblY, titleSize.width, lblH);
        
        [self.titleScrollView addSubview:lbl];
        
        nextLblX += titleSize.width;

    }
    self.titleScrollView.contentSize = CGSizeMake(nextLblX, 0);
    
}
#pragma mark - getters and setters
- (UIScrollView *)titleScrollView {
    if (!_titleScrollView) {
        _titleScrollView = [[UIScrollView alloc]init];
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        //不加这个会无故加上一个imageview
        _titleScrollView.showsVerticalScrollIndicator = NO;
    }
    return _titleScrollView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [UIScrollView new];
        _contentScrollView.showsHorizontalScrollIndicator = YES;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.delegate = self;
        _contentScrollView.backgroundColor = [UIColor greenColor];
    }
    
    return _contentScrollView;
}
- (NSMutableArray *)titleLists {
    if (!_titleLists) {
        _titleLists = [NSMutableArray arrayWithCapacity:0];
    }
    return _titleLists;
}

@end
