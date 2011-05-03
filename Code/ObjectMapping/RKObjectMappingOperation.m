//
//  RKObjectMappingOperation.m
//  RestKit
//
//  Created by Blake Watters on 4/30/11.
//  Copyright 2011 Two Toasters. All rights reserved.
//

#import "RKObjectMappingOperation.h"

@implementation RKObjectMappingOperation

@synthesize sourceObject = _sourceObject;
@synthesize destinationObject = _destinationObject;
@synthesize keyPath = _keyPath;
@synthesize objectMapping = _objectMapping;
@synthesize delegate = _delegate;

- (id)initWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject keyPath:(NSString*)keyPath objectMapping:(RKObjectMapping*)objectMapping {
    NSAssert(sourceObject != nil, @"Cannot perform a mapping operation without a sourceObject object");
    NSAssert(destinationObject != nil, @"Cannot perform a mapping operation without a destinationObject");
    NSAssert(keyPath != nil, @"Cannot perform a mapping operation without a keyPath context");
    NSAssert(objectMapping != nil, @"Cannot perform a mapping operation without an object mapping to apply");
    
    self = [super init];
    if (self) {
        _sourceObject = [sourceObject retain];
        _destinationObject = [destinationObject retain];
        _keyPath = [keyPath retain];
        _objectMapping = [objectMapping retain];
    }
    
    return self;
}

- (void)dealloc {
    [_sourceObject release];
    [_destinationObject release];
    [_keyPath release];
    [_objectMapping release];
    
    [super dealloc];
}

- (NSString*)objectClassName {
    return NSStringFromClass([self.destinationObject class]);
}

- (void)performMapping {
    for (RKObjectAttributeMapping* attributeMapping in self.objectMapping.mappings) {
        // TODO: Catch exceptions here... valueForUndefinedKey
        id value = [self.sourceObject valueForKeyPath:attributeMapping.sourceKeyPath];
        // TODO: Replace this logging...
        NSLog(@"Asking self.sourceObject %@ for valueForKeyPath: %@. Got %@", self.sourceObject, attributeMapping.sourceKeyPath, value);
        if (value) {
            [self.delegate objectMappingOperation:self didFindMapping:attributeMapping forKeyPath:attributeMapping.sourceKeyPath];
            // TODO: didFindMappableValue:atKeyPath:
            // TODO: Handle relationships and collections by evaluating the type of the elementMapping???
            // didSetValue:forKeyPath:fromKeyPath:            
            [self.destinationObject setValue:value forKey:attributeMapping.destinationKeyPath];
            [self.delegate objectMappingOperation:self didSetValue:value forKeyPath:attributeMapping.destinationKeyPath usingMapping:attributeMapping];
        } else {
            [self.delegate objectMappingOperation:self didNotFindMappingForKeyPath:attributeMapping.sourceKeyPath];
            // TODO: didNotFindMappableValue:forKeyPath:
        }
    }
}

- (NSString*)description {
    return [NSString stringWithFormat:@"RKObjectMappingOperation for '%@' object at 'keyPath': %@. Mapping values from object %@ to object %@ with object mapping %@",
            [self objectClassName], self.keyPath, self.sourceObject, self.destinationObject];
}

@end