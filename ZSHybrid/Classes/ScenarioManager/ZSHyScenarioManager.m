//
//  ZSHyManager.m
//  ParkPlatform
//
//  Created by SoSo. on 6/3/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import "ZSHyScenarioManager.h"
#import "ZSHyOperationCenter.h"
#import "ZSHyWebViewController.h"

/*********************************************************************
 *
 *  class ZSHyManager
 *
 *********************************************************************/

@interface ZSHyScenarioManager ()

@property (nonatomic, strong) ZSHyWebViewController *webViewController;

@end

@implementation ZSHyScenarioManager

@synthesize webViewController = _webViewController;

static NSMutableDictionary *_mDict = nil;

#pragma mark - Public

/**
 *  Singleton init
 *
 *  @return hybrid manager instance
 */
+ (instancetype)sharedManager
{
    @synchronized(self)
    {
        NSString *className = NSStringFromClass(self);
        
        return [_mDict objectForKey:className];
    }
}

/**
 *  Get specified manager by manager name
 *
 *  @param name manager name
 *
 *  @return sub-class instance
 */
+ (instancetype)managerByName:(const NSString *)name
{
    ZSHyScenarioManager *retManager = nil;
    
    NSString *className = [NSString stringWithFormat:@"%@Manager", name];
    
    if ([NSClassFromString(className) isSubclassOfClass:self])
    {
        retManager = [NSClassFromString(className) sharedManager];
    }
    
    return retManager;
}

/**
 *  Init
 *
 *  @return self instance
 */
- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        ;
    }
    
    return self;
}

#pragma mark - Inner Protocol Method

/**
 *  Sub-class should override this method and return a specified title
 *
 *  @return return title for view controller
 */
- (NSString *)title
{
    return nil;
}

/**
 *  Sub-class should override this method to load the specified url for webview
 *
 *  @return URL string
 */
- (NSString *)webPageURLString
{
    return nil;
}

/**
 *  Load secnario and present scenarios view with open mode
 *
 *  @param viewController The view controller to open scencario
 *  @param mode           ScenarioOpenMode, if using Push mode, the viewController should be contained
 *                        in a navigationViewController.
 *                        Otherwise, you should prepare the close button for presenting mode.
 */
- (void)loadScenarioFromViewController:(UIViewController *)viewController openMode:(ScenarioOpenMode)mode
{
    //
    //  register operations for this manager to handle, every time the manager is being used
    //
    [[ZSHyOperationCenter defaultCenter] registerOperation:[self registerOperationsNames] fromHandler:self];
    
    //
    //  open view controller
    //
    [self loadViewController2Screen:viewController openMode:mode];

    //
    //  load url
    //
    [self.webViewController loadURLString:self.webPageURLString];
}

#pragma mark - Operation delegate method

/**
 *  The operation names that this manager could handle, 
 *  the sub-class need to implement and return it's own operations names.
 *
 *  @return bunch of operations names
 */
- (NSArray *)registerOperationsNames
{
    return nil;
}

/**
 *  Do operation according to operation command,
 *  Sub-class should override this method to proccess its own operation, but need including super method
 *
 *  @param operation operation object
 *
 *  @return return the Y or N about whether this operation is accepted
 */
- (BOOL)handleOperation:(ZSHyOperation *)operation
{
    BOOL retOperationAccepted = NO;
    
    //
    //  handle your operation if any
    //

    return retOperationAccepted;
}

#pragma mark - Private

/**
 *  initialize and regesiter self siglton object
 */
+ (void)initialize
{
    //
    //  ZSHyManager is abstract class, won't be initialized
    //
    if ([NSStringFromClass(self) isEqualToString:@"ZSHyScenarioManager"])
    {
        return;
    }
    
    @synchronized(self)
    {
        if (nil == _mDict)
        {
            _mDict = [NSMutableDictionary dictionary];
        }
        
        NSString *className = NSStringFromClass(self);
        
        if (nil == [_mDict objectForKey:className])
        {
            ZSHyScenarioManager *aManager = [[self alloc] init];
            
            [_mDict setObject:aManager forKey:className];
        }
    }
}

/**
 *  Open view on the screen, modally.
 *
 *  @param onVC the view controller to present
 */
- (void)loadViewController2Screen:(UIViewController *)onVC openMode:(ScenarioOpenMode)mode;
{
    self.webViewController = [[ZSHyWebViewController alloc] init];
    self.webViewController.title = [self title];

    switch (mode)
    {
        case SOM_Push:
        {
            //
            //  push view controller
            //
            [onVC.navigationController pushViewController:self.webViewController animated:YES];
            break;
        }
        case SOM_Present:
        default:
        {
            //
            //  present view controller
            //
            [onVC presentViewController:self.webViewController animated:YES completion:nil];
            break;
        }
    }
}

@end
