//
//  MKStoreObserver.m
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//

#import "MKStoreObserver.h"
#import "MKStoreManager.h"
#import "AppDelegate.h"

static MKStoreObserver* _sharedObject = nil;
NSString *const MKStoreObserverProductPurchasedNotification = @"MKStoreObserverProductPurchasedNotification";
@implementation MKStoreObserver
@synthesize arrayRet;
@synthesize FlashLevel,EMLevel,SALevel,TFLevel;


+ (id)sharedObject {
    @synchronized(self) {
        if (_sharedObject == nil) {
            _sharedObject = [[self alloc] init];
        }
    }
    return _sharedObject;
}


- (NSString *)dataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}



- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
   			case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"------success");
                [self completeTransaction:transaction];
            }
                break;
				
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"-------failed");
                [self failedTransaction:transaction];
            }
                break;
				
            case SKPaymentTransactionStateRestored:
            {
				NSLog(@"-------restored");
                [self restoreTransaction:transaction];
            }
				break;
            default:
				
                break;
		}
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSUserDefaults *userdefalts = [NSUserDefaults standardUserDefaults];
    [userdefalts setBool:true forKey:@"purchaseflage"];
    [userdefalts synchronize];
    if (transaction.error.code == SKErrorPaymentCancelled )
    {
		NSLog(@"cancelled");
	}
    
	if (transaction.error.code == SKErrorPaymentNotAllowed ) {
		NSLog(@"pay not allowd");
	}
	
	if (transaction.error.code == SKErrorPaymentInvalid ) {
		NSLog(@"invalid");
	}
    
    if (transaction.error.code == SKErrorClientInvalid ) {
		NSLog(@"SKErrorClientInvalid");
	}
	
	if (transaction.error.code == SKErrorUnknown ) {
		NSLog(@"SKErrorUnknown");
	}
    
	if (transaction.error.code == SKErrorStoreProductNotAvailable ) {
		NSLog(@"SKErrorStoreProductNotAvailable");
	}
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed",@"") message:NSLocalizedString(@"Purchased Failed, Please try again.",@"")
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles: nil];
    [alert show];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[NSNotificationCenter defaultCenter]postNotificationName:IAPNOTIFICATION object:nil userInfo:nil];
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"test_purchase=%@",transaction.payment.productIdentifier);
    
    [self provideContent: transaction.payment.productIdentifier shouldSerialize:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SUCCESSED",@"") message:NSLocalizedString(@"Purchased Successed, Thank you.",@"")
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles: nil];
    [alert show];

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    isRestoring = YES;
    [self provideContent: transaction.originalTransaction.payment.productIdentifier shouldSerialize:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SUCCESSED",@"") message:NSLocalizedString(@"Restore Successed, Thank you.",@"")
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles: nil];
    [alert show];

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    isRestoring = YES;
    AppDelegate *app = [[UIApplication sharedApplication]delegate];
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        app.restore_flag = true;
        NSString *productID = transaction.payment.productIdentifier;
        [self provideContent:productID shouldSerialize:YES];
        app.comeinpurchasestr = productID;
        [[NSNotificationCenter defaultCenter]postNotificationName:IAPNOTIFICATION object:nil userInfo:nil];
    }
    app.restore_flag = false;
    [[NSNotificationCenter defaultCenter]postNotificationName:IAPNOTIFICATION object:nil userInfo:nil];
}

