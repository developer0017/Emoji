//
//  StoreViewController.m
//  Hoodcons
//
//  Created by Jeremiah McAllister on 11/21/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import "StoreViewController.h"
#import "StoreTableViewCell.h"
#import "MKStoreManager.h"
#import "AppDelegate.h"
#import "StoreDetailVIewController.h"
@interface StoreViewController ()
{
    AppDelegate *app;
}
@property (nonatomic, strong) NSArray *catList;

@end

@implementation StoreViewController
@synthesize backBtn;
@synthesize catList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        catList = [[NSArray alloc] initWithObjects:@"GRUB",@"SEX MONEY DRUGS",@"CARS",@"WEAPONS",@"PLACES",@"HAND EXPRESSIONS",@"FACES",@"MUSIC",@"ANIMALS",@"GEAR",@"ART SUPPLIES",@"SLANG", nil];
        NSLog(@"There are %lu categories", (unsigned long)catList.count);
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    app = [[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view from its nib.
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


- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restorebuttonpressed:(id)sender
{
    [[MKStoreManager sharedManager]restorefunction];
    [self buttonunactive];
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    [_HUD setLabelText:@"Connecting....."];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buttonactive) name:IAPNOTIFICATION object:nil];
}

- (void)buttonunactive
{
    [backBtn setEnabled:false];
    [_restorebtn setEnabled:false];
    _tbl.userInteractionEnabled = NO;
}

- (void)buttonactive
{
    if(!app.restore_flag)
        [[NSNotificationCenter defaultCenter]removeObserver:self name:IAPNOTIFICATION object:nil];
    [backBtn setEnabled:true];
    [_restorebtn setEnabled:true];
    _tbl.userInteractionEnabled = YES;
    [_HUD hide:YES];
    
    NSUserDefaults *userdefalts = [NSUserDefaults standardUserDefaults];
    if([app.comeinpurchasestr isEqualToString:GRUB_IAP])
        [userdefalts setBool:true forKey:@"food"];
    else if([app.comeinpurchasestr isEqualToString:DRUG_IAP])
        [userdefalts setBool:true forKey:@"sexdrugs"];
    else if([app.comeinpurchasestr isEqualToString:CAR_IAP])
        [userdefalts setBool:true forKey:@"whips"];
    else if([app.comeinpurchasestr isEqualToString:WEAPON_IAP])
        [userdefalts setBool:true forKey:@"weapons"];
    else if([app.comeinpurchasestr isEqualToString:PLACE_IAP])
        [userdefalts setBool:true forKey:@"places"];
    else if([app.comeinpurchasestr isEqualToString:HAND_IAP])
        [userdefalts setBool:true forKey:@"hands"];
    else if([app.comeinpurchasestr isEqualToString:FACE_IAP])
        [userdefalts setBool:true forKey:@"hoodconfacepngs"];
    else if([app.comeinpurchasestr isEqualToString:MUSIC_IAP])
        [userdefalts setBool:true forKey:@"music"];
    else if([app.comeinpurchasestr isEqualToString:ANIMAL_IAP])
        [userdefalts setBool:true forKey:@"food"];
    else if([app.comeinpurchasestr isEqualToString:GEAR_IAP])
        [userdefalts setBool:true forKey:@"fashion"];
    else if([app.comeinpurchasestr isEqualToString:ART_IAP])
        [userdefalts setBool:true forKey:@"artsuplies"];
    else if([app.comeinpurchasestr isEqualToString:SLAG_IAP])
        [userdefalts setBool:true forKey:@"animalpngs"];

    [userdefalts synchronize];
}


#pragma mark - UITableViewDataSource
/** ################################ UITableViewDataSource ################################ **/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return catList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StoreTableViewCell";
    StoreTableViewCell *cell = (StoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
    }
    [cell initWithTitle:[catList objectAtIndex:indexPath.row]];
    
    return cell;
}

/** ################################ UITableViewDelegate ################################ **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 78;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"item_name=%@", [catList objectAtIndex:indexPath.row]);
    app.comeoutpurchasestr = [catList objectAtIndex:indexPath.row];
    
    StoreDetailVIewController *controller = [[StoreDetailVIewController alloc]initWithNibName:@"StoreDetailVIewController" bundle:nil];
    
    switch (indexPath.row) {
        case 0:
            controller.iap_string = GRUB_IAP;
            break;
        case 1:
            controller.iap_string = DRUG_IAP;
            break;
        case 2:
            controller.iap_string = CAR_IAP;
            break;
        case 3:
            controller.iap_string = WEAPON_IAP;
            break;
        case 4:
            controller.iap_string = PLACE_IAP;
            break;
        case 5:
            controller.iap_string = HAND_IAP;
            break;
        case 6:
            controller.iap_string = FACE_IAP;
            break;
        case 7:
            controller.iap_string = MUSIC_IAP;
            break;
        case 8:
            controller.iap_string = ANIMAL_IAP;
            break;
        case 9:
            controller.iap_string = GEAR_IAP;
            break;
        case 10:
            controller.iap_string = ART_IAP;
            break;
        case 11:
            controller.iap_string = SLAG_IAP;
            break;
        default:
            break;
    }
    [self presentViewController:controller animated:YES completion:nil];
//    [self buttonunactive];
//    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _HUD.delegate = self;
//    [_HUD setLabelText:@"Connecting....."];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buttonactive) name:IAPNOTIFICATION object:nil];
}


@end
