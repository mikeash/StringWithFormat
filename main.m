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
    TEST(@"-1", @"%d", -1);
    TEST(@"-2147483648", @"%d", INT_MIN);
    
    TEST(@"1", @"%ld", 1L);
    TEST(sizeof(long) == 8 ? @"9223372036854775807" : @"2147483647", @"%ld", LONG_MAX);
    TEST(@"-1", @"%ld", -1L);
    TEST(@"1", @"%lld", 1LL);
    TEST(@"9223372036854775807", @"%lld", LLONG_MAX);
    TEST(@"-9223372036854775808", @"%lld", LLONG_MIN);
    
    TEST(@"4294967295", @"%u", -1);
    TEST(sizeof(long) == 8 ? @"18446744073709551615" : @"4294967295", @"%lu", -1L);
    TEST(@"18446744073709551615", @"%llu", -1L);
    
    TEST(@"INFINITY", @"%f", INFINITY);
    TEST(@"NaN", @"%f", NAN);
    TEST(@"1.0", @"%f", 1.0);
    TEST(@"0.5", @"%f", 0.5);
    TEST(@"1.5", @"%f", 1.5);
    
    TEST(@"42.0", @"%f", 42.0);
    TEST(@"0.625", @"%f", 0.625);
    TEST(@"42.625", @"%f", 42.625);
    TEST(@"0.2000000000000000104", @"%f", 0.2);
    TEST(@"-1.0", @"%f", -1.0);
    TEST(@"0.0", @"%f", 0.0);
    
    TEST(@"10000000000000000400000000000000000000000.0", @"%f", 1e40);
    
    TEST(@"0.0000000000000000000000000000000000000000999999999999999907", @"%f", 1e-40);
    
    TEST(@"hello", @"%s", "hello");
    TEST(@"hello", @"%@", @"hello");
    TEST(@"(\n    hello\n)", @"%@", @[ @"hello" ]);
    
    TEST(@"%", @"%%");
    
    TEST(@"", @"%");
    TEST(@"", @"%l");
    TEST(@"", @"%ll");
}
