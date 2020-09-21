//
//  WXYZ_SearchBoxCollectionView.h
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ClassifyModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_SearchBoxCollectionDelegate <NSObject>

- (void)selectSearchBoxAtIndex:(NSIndexPath *)indexPath selectField:(NSString *)field selectValue:(NSString *)value;

@end

@interface WXYZ_SearchBoxCollectionView : UIView

@property (nonatomic, strong) WXYZ_SearchBoxModel *searchModel;

@property (nonatomic, weak) id <WXYZ_SearchBoxCollectionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
