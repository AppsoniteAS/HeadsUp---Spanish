//
//  moreViewController.m
//  Valutakalkulator
//
//  Created by Robin Grønvold on 7/24/13.
//  Copyright (c) 2013 Appsonite. All rights reserved.
//

#import "MoreViewController.h"
#import "moreTableCell.h"

@interface moreViewController ()

@end

@implementation moreViewController
@synthesize appList, descriptionList, imageList, urlList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"More apps", @"More apps");
        self.tabBarItem.image = [UIImage imageNamed:@"more_n.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    appList=[[NSArray alloc] initWithObjects:@"SuperScan", @"Job Interview App", @"Calory Counter", @"The Flying Game", nil];
    descriptionList=[[NSArray alloc] initWithObjects:@"Scan, sign and save your documents with this app. Perfect for scanning receipts, invoices and all documents. ",@"Practice mock interviews with this video tutorial app.You can video record your own answers and compare with mock answer", @"Track your calories and loose weight with this calory counter app", @"Go on an adventure in your own old fashioned airplane. Create your own sound effects",nil];
    imageList=[[NSArray alloc] initWithObjects:@"SSIcon-72.png",@"JobbInterviewIcon-72.png",@"KTIcon-72.png",@"flyinggameIcon-72.png", nil];
    urlList =[[NSArray alloc] initWithObjects:@"itms-apps://itunes.apple.com/us/app/superscan-scan-to-pdf-sign/id786499978?mt=8&uo=4",@"itms-apps://itunes.apple.com/us/app/job-interview-app-get-your/id475889617?mt=8&uo=4",@"itunes.apple.com/us/app/calory-counter/id781366831?mt=8&uo=4",@"itms-apps://itunes.apple.com/us/app/the-flying-game/id514313357?ls=1&mt=8",nil];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [appList count];
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cell.png"]] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"moreTableCell";
    
    moreTableCell *cell = (moreTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    NSString *nibName = nil;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        nibName = @"moreTableCell";
    }
    else
    {
        nibName = @"moreTableCell_ipad";
    }
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
    }

    // Updating table view through table cell
    NSString *appName = [appList objectAtIndex:indexPath.row];
    cell.appName.text = appName;
    NSString *appIcon = [imageList objectAtIndex:indexPath.row];
    cell.appImage.image = [UIImage imageNamed: appIcon];

    NSString *description = [descriptionList objectAtIndex:indexPath.row];
    cell.appDescription.text = description;
    return cell;
    
    /*if([deviceType isEqualToString:@"iPad"])
    {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"moreTableCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // Updating table view through table cell
        cell.appName.font = [UIFont systemFontOfSize:20];
        cell.appDescription.font = [UIFont systemFontOfSize:18];
        NSString *appName = [appList objectAtIndex:indexPath.row];
        cell.appName.text = appName;
        NSString *appIcon = [imageList objectAtIndex:indexPath.row];
        cell.appImage.image = [UIImage imageNamed: appIcon];
        
        NSString *description = [descriptionList objectAtIndex:indexPath.row];
        cell.appDescription.text = description;
        return cell;
    }*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = [urlList objectAtIndex:indexPath.row];
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openFeedback:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@""];
        NSArray *toRecipients = [NSArray arrayWithObjects:@"robin@appsonite.no", nil];
        [mailer setToRecipients:toRecipients];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feilmelding"
                                                        message:@"Din enhet kan ikke sende mail."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Epost kansellert.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Epost lagret: du lagret eposten i drafts mappen.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail i utboksen: eposten er klart til å sendes, den ligger i kø i utboksen");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Eposten ble ikke sendt.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
