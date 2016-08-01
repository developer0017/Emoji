//
//  StoreDetailVIewController.m
//  Hoodcons
//
//  Created by SKY on 12/8/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import "StoreDetailVIewController.h"
#import "MKStoreManager.h"
#import "AppDelegate.h"
@interface StoreDetailVIewController ()
{
    AppDelegate *app;
}

@end

@implementation StoreDetailVIewController
@synthesize detailscrollview;

#define DETAIL_COUNT_ROW  4
#define DETAIL_COUNT_CLU  4
#define DETAIL_COUNT_PAGE ( DETAIL_COUNT_ROW * DETAIL_COUNT_CLU )
#define DETAIL_ICON_SIZE  40

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    app = [[UIApplication sharedApplication]delegate];
    [super viewDidLoad];
    
    NSLog(@"test=%@", _iap_string);
    if([_iap_string isEqualToString:ANIMAL_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_animations_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:ART_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_artsuplies_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:GEAR_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_fashion_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:GRUB_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_food_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:HAND_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_hands_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:FACE_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_hoodconfacepngs_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:MUSIC_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_music_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:DRUG_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_sexdrugs_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:SLAG_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_slang_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:WEAPON_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_weapons_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:CAR_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_whips_en"
                                                    ofType:@"plist"]];
    else if([_iap_string isEqualToString:PLACE_IAP])
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_places_en"
                                                    ofType:@"plist"]];
  
    NSArray* keysArray = [_faceMap keysSortedByValueUsingComparator:^(id first, id second) {
        
        return [first compare:second];
        
    }];
    
    firstitemcategory_number = [[keysArray firstObject] intValue];
    lastitemcategory_number = [[keysArray lastObject] intValue];
    
    float pagefloat = (float) (lastitemcategory_number - firstitemcategory_number + 1) / DETAIL_COUNT_PAGE;
    int pageCnt = (int)pagefloat;
    if(pagefloat>pageCnt)
        pageCnt = pageCnt + 1;
    detailscrollview.pagingEnabled = YES;
    //        faceView.contentSize = CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * 320, 190);
    detailscrollview.contentSize = CGSizeMake((pageCnt) * 320, 330);
    detailscrollview.showsHorizontalScrollIndicator = NO;
    detailscrollview.showsVerticalScrollIndicator = NO;
    detailscrollview.delegate = self;

    detailscrollview.backgroundColor = [UIColor clearColor];
  dispatch_async(dispatch_get_main_queue(), ^(void){
      for (int i = 1; i <= (lastitemcategory_number - firstitemcategory_number + 1); i++) {
          
          UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
          
          CGFloat x = (((i - 1) % DETAIL_COUNT_PAGE) % DETAIL_COUNT_CLU) * DETAIL_ICON_SIZE + 6 + ((i - 1) / DETAIL_COUNT_PAGE * 320) + ((i-1)%4)*35 ;
          CGFloat y = (((i - 1) % DETAIL_COUNT_PAGE) / DETAIL_COUNT_CLU) * DETAIL_ICON_SIZE + 8 + ((i-1)%16)/4 * 20;
          
//          if(i%16==0)
//              y = y-20;
          faceButton.frame = CGRectMake( x+20, y, 50, 50);
          faceButton.layer.borderColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7] CGColor];
          faceButton.layer.borderWidth = 2.0f;
          faceButton.layer.cornerRadius = 5.0f;
          
          NSString *imgName = [NSString stringWithFormat:@"%03d.png", (firstitemcategory_number +i - 1)];
          UIImage *currImg =[UIImage imageNamed: imgName];
          NSLog(@"Image name %@",imgName);
          if (currImg.size.width != DETAIL_ICON_SIZE) {
              currImg = [self image:currImg scaledToWidth:DETAIL_ICON_SIZE];
              //                NSLog(@"Image size is now %@",NSStringFromCGSize(currImg.size));
          }
          
          [faceButton setImage:currImg forState:UIControlStateNormal];
          
          [detailscrollview addSubview:faceButton];
      }
      //PageControl
      facePageControl = [[GrayPageControl alloc]initWithFrame:CGRectMake(110, 400, 100, 20)];
      
      facePageControl.backgroundColor = [UIColor clearColor];
      
      [facePageControl addTarget:self
                          action:@selector(pageChange:)
                forControlEvents:UIControlEventValueChanged];
      
      //        facePageControl.numberOfPages = FACE_COUNT_ALL / FACE_COUNT_PAGE + 1;
      facePageControl.numberOfPages = pageCnt;
      
      facePageControl.currentPage = 0;
      [self.view addSubview:facePageControl];
    });
    // Do any additional setup after loading the view from its nib.
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [facePageControl setCurrentPage:detailscrollview.contentOffset.x / 320];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    
    [detailscrollview setContentOffset:CGPointMake(facePageControl.currentPage * 320, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}



- (UIImage*)image:(UIImage *)sourceImage scaledToWidth:(float) i_width
{
    float oldWidth = sourceImage.size.width;
    float oldHeight = sourceImage.size.height;
    //    float imgHeight = imagePreview.frame.size.height * 2;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = oldHeight * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)backbtnclick:(id)sender
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)storebtnclick:(id)sender
{
    [[MKStoreManager sharedManager]buyMag:_iap_string];
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    [_HUD setLabelText:@"Connecting....."];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buttonactive) name:IAPNOTIFICATION object:nil];
}

- (void)buttonunactive
{
    [_backbtn setEnabled:false];
    [_purchasebtn setEnabled:false];
}

- (void)buttonactive
{
    if(!app.restore_flag)
        [[NSNotificationCenter defaultCenter]removeObserver:self name:IAPNOTIFICATION object:nil];
    [_backbtn setEnabled:true];
    [_purchasebtn setEnabled:true];
    [_HUD hide:YES];
    
    NSLog(@"test=%@", app.comeinpurchasestr);
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
        [userdefalts setBool:true forKey:@"animalpngs"];
    else if([app.comeinpurchasestr isEqualToString:GEAR_IAP])
        [userdefalts setBool:true forKey:@"fashion"];
    else if([app.comeinpurchasestr isEqualToString:ART_IAP])
        [userdefalts setBool:true forKey:@"artsuplies"];
    else if([app.comeinpurchasestr isEqualToString:SLAG_IAP])
        [userdefalts setBool:true forKey:@"slang"];
    
    [userdefalts synchronize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
