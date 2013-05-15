#import "MAStringWithFormat.h"

@interface MAStringFormatter : NSObject

- (NSString *)format: (NSString *)format arguments: (va_list)arguments;

@end

NSString *MAStringWithFormat(NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    
    MAStringFormatter *formatter = [[MAStringFormatter alloc] init];
    NSString *result = [formatter format: format arguments: arguments];
    
    va_end(arguments);
    
    return result;
}

@implementation MAStringFormatter {
    va_list _arguments;
    
    CFStringInlineBuffer _formatBuffer;
    NSUInteger _formatLength;
    NSUInteger _cursor;
    
    unichar *_outputBuffer;
    NSUInteger _outputBufferCursor;
    NSUInteger _outputBufferLength;
}

- (NSString *)format: (NSString *)format arguments: (va_list)arguments
{
    _formatLength = [format length];
    CFStringInitInlineBuffer((__bridge CFStringRef)format, &_formatBuffer, CFRangeMake(0, _formatLength));
    _cursor = 0;
    
    int c;
    while((c = [self read]) >= 0)
    {
        if(c != '%')
        {
            [self write: c];
        }
        else
        {
            int next = [self read];
            if(next < 0)
            {
                [self write: c];
                break;
            }
            
            if(next == 'd')
            {
                int value = va_arg(arguments, int);
                [self writeLongLong: value];
            }
            else if(next == 'u')
            {
                unsigned value = va_arg(arguments, unsigned);
                [self writeUnsignedLongLong: value];
            }
            else if(next == 'l')
            {
                next = [self read];
                if(next == 'd')
                {
                    long value = va_arg(arguments, long);
                    [self writeLongLong: value];
                }
                else if(next == 'u')
                {
                    unsigned long value = va_arg(arguments, unsigned long);
                    [self writeUnsignedLongLong: value];
                }
                else if(next == 'l')
                {
                    next = [self read];
                    if(next == 'd')
                    {
                        long long value = va_arg(arguments, long long);
                        [self writeLongLong: value];
                    }
                    else if(next == 'u')
                    {
                        unsigned long long value = va_arg(arguments, unsigned long long);
                        [self writeUnsignedLongLong: value];
                    }
                }
            }
            else if(next == 'f')
            {
                double value = va_arg(arguments, double);
                [self writeDouble: value];
            }
            else if(next == 's')
            {
                const char *value = va_arg(arguments, const char *);
                while(*value)
                    [self write: *value++];
            }
            else if(next == '@')
            {
                id value = va_arg(arguments, id);
                NSString *description = [value description];
                NSUInteger length = [description length];
                
                while(length > _outputBufferLength - _outputBufferCursor)
                    [self doubleOutputBuffer];
                
                [description getCharacters: _outputBuffer + _outputBufferCursor range: NSMakeRange(0, length)];
                _outputBufferCursor += length;
            }
            else if(next == '%')
            {
                [self write: '%'];
            }
        }
    }
    
    NSString *output = [[NSString alloc] initWithCharactersNoCopy: _outputBuffer length: _outputBufferCursor freeWhenDone: YES];
    _outputBuffer = NULL;
    return output;
}

- (void)writeLongLong: (long long)value
{
    if(value < 0)
    {
        [self write: '-'];
        if(value == LLONG_MIN)
        {
            [self writeUnsignedLongLong: 1ULL << (sizeof(long long) * CHAR_BIT - 1)];
            return;
        }
        else
            value = -value;
    }
    [self writeUnsignedLongLong: value];
}

- (void)writeUnsignedLongLong: (unsigned long long)value
{
    unsigned long long cursor = 1;
    while(value / cursor >= 10)
        cursor *= 10;
    
    while(cursor > 0)
    {
        int digit = value / cursor;
        [self write: '0' + digit];
        value -= digit * cursor;
        cursor /= 10;
    }
}

- (void)writeDouble: (double)value
{
    if(isinf(value) || isnan(value))
    {
        const char *str = isinf(value) ? "INFINITY" : "NaN";
        while(*str)
            [self write: *str++];
        return;
    }
    
    double intpart = trunc(value);
    double fracpart = value - intpart;
    
    [self writeDoubleIntPart: intpart];
    [self write: '.'];
    [self writeDoubleFracPart: fracpart];
}

- (void)writeDoubleIntPart: (double)intpart
{
    unsigned long long total = 0;
    unsigned long long currentBit = 1;
    
    unsigned long long maxValue = [self ullongMaxPowerOf10] / 10;
    
    unsigned surplusZeroes = 0;
    
    while(intpart)
    {
        intpart /= 2;
        if(fmod(intpart, 1.0))
        {
            total += currentBit;
            intpart = trunc(intpart);
        }
        currentBit *= 2;
        if(currentBit > maxValue)
        {
            total /= 10;
            currentBit = (currentBit + 5) / 10;
            surplusZeroes++;
        }
    }
    
    [self writeUnsignedLongLong: total];
    for(unsigned i = 0; i < surplusZeroes; i++)
        [self write: '0'];
}

- (void)writeDoubleFracPart: (double)fracpart
{
    unsigned long long total = 0;
    unsigned long long currentBit = [self ullongMaxPowerOf10];
    unsigned long long shiftThreshold = [self ullongMaxPowerOf10] / 10;
    
    while(fracpart)
    {
        currentBit /= 2;
        fracpart *= 2;
        if(fracpart >= 1.0)
        {
            total += currentBit;
            fracpart -= 1.0;
        }
        
        if(currentBit <= shiftThreshold && total <= shiftThreshold)
        {
            [self write: '0'];
            currentBit *= 10;
            total *= 10;
        }
    }
    
    while(total != 0 && total % 10 == 0)
        total /= 10;
    
    [self writeUnsignedLongLong: total];
}

- (unsigned long long)ullongMaxPowerOf10
{
    unsigned long long result = 1;
    while(ULLONG_MAX / result >= 10)
        result *= 10;
    return result;
}

- (int)read
{
    if(_cursor < _formatLength)
        return CFStringGetCharacterFromInlineBuffer(&_formatBuffer, _cursor++);
    else
        return -1;
}

- (void)write: (unichar)c
{
    if(_outputBufferCursor >= _outputBufferLength)
        [self doubleOutputBuffer];
    
    _outputBuffer[_outputBufferCursor] = c;
    _outputBufferCursor++;
}

- (void)doubleOutputBuffer
{
    if(_outputBufferLength == 0)
        _outputBufferLength = 64;
    else
        _outputBufferLength *= 2;
    _outputBuffer = realloc(_outputBuffer, _outputBufferLength * sizeof(*_outputBuffer));
}

@end
