//
//  NSObject+LNCustomKVO.h
//  LNKVOStudyOC
//
//  Created by ioser on 2018/9/18.
//  Copyright © 2018年 Lenny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LNCustomKVO)

- (void)LN_addObserver:(NSObject *)observer forKey:(NSString *)key bloak:(void (^)(NSObject *observer, NSString *key))block;

- (void)holleWorld;

@end
