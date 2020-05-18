//
//  TableViewCell.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "TableViewCell.h"
#import "QMImageView.h"

@interface TableViewCell()

@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
}

- (void)setUserImageWithUrl:(NSURL *)userImageUrl {
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    
    [self.qmImageView setImageWithURL:userImageUrl
                          placeholder:placeholder
                              options:SDWebImageHighPriority
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                       completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
}

- (void)setUserImage:(UIImage *)image withKey:(NSString *)key {
    
    if (!image) {
        image = [UIImage imageNamed:@"upic-placeholder"];
    }
    
    
    [self.qmImageView setImage:image withKey:key];
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
    
}

@end
