// Hah, day 12 is in Mercury and day 16 is ObjC, but they both use .m
// I wonder how GitHub will handle that

#import <Foundation/Foundation.h>
// exclamation point key still broke
#include <iso646.h>

typedef NS_ENUM(NSInteger, AOCDirection) {
    AOCDirectionEast = 1,
    AOCDirectionSouth = 2,
    AOCDirectionWest = 4,
    AOCDirectionNorth = 8
};

@interface AOCLocation : NSObject<NSCopying> {
@private
    NSUInteger x;
    NSUInteger y;
    AOCDirection direction;
}

@property NSUInteger x;
@property NSUInteger y;
@property AOCDirection direction;

- (instancetype)initWithX:(NSUInteger)x y:(NSUInteger)y direction:(AOCDirection)direction;

- (NSUInteger)offsetGivenLineLength:(NSUInteger)lineLength;
- (BOOL)isOutOfBoundsForString:(NSString *)string;
- (AOCLocation *)advanced;

@end

static inline void advanceAndAdd(AOCLocation *location, NSMutableSet *newLocations, NSString *str) {
    AOCLocation *newLoc = [[location advanced] retain];
    if (not [newLoc isOutOfBoundsForString:str]) {
        [newLocations addObject:newLoc];
    }
    [newLoc release];
}

static inline NSInteger f(NSString *str) {
    NSUInteger len = [str length];
    // Yes, this technically has extra space for the newlines. But what does it matter
    // It makes the code easier
    AOCDirection *energizedArr = calloc(len, sizeof (AOCDirection));

    NSRange newlineRange = [str rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    NSUInteger lineLength = newlineRange.location;

    NSSet *locations = [NSSet setWithObject:[[AOCLocation alloc] initWithX:0
                                                                         y:0
                                                                 direction:AOCDirectionEast]];  
    NSUInteger locCount;

    while ((locCount = [locations count]) not_eq 0) {
        // This capacity is sometimes an overestimate and sometimes an underestimate. Oh well.
        NSMutableSet *newLocations = [NSMutableSet setWithCapacity:locCount];

        NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
        
        for (AOCLocation *location in locations) {
            NSUInteger index = [location offsetGivenLineLength:lineLength];
            AOCDirection dir = [location direction];
            if (energizedArr[index] & dir) {
                // this is a loop
                continue;
            }
            energizedArr[index] |= dir;

            switch ([str characterAtIndex:index]) {
                case '.':
                    advanceAndAdd(location, newLocations, str);
                    break;
                case '-': {
                    if (dir == AOCDirectionEast || dir == AOCDirectionWest) {
                        advanceAndAdd(location, newLocations, str);
                    } else {
                        AOCLocation *westBoundCopy = [location copy];
                        AOCLocation *eastBoundCopy = [location copy];
                        [westBoundCopy setDirection:AOCDirectionWest];
                        [eastBoundCopy setDirection:AOCDirectionEast];
                        advanceAndAdd(westBoundCopy, newLocations, str);
                        advanceAndAdd(eastBoundCopy, newLocations, str);
                        [westBoundCopy release];
                        [eastBoundCopy release];
                    }
                    break;
                }
                case '|':
                    if (dir == AOCDirectionNorth || dir == AOCDirectionSouth) {
                        advanceAndAdd(location, newLocations, str);
                    } else {
                        AOCLocation *northBoundCopy = [location copy];
                        AOCLocation *southBoundCopy = [location copy];
                        [northBoundCopy setDirection:AOCDirectionNorth];
                        [southBoundCopy setDirection:AOCDirectionSouth];
                        advanceAndAdd(northBoundCopy, newLocations, str);
                        advanceAndAdd(southBoundCopy, newLocations, str);
                        [northBoundCopy release];
                        [southBoundCopy release];
                    }
                    break;
                case '\\': {
                    AOCLocation *newLoc = [location copy];
                    switch (dir) {
                    case AOCDirectionEast:
                        [newLoc setDirection:AOCDirectionSouth];
                        break;
                    case AOCDirectionSouth:
                        [newLoc setDirection:AOCDirectionEast];
                        break;
                    case AOCDirectionWest:
                        [newLoc setDirection:AOCDirectionNorth];
                        break;
                    case AOCDirectionNorth:
                        [newLoc setDirection:AOCDirectionWest];
                        break;
                    }
                    advanceAndAdd(newLoc, newLocations, str);
                    [newLoc release];
                    break;
                }
                case '/': {
                    AOCLocation *newLoc = [location copy];
                    switch (dir) {
                    case AOCDirectionEast:
                        [newLoc setDirection:AOCDirectionNorth];
                        break;
                    case AOCDirectionSouth:
                        [newLoc setDirection:AOCDirectionWest];
                        break;
                    case AOCDirectionWest:
                        [newLoc setDirection:AOCDirectionSouth];
                        break;
                    case AOCDirectionNorth:
                        [newLoc setDirection:AOCDirectionEast];
                        break;
                    }
                    advanceAndAdd(newLoc, newLocations, str);
                    [newLoc release];
                    break;
                }
                case '\n':
                case '\0':
                    // Shouldn't happen but easy to handle
                    energizedArr[index] = 0;
                    break;
                default:
                    // Uhhhhhhh
                    [NSException raise:NSInternalInconsistencyException
                                format:@"Unexpected character '%c' in grid", [str characterAtIndex:index]];
            }
        }
        
        [localPool drain];

        [locations release];
        locations = newLocations;
    }
    
    [locations release];

    NSInteger count = 0;
    NSUInteger i;
    for (i = 0; i < len; ++i) {
        if (energizedArr[i] not_eq 0) {
            ++count;
        }
    }
    free(energizedArr);
    return count;
}

@implementation AOCLocation

@synthesize x;
@synthesize y;
@synthesize direction;

- (id)initWithX:(NSUInteger)x y:(NSUInteger)y direction:(AOCDirection)direction {
    if ((self = [super init])) {
        self->x = x;
        self->y = y;
        self->direction = direction;
    }
    return self;
}

- (NSUInteger)offsetGivenLineLength:(NSUInteger)lineLength {
    return (lineLength + 1) * self->y + self->x;
}

- (BOOL)isOutOfBoundsForString:(NSString *)string {
    if (self->x < 0 || self->y < 0) {
        return YES;
    }

    NSRange newlineRange = [string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    NSUInteger lineLength = newlineRange.location;
    if (self->x >= lineLength) {
        return YES;
    }

    NSUInteger offset = [self offsetGivenLineLength:lineLength];
    return (offset >= [string length]);
}

- (AOCLocation *)advanced {
    AOCLocation *copy = [self copy];

    switch (self->direction) {
    case AOCDirectionEast:
        [copy setX:self->x + 1];
        break;
    case AOCDirectionSouth:
        [copy setY:self->y + 1];
        break;
    case AOCDirectionWest:
        [copy setX:self->x - 1];
        break;
    case AOCDirectionNorth:
        [copy setY:self->y - 1];
        break;
    }

    return [copy autorelease];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[AOCLocation allocWithZone:zone] initWithX:self->x y:self->y direction:self->direction];
}

- (BOOL)isEqual:(id)anObject {
    if (self == anObject) {
        return YES;
    }

    if (not [anObject isKindOfClass:[self class]]) {
        return NO;
    }
    AOCLocation *other = anObject;

    return self->x == [other x] && self->y == [other y] && self->direction == [other direction];
}

- (NSUInteger)hash {
    NSUInteger wordSwappedY = (y << (4 * sizeof y)) | (y >> (4 * sizeof y));
    return x ^ wordSwappedY ^ (direction << 8);
}

@end
