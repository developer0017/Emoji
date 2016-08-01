//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "utilities.h"

//#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void LoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//	NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[WelcomeView alloc] init]];
//	[target presentViewController:navigationController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = CGSizeMake(width, height);
	UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PostNotification(NSString *notification)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* TimeElapsed(NSTimeInterval seconds)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *elapsed;
	if (seconds < 60 * 60)
	{
		int minutes = (int) (seconds / 60);
		elapsed = [NSString stringWithFormat:@"%d %@", minutes, (minutes > 1) ? @"mins" : @"min"];
	}
	else if (seconds < 24 * 60 * 60)
	{
		int hours = (int) (seconds / (60 * 60));
		elapsed = [NSString stringWithFormat:@"%d %@", hours, (hours > 1) ? @"hours" : @"hour"];
	}
	else
	{
		int days = (int) (seconds / (24 * 60 * 60));
		elapsed = [NSString stringWithFormat:@"%d %@", days, (days > 1) ? @"days" : @"day"];
	}
	return elapsed;
}

NSString* ArrayToJSONString(NSArray *array)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *json = nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return (error ? nil : json);
}

NSArray* JSONStringToArray(NSString *jsonString)
{
    NSArray *array = [[NSArray alloc] init];
    NSError *error = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    id jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        array = jsonArray;
    }
    
    return array;
}
