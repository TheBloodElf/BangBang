//
//  CMMacros+Block.h
//  CMMacros
//
//  Created by C.Maverick on 15/6/7.
//  Copyright (c) 2015年 C.Maverick. All rights reserved.
//

#ifndef CMMacros_Block_h
#define CMMacros_Block_h

//空的block
typedef void(^BlankBlock)(void);

#define WeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#undef  perform_block_safely
#define perform_block_safely( b, ... ) if ( (b) ) { (b)(__VA_ARGS__); }

//在主线程同步执行block

#undef  dispatch_main_sync_safe
#define dispatch_main_sync_safe(block) if ([NSThread isMainThread]) { block(); \
} else { dispatch_sync(dispatch_get_main_queue(), block); }
//在主线程异步执行block

#undef  dispatch_main_async_safe
#define dispatch_main_async_safe(block) if ([NSThread isMainThread]) { block(); \
} else { dispatch_async(dispatch_get_main_queue(), block); }

#endif