-(void) provideContent: (NSString*)productIdentifier shouldSerialize: (BOOL) serialize
{
    if(serialize)
    {
        NSUserDefaults *userdefalts = [NSUserDefaults standardUserDefaults];
        
        AppDelegate *app = [[UIApplication sharedApplication]delegate];
        if(!isRestoring)
        {
            NSLog(@"purchase_string= %@", productIdentifier);
            if([productIdentifier isEqualToString:GRUB_IAP] && [app.comeoutpurchasestr isEqualToString:GRUB_IAP])
                [userdefalts setBool:true forKey:@"food"];
            else if([productIdentifier isEqualToString:DRUG_IAP] && [app.comeoutpurchasestr isEqualToString:DRUG_IAP])
                [userdefalts setBool:true forKey:@"sexdrugs"];
            else if([productIdentifier isEqualToString:CAR_IAP] && [app.comeoutpurchasestr isEqualToString:CAR_IAP])
                [userdefalts setBool:true forKey:@"whips"];
            else if([productIdentifier isEqualToString:WEAPON_IAP] && [app.comeoutpurchasestr isEqualToString:WEAPON_IAP])
                [userdefalts setBool:true forKey:@"weapons"];
            else if([productIdentifier isEqualToString:PLACE_IAP] && [app.comeoutpurchasestr isEqualToString:PLACE_IAP])
                [userdefalts setBool:true forKey:@"places"];
            else if([productIdentifier isEqualToString:HAND_IAP] && [app.comeoutpurchasestr isEqualToString:HAND_IAP])
                [userdefalts setBool:true forKey:@"hands"];
            else if([productIdentifier isEqualToString:FACE_IAP] && [app.comeoutpurchasestr isEqualToString:FACE_IAP])
                [userdefalts setBool:true forKey:@"hoodconfacepngs"];
            else if([productIdentifier isEqualToString:MUSIC_IAP] && [app.comeoutpurchasestr isEqualToString:MUSIC_IAP])
                [userdefalts setBool:true forKey:@"music"];
            else if([productIdentifier isEqualToString:ANIMAL_IAP] && [app.comeoutpurchasestr isEqualToString:ANIMAL_IAP])
                [userdefalts setBool:true forKey:@"food"];
            else if([productIdentifier isEqualToString:GEAR_IAP] && [app.comeoutpurchasestr isEqualToString:GEAR_IAP])
                [userdefalts setBool:true forKey:@"fashion"];
            else if([productIdentifier isEqualToString:ART_IAP] && [app.comeoutpurchasestr isEqualToString:ART_IAP])
                [userdefalts setBool:true forKey:@"artsuplies"];
            else if([productIdentifier isEqualToString:SLAG_IAP] && [app.comeoutpurchasestr isEqualToString:SLAG_IAP])
                [userdefalts setBool:true forKey:@"animalpngs"];
            NSLog(@"purchase_string= %@", productIdentifier);
        }
        else
        {
            NSLog(@"purchase_string= %@", productIdentifier);
            
            if([productIdentifier isEqualToString:GRUB_IAP])
                [userdefalts setBool:true forKey:@"food"];
            else if([productIdentifier isEqualToString:DRUG_IAP])
                [userdefalts setBool:true forKey:@"sexdrugs"];
            else if([productIdentifier isEqualToString:CAR_IAP])
                [userdefalts setBool:true forKey:@"whips"];
            else if([productIdentifier isEqualToString:WEAPON_IAP])
                [userdefalts setBool:true forKey:@"weapons"];
            else if([productIdentifier isEqualToString:PLACE_IAP])
                [userdefalts setBool:true forKey:@"places"];
            else if([productIdentifier isEqualToString:HAND_IAP])
                [userdefalts setBool:true forKey:@"hands"];
            else if([productIdentifier isEqualToString:FACE_IAP])
                [userdefalts setBool:true forKey:@"hoodconfacepngs"];
            else if([productIdentifier isEqualToString:MUSIC_IAP])
                [userdefalts setBool:true forKey:@"music"];
            else if([productIdentifier isEqualToString:ANIMAL_IAP])
                [userdefalts setBool:true forKey:@"food"];
            else if([productIdentifier isEqualToString:GEAR_IAP])
                [userdefalts setBool:true forKey:@"fashion"];
            else if([productIdentifier isEqualToString:ART_IAP])
                [userdefalts setBool:true forKey:@"artsuplies"];
            else if([productIdentifier isEqualToString:SLAG_IAP])
                [userdefalts setBool:true forKey:@"animalpngs"];
            
            NSLog(@"purchase_string= %@", productIdentifier);
            isRestoring = NO;
        }
        
        [userdefalts synchronize];
        app.comeinpurchasestr = productIdentifier;
        [[NSNotificationCenter defaultCenter]postNotificationName:IAPNOTIFICATION object:nil userInfo:nil];
    }
    
}


@end
