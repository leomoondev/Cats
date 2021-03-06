//
//  NetworkManager.m
//  Cats
//
//  Created by Hyung Jip Moon on 2017-02-28.
//  Copyright © 2017 leomoon. All rights reserved.
//

#import "NetworkManager.h"
@interface NetworkManager () {
    
}
@end

@implementation NetworkManager

// Completion Handler
- (void)getPicturesWithCompletion:(void (^)(NSMutableArray *))completion {
    // go fetch data
    NSURL *url = [NSURL URLWithString:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=500a485bcdb5d40ef46da98c4c7f8806&tags=cat"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *configureSession = [NSURLSession sessionWithConfiguration:configure];
    
    NSURLSessionDataTask *dataTask = [configureSession
                                      dataTaskWithRequest:urlRequest
                                      completionHandler:^
                                      (NSData * _Nullable data,
                                       NSURLResponse * _Nullable response,
                                       NSError * _Nullable error) {
                                          
                                          if (error) {
                                              
                                              NSLog(@"error: %@", error.localizedDescription);
                                              return;
                                              
                                          }
                                          NSError *jsonError = nil;
                                          NSDictionary *tempDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                          
                                          if(jsonError) {
                                              //Handle the error
                                              NSLog(@"jsonError: %@", jsonError.localizedDescription);
                                              return ;
                                          }
                                          
                                          NSDictionary *photos = [[tempDictionary objectForKey:@"photos"] objectForKey:@"photo"];
                                          NSMutableArray *storeAllImages = [NSMutableArray array];

                                          for(NSDictionary *tempPhotoDictionary in photos) {
                                              
                                              
                                              // Get title of the image
                                              NSString *title = [tempPhotoDictionary objectForKey:@"title"];
                                            
                                              Photo *newPhoto = [[Photo alloc] initWithServer:[tempPhotoDictionary objectForKey:@"server"] initWithFarm:[tempPhotoDictionary objectForKey:@"farm"] initWithID:[tempPhotoDictionary objectForKey:@"id"] initWithSecret:[tempPhotoDictionary objectForKey:@"secret"] initWithTitle:title initWithURL:url];
                                              
                                              
                                              [storeAllImages addObject:newPhoto];
                                            
                                              NSLog(@"%@",storeAllImages);
                                          }
                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                              //This will run on the main queue
                                              completion(storeAllImages);
                                          }];
                                      }];
    [dataTask resume];
}

//Download Images from URL
- (void)downloadImagesFromURL:(NSURL *)url completion:(void (^)(UIImage *))completion {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        
        UIImage *imageToBeDisplayed = [UIImage imageWithData:data];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completion(imageToBeDisplayed);
        }];
        
    }];
    
    [downloadTask resume];
}

@end
