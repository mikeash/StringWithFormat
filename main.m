// clang -framework Foundation -fobjc-arc MAStringWithFormat.m main.m

#import <Foundation/Foundation.h>

#import "MAStringWithFormat.h"


int main(int argc, char **argv)
{
    #define TEST(expected, ...) do { \
        NSString *actual = MAStringWithFormat(__VA_ARGS__); \
        if(![(expected) isEqual: actual]) { \
            NSLog(@"FAILURE! Expected %@ got %@", expected, actual); \
        } \
        else { \
            NSLog(@"Passed test: %@", expected); \
        } \
    } while(0)
    
    TEST(@"Abcd", @"Abcd");
    TEST(@"AB 42 CD", @"AB %d CD", 42);
    TEST(@"0", @"%d", 0);
    TEST(@"2147483647", @"%d", 2147483647);
    TEST(@"123456789", @"%d%d%d%d%d%d%d%d%d", 1, 2, 3, 4, 5, 6, 7, 8, 9);
    TEST(@"%", @"%%");
    TEST(@"-1", @"%d", -1);
    TEST(@"-2147483648", @"%d", INT_MIN);
}
