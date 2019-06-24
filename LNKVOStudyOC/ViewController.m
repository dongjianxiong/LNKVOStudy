//
//  ViewController.m
//  LNKVOStudyOC
//
//  Created by ioser on 2018/9/14.
//  Copyright © 2018年 Lenny. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Hellokitty.h"
#import "NSObject+LNCustomKVO.h"
#import "LNFatTiger.h"
#import <objc/runtime.h>


@interface ViewController ()

@property (nonatomic, strong) LNFatTiger *fatTiger;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fatTiger = [[LNFatTiger alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addObserverForSelf)];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addGestureRecognizer:tap];
    
//    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    [self holleWorld];
    
}

- (void)addObserverForSelf
{
    [self.fatTiger LN_addObserver:self forKey:@"name" bloak:^(NSObject *observer, NSString *key) {
        
    }];
    
    [self.fatTiger setName:@"hahha"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(fe_viewWillApper:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
    
}

-(void)fe_viewWillApper:(BOOL)animated{
    //    [self fe_viewWillApper:animated];
    NSLog(@"FlyElephant--fe_viewWillApper");
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"FlyElephant--fe_viewWillApper");
}

@end
