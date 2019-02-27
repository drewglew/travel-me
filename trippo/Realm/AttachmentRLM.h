//
//  AttachmentRLM.h
//  trippo-app
//
//  Created by andrew glew on 24/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface AttachmentRLM : RLMObject
@property NSString *key;
@property NSString *filename;
@property NSString *notes;
@property NSDate *importeddate;
@end

RLM_ARRAY_TYPE(AttachmentRLM)

NS_ASSUME_NONNULL_END
