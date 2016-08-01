//
//  ContactsViewController.m
//  Hoodcons
//
//  Created by SKY on 12/8/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactTableViewCell.h"

@implementation NSString(EmojiExtension)
- (NSString*)removeEmoji {
    __block NSMutableString* temp = [NSMutableString string];
    
    [self enumerateSubstringsInRange: NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
             
             [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"": substring]; // U+1D000-1F77F
             
             // non surrogate
         } else {
             [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"": substring]; // U+2100-26FF
         }
     }];
    
    return temp;
}
@end

@interface ContactsViewController ()

@end

@implementation ContactsViewController



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
    [super viewDidLoad];
    self.contacts = [NSMutableArray array];
    [self askContacts];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.contacts count] > 0) {
        return ([self.contacts count]);
    }
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 78;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ContactTableViewCell";
    ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
    }

    
    ContactObject *contact = [self.contacts objectAtIndex:indexPath.row];
    
    cell.username.text = [NSString stringWithFormat:@"%@ %@", contact.contactfirstname, contact.contactlastname];
    if(contact.contactImg == nil)
        cell.userphoto.image = [UIImage imageNamed:@"avatar.png"];
    else
        cell.userphoto.image = contact.contactImg;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *actionSheet;
    _selectuser = [self.contacts objectAtIndex:indexPath.row];    
    actionSheet = [[UIActionSheet alloc]
                   initWithTitle:NSLocalizedString(@"Invite your friends in Hoodcons",@"")
                   delegate:self
                   cancelButtonTitle:nil
                   destructiveButtonTitle:NSLocalizedString(@"Cancel",@"")
                   otherButtonTitles:NSLocalizedString(@"Invite Via E-mail",@""),NSLocalizedString(@"Invite Via SMS",@""),nil];
    
    actionSheet.tag = 1;
    actionSheet.alpha = 1.0;
    [actionSheet showFromRect:CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60) inView:self.view animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (actionSheet.tag == 1) {
		if (buttonIndex == 0){
			
		}
		else if (buttonIndex == 1){
			[self sendMail];
			
		}
		else if (buttonIndex == 2){
			[self sendSMS];
		}
	}
}


- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        mailViewController.mailComposeDelegate = self;
        mailViewController.title = @"Invite Friend";
        [mailViewController setToRecipients:[NSArray arrayWithObjects:_selectuser.email, nil]];
        [mailViewController setSubject:@"Hoodcons SMS"];
        [mailViewController setMessageBody:@"Hoodcons SMS: an innovative communication system available for Andro Iphone. FREE download  from https://itunes.apple.com/us/app/cilink-pro/id835567660?ls=1&mt=8" isHTML:NO];
        
        [self presentModalViewController:mailViewController animated:YES];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Device is unable to send e-mail in its current state." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (void)sendSMS {
    
    if ([MFMessageComposeViewController canSendText]) {
        
        MFMessageComposeViewController *mailViewController = [[MFMessageComposeViewController alloc] init];
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        mailViewController.messageComposeDelegate = self;
        [mailViewController setRecipients:[NSArray arrayWithObjects:_selectuser.phone, nil]];
        mailViewController.title = @"Invite Friend";
        mailViewController.body = @"Hoodcons SMS: an innovative communication system available for Andro Iphone. FREE download  from https://itunes.apple.com/us/app/cilink-pro/id835567660?ls=1&mt=8";
        
        [self presentModalViewController:mailViewController animated:YES];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Device is unable to send SMS in its current state." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Address

- (void)askContacts {
    if (ABAddressBookRequestAccessWithCompletion) //Si IOS 6 => Demande l'autorisation d'accéder aux contacts
    {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) // Premier accès aux contacts
                                                     {
                                                         [self storeContacts:addressBookRef];
                                                         [self sortContacts];
                                                         [self.contactlisttbl performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                                                     }
                                                     
                                                     );
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) // Accès aux contacts déja validé précédemment
        {
            [self storeContacts:addressBookRef];
            [self sortContacts];
            [self.contactlisttbl performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }
        else // Si ce n'est pas IOS 6 => récuperer directement les contacts ABAdressBookCreate();
        {
            ABAddressBookRef addressBookRef = ABAddressBookCreate();
            [self storeContacts:addressBookRef];
            [self sortContacts];
            [self.contactlisttbl performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            
        }
    
 }

- (void)sortContacts {
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortField" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [self.contacts sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
    
    if ([self.contacts count] > 0) {
        ContactObject *contact = self.contacts[0];
        
        
        while ([contact.sortField isEqualToString:@"#"]) {
            [self.contacts removeObjectAtIndex:0];
            [self.contacts addObject:contact];
            contact = self.contacts[0];
        }
    }
}


- (void)storeContacts:(ABAddressBookRef)addressBookRef {
    NSArray *arrayOfPeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    int i = 0;
    [self.contacts removeAllObjects];
    //0 = firstName 1 = lastName
    sort = ABPersonGetSortOrdering();
    
    while (i < [arrayOfPeople count])
    {
        ContactObject *contact = [[ContactObject alloc] init];
        ABRecordRef currentPerson = (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:i];
        
        NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(currentPerson, kABPersonPhoneProperty));
        NSArray *emails = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(currentPerson, kABPersonEmailProperty));
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty));
        if(firstName == nil)
            firstName = @"";
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(currentPerson, kABPersonLastNameProperty));
        if(lastName == nil)
            lastName = @"";
        
        CFDataRef imageData = ABPersonCopyImageData(currentPerson);
        UIImage *image = [UIImage imageWithData:(__bridge NSData *)imageData];
     
        contact.contactfirstname = [firstName removeEmoji];
        contact.contactlastname = [lastName removeEmoji];
        contact.contactImg = image;
     
        
        if ([phones count] > 0)
            contact.phone = phones[0];
        if ([emails count] > 0)
            contact.email = emails[0];
        
        contact.searchField = [NSString stringWithFormat:@"%@ %@ %@ %@", contact.contactfirstname, contact.contactlastname, contact.phone, contact.email];
        
        if (sort == 0) {
            if (contact.contactfirstname)
                contact.sortField = contact.contactfirstname;
            else if (contact.contactlastname)
                contact.sortField = contact.contactlastname;
            else
            {
                contact.sortField = @"#";
                contact.searchField = @"#";
            }
        }
        else {
            if (contact.contactlastname)
                contact.sortField = contact.contactlastname;
            else if (contact.contactfirstname)
                contact.sortField = contact.contactfirstname;
            else {
                contact.sortField = @"#";
                contact.searchField = @"#";
            }
        }
        
        [self.contacts addObject:contact];
        
        i++;
    }
}



#pragma mark Mail Delegate

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissModalViewControllerAnimated:YES];
}


@end
