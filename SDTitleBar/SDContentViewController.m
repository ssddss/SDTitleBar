//
//  SDContentViewController.m
//  SDTitleBar
//
//  Created by ssdd on 15/10/9.
//  Copyright © 2015年 ssdd. All rights reserved.
//

#import "SDContentViewController.h"

@interface SDContentViewController ()
@property (weak, nonatomic) IBOutlet UILabel *content;

@end

@implementation SDContentViewController
- (instancetype)init {
    self = [super initWithNibName:@"SDContentViewController" bundle:[NSBundle mainBundle]];
    
    if (!self) {
        return nil;
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.content setText:self.contentDict[@"urlString"]];
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
