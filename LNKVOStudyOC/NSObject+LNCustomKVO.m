//
//  NSObject+LNCustomKVO.m
//  LNKVOStudyOC
//
//  Created by ioser on 2018/9/18.
//  Copyright © 2018年 Lenny. All rights reserved.
//

#import "NSObject+LNCustomKVO.h"
#import <objc/runtime.h>

static const void * const kLNCustomKVOInfoList = &kLNCustomKVOInfoList;

//static NSString *kLNCustomKVOInfoList = @"kLNCustomKVOInfoList";
//static NSString *kLNCustomKVODispatchQueueSpecificKey = @"kLNCustomKVODispatchQueueSpecificKey";
static const void * const kLNCustomKVODispatchQueueSpecificKey = &kLNCustomKVODispatchQueueSpecificKey;

//static NSString *kLNCustomKVOQueue = @"kLNCustomKVOQueue";
static const void * const kLNCustomKVOQueue = &kLNCustomKVOQueue;
static NSString *LNKVOSubclassSuffix = @"LNKVO";

@interface LNCustomKVOInfo : NSObject

@property (nonatomic, strong) id observer;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) void (^block)(NSObject *observer, NSString *key);

@end

@implementation LNCustomKVOInfo

@end




//@interface NSObject ()
//
//@property (nonatomic, strong) dispatch_queue_t queue;
//
//@end
//

@implementation NSObject (LNCustomKVO)

- (void)LN_addObserver:(NSObject *)observer forKey:(NSString *)key bloak:(void (^)(NSObject *observer, NSString *key))block
{
    Class baseClass = object_getClass(self);
    NSString *className = NSStringFromClass(baseClass);
    const char *subclassName = className.UTF8String;
    if (![className hasSuffix:LNKVOSubclassSuffix]) {
        subclassName = [className stringByAppendingString:LNKVOSubclassSuffix].UTF8String;
    }
    //
    Class subclass = objc_getClass(subclassName);
    if (!subclass) {
        subclass = objc_allocateClassPair(object_getClass(self), subclassName, 0);
        if (subclass == nil) {
            NSString *errrorDesc = [NSString stringWithFormat:@"objc_allocateClassPair failed to allocate class %s.", subclassName];
            NSLog(@"Error message:%@",errrorDesc);
            return;
        }
        objc_registerClassPair(subclass);
        object_setClass(self, subclass);
    }

    LNCustomKVOInfo *info = [[LNCustomKVOInfo alloc] init];
    info.observer = observer;
    info.key = key;
    info.block = block;
    
    NSMutableArray *infoList = objc_getAssociatedObject(self, &kLNCustomKVOInfoList);
    if (!infoList) {
        infoList =  [NSMutableArray array];
        objc_setAssociatedObject(self, &kLNCustomKVOInfoList, infoList, OBJC_ASSOCIATION_RETAIN);
    }
    [infoList addObject:info];
    
    SEL setSelecter = [self getSetSelecter:key];
    Method method = class_getInstanceMethod(subclass, setSelecter);
    IMP imp = method_getImplementation(method);
    const char *typeEcoding = method_getTypeEncoding(method);
    if (imp) {
        class_replaceMethod(subclass, setSelecter, (IMP)LNKVO_setter, typeEcoding);
    }else{
       class_addMethod(subclass, setSelecter, (IMP)LNKVO_setter, typeEcoding);
    }
}

- (SEL)getSetSelecter:(NSString *)keyName
{
    if (keyName.length > 0) {
        NSString *firstC = [keyName substringToIndex:1];
        firstC = [firstC uppercaseString];
        keyName = [keyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstC];
        NSString *setSeleterName = [@"set" stringByAppendingFormat:@"%@:", keyName];
        SEL setSlecter = NSSelectorFromString(setSeleterName);
        return setSlecter;
    }
    return nil;
}

NSString * keyNameForSelecterName(NSString *selecterName)
{
    if (selecterName.length > 4) {
        selecterName = [selecterName substringFromIndex:3];
        selecterName = [selecterName substringToIndex:selecterName.length-1];
        NSString *firstC = [selecterName substringToIndex:1];
        firstC = [firstC lowercaseString];
        NSString *keyName = [selecterName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstC];
        return keyName;
    }
    return nil;
}

void LNKVO_setter(id self, SEL _cmd, id newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = keyNameForSelecterName(setterName);
    if (!getterName) {
        return;
    }
    NSMutableArray *infoList = objc_getAssociatedObject(self, &kLNCustomKVOInfoList);

    for (LNCustomKVOInfo *info in infoList) {
        if ([info.key isEqualToString:getterName]) {
            if (info.block) {
                info.block(info.observer, getterName);
            }
        }
    }
}

+ (void)load
{
    NSLog(@"LNCustomKVO--load");
}

- (void)holleWorld
{
    NSLog(@"LNCustomKVO--holleWorld");
}
@end
