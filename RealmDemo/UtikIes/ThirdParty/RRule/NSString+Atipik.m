/*The MIT License (MIT)
 Copyright (c) 2012 Atipik Sarl
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
#import "NSString+Atipik.h"

#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))

static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static char base64DecodingTable[128];
static BOOL base64Initialized = NO;

@implementation NSString (NSString_Atipik)
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			,nil];  
}

/*return the path without the file*/
-(NSString *) pathComponent
{
	NSString * result =@"";
	NSArray * paths = [self pathComponents];
	int i=0;
	while (i<[paths count] && ![[self lastPathComponent] isEqual:[paths objectAtIndex:i]]) {
		result =[result stringByAppendingPathComponent:[paths objectAtIndex:i]];
	}
	return result;
}

- (NSData*) base64Decode
{
	return [NSString base64Decode:self];
}

+ (NSData*) base64Decode:(NSString*) string 
{
	return [self base64Decode:[string cStringUsingEncoding:NSASCIIStringEncoding] length:string.length];
}


+ (NSData*) base64Decode:(const char*) string length:(NSInteger) inputLength 
{
	[NSData initializeBase64];
	if ((string == NULL) || (inputLength % 4 != 0)) {
		return nil;
	}
	
	while (inputLength > 0 && string[inputLength - 1] == '=') {
		inputLength--;
	}
	
	NSInteger outputLength = inputLength * 3 / 4;
	NSMutableData* data = [NSMutableData dataWithLength:outputLength];
	uint8_t* output = data.mutableBytes;
	
	NSInteger inputPoint = 0;
	NSInteger outputPoint = 0;
	while (inputPoint < inputLength) {
		char i0 = string[inputPoint++];
		char i1 = string[inputPoint++];
		char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
		char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';
		
		output[outputPoint++] = (base64DecodingTable[i0] << 2) | (base64DecodingTable[i1] >> 4);
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((base64DecodingTable[i1] & 0xf) << 4) | (base64DecodingTable[i2] >> 2);
		}
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((base64DecodingTable[i2] & 0x3) << 6) | base64DecodingTable[i3];
		}
	}
	
	return data;
}


+ (void) initializeBase64
{
	if (self == [NSData class] && ! base64Initialized) {
		memset(base64DecodingTable, 0, ArrayLength(base64DecodingTable));
		for (NSInteger i = 0; i < ArrayLength(base64EncodingTable); i++) {
			base64DecodingTable[base64EncodingTable[i]] = i;
		}
		base64Initialized = YES;
	}
}


- (NSString*) decodeHash: (NSString*) key
{
	if (!key){
		key = AKDefaultEncodeKey;
	}
	return [self decodeHash:key withSeparator:nil];
}

- (NSString*) encodeHash: (NSString*) key
{
	if (!key){
		key = AKDefaultEncodeKey;
	}
	return [self encodeHash:key withSeparator:nil];
}

- (NSString*) decodeHash: (NSString*) key withSeparator:(NSString*)separator
{
	if (!separator){
		separator = AKDefaultSeparator;
	}
	NSData * decoded = [self base64Decode] ;
	NSString * dec = [[NSString alloc] initWithData:decoded encoding:NSUTF8StringEncoding];
	NSArray * elements = [dec componentsSeparatedByString:separator];
	if([elements count ]== 2){
		NSString * msg = [elements objectAtIndex:0];
		
		NSString * md5 = [[NSString stringWithFormat:@"%@%@",msg,key,nil] md5];
		
		if ([md5 isEqual:[elements objectAtIndex:1]]) {
			return msg;
		}
	}
	return nil;	
}

- (NSString*) encodeHash: (NSString*) key withSeparator:(NSString*)separator
{
	if (!separator){
		separator = AKDefaultSeparator;
	}
	
	
	NSString * md5 = [[NSString stringWithFormat:@"%@%@",self,key,nil] md5];
	return [[[NSString stringWithFormat:@"%@%@%@",self,separator,md5,nil] dataUsingEncoding:NSUTF8StringEncoding] base64Encode];
}



- (NSString *)stringByDecodingXMLEntities {
	
	// Find first & and short-cut if we can
	NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
	if (ampIndex == NSNotFound) {
		return [NSString stringWithString:self]; // return copy of string as no & found
	}
	
	// Make result string with some extra capacity.
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:(self.length * 1.25)];
	
	// First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	[scanner setCaseSensitive:YES];
	
	// Boundary characters for scanning unexpected &#... pattern
	NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
	
	// Scan
	do {
		
		// Scan up to the next entity or the end of the string.
		NSString *nonEntityString;
		if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
			[result appendString:nonEntityString];
		}
		if ([scanner isAtEnd]) break;
		
		// Common character entity references first
		if ([scanner scanString:@"&amp;" intoString:NULL])
			[result appendString:@"&"];
		else if ([scanner scanString:@"&apos;" intoString:NULL])
			[result appendString:@"'"];
		else if ([scanner scanString:@"&quot;" intoString:NULL])
			[result appendString:@"\""];
		else if ([scanner scanString:@"&lt;" intoString:NULL])
			[result appendString:@"<"];
		else if ([scanner scanString:@"&gt;" intoString:NULL])
			[result appendString:@">"];
		else if ([scanner scanString:@"&nbsp;" intoString:NULL])
			[result appendFormat:@"%C", 160];
		else if ([scanner scanString:@"&laquo;" intoString:NULL])
			[result appendFormat:@"%C", 171];
		else if ([scanner scanString:@"&raquo;" intoString:NULL])
			[result appendFormat:@"%C", 187];
		else if ([scanner scanString:@"&ndash;" intoString:NULL])
			[result appendFormat:@"%C", 8211];
		else if ([scanner scanString:@"&mdash;" intoString:NULL])
			[result appendFormat:@"%C", 8212];
		else if ([scanner scanString:@"&lsquo;" intoString:NULL])
			[result appendFormat:@"%C", 8216];
		else if ([scanner scanString:@"&rsquo;" intoString:NULL])
			[result appendFormat:@"%C", 8217];
		else if ([scanner scanString:@"&ldquo;" intoString:NULL])
			[result appendFormat:@"%C", 8220];
		else if ([scanner scanString:@"&rdquo;" intoString:NULL])
			[result appendFormat:@"%C", 8221];
		else if ([scanner scanString:@"&bull;" intoString:NULL])
			[result appendFormat:@"%C", 8226];
		else if ([scanner scanString:@"&hellip;" intoString:NULL])
			[result appendFormat:@"%C", 8230];
		
		// Numeric character entity references
		else if ([scanner scanString:@"&#" intoString:NULL]) {
			
			// Entity
			BOOL gotNumber;
			unsigned charCode;
			NSString *xForHex = @"";
			
			// Is it hex or decimal?
			if ([scanner scanString:@"x" intoString:&xForHex]) {
				gotNumber = [scanner scanHexInt:&charCode];
			} else {
				gotNumber = [scanner scanInt:(int*)&charCode];
			}
			
			// Process
			if (gotNumber) {
				
				// Append character
				[result appendFormat:@"%C", (unichar)charCode];
				[scanner scanString:@";" intoString:NULL];
				
			} else {
				
				// Failed to get a number so append to result and log error
				NSString *unknownEntity = @"";
				[scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
				[result appendFormat:@"&#%@%@", xForHex, unknownEntity]; // Append exact same string
				
			}
			
			// Quick check for isolated & with a space after to speed up checks
		} else if ([scanner scanString:@"& " intoString:NULL])
			[result appendString:@"& "];	
		
		// No so common character entity references
		else if ([scanner scanString:@"&iexcl;" intoString:NULL])
			[result appendFormat:@"%C", 161];
		else if ([scanner scanString:@"&cent;" intoString:NULL])
			[result appendFormat:@"%C", 162];
		else if ([scanner scanString:@"&pound;" intoString:NULL])
			[result appendFormat:@"%C", 163];
		else if ([scanner scanString:@"&curren;" intoString:NULL])
			[result appendFormat:@"%C", 164];
		else if ([scanner scanString:@"&yen;" intoString:NULL])
			[result appendFormat:@"%C", 165];
		else if ([scanner scanString:@"&brvbar;" intoString:NULL])
			[result appendFormat:@"%C", 166];
		else if ([scanner scanString:@"&sect;" intoString:NULL])
			[result appendFormat:@"%C", 167];
		else if ([scanner scanString:@"&uml;" intoString:NULL])
			[result appendFormat:@"%C", 168];
		else if ([scanner scanString:@"&copy;" intoString:NULL])
			[result appendFormat:@"%C", 169];
		else if ([scanner scanString:@"&ordf;" intoString:NULL])
			[result appendFormat:@"%C", 170];
		else if ([scanner scanString:@"&not;" intoString:NULL])
			[result appendFormat:@"%C", 172];
		else if ([scanner scanString:@"&shy;" intoString:NULL])
			[result appendFormat:@"%C", 173];
		else if ([scanner scanString:@"&reg;" intoString:NULL])
			[result appendFormat:@"%C", 174];
		else if ([scanner scanString:@"&macr;" intoString:NULL])
			[result appendFormat:@"%C", 175];
		else if ([scanner scanString:@"&deg;" intoString:NULL])
			[result appendFormat:@"%C", 176];
		else if ([scanner scanString:@"&plusmn;" intoString:NULL])
			[result appendFormat:@"%C", 177];
		else if ([scanner scanString:@"&sup2;" intoString:NULL])
			[result appendFormat:@"%C", 178];
		else if ([scanner scanString:@"&sup3;" intoString:NULL])
			[result appendFormat:@"%C", 179];
		else if ([scanner scanString:@"&acute;" intoString:NULL])
			[result appendFormat:@"%C", 180];
		else if ([scanner scanString:@"&micro;" intoString:NULL])
			[result appendFormat:@"%C", 181];
		else if ([scanner scanString:@"&para;" intoString:NULL])
			[result appendFormat:@"%C", 182];
		else if ([scanner scanString:@"&middot;" intoString:NULL])
			[result appendFormat:@"%C", 183];
		else if ([scanner scanString:@"&cedil;" intoString:NULL])
			[result appendFormat:@"%C", 184];
		else if ([scanner scanString:@"&sup1;" intoString:NULL])
			[result appendFormat:@"%C", 185];
		else if ([scanner scanString:@"&ordm;" intoString:NULL])
			[result appendFormat:@"%C", 186];
		else if ([scanner scanString:@"&frac14;" intoString:NULL])
			[result appendFormat:@"%C", 188];
		else if ([scanner scanString:@"&frac12;" intoString:NULL])
			[result appendFormat:@"%C", 189];
		else if ([scanner scanString:@"&frac34;" intoString:NULL])
			[result appendFormat:@"%C", 190];
		else if ([scanner scanString:@"&iquest;" intoString:NULL])
			[result appendFormat:@"%C", 191];
		else if ([scanner scanString:@"&Agrave;" intoString:NULL])
			[result appendFormat:@"%C", 192];
		else if ([scanner scanString:@"&Aacute;" intoString:NULL])
			[result appendFormat:@"%C", 193];
		else if ([scanner scanString:@"&Acirc;" intoString:NULL])
			[result appendFormat:@"%C", 194];
		else if ([scanner scanString:@"&Atilde;" intoString:NULL])
			[result appendFormat:@"%C", 195];
		else if ([scanner scanString:@"&Auml;" intoString:NULL])
			[result appendFormat:@"%C", 196];
		else if ([scanner scanString:@"&Aring;" intoString:NULL])
			[result appendFormat:@"%C", 197];
		else if ([scanner scanString:@"&AElig;" intoString:NULL])
			[result appendFormat:@"%C", 198];
		else if ([scanner scanString:@"&Ccedil;" intoString:NULL])
			[result appendFormat:@"%C", 199];
		else if ([scanner scanString:@"&Egrave;" intoString:NULL])
			[result appendFormat:@"%C", 200];
		else if ([scanner scanString:@"&Eacute;" intoString:NULL])
			[result appendFormat:@"%C", 201];
		else if ([scanner scanString:@"&Ecirc;" intoString:NULL])
			[result appendFormat:@"%C", 202];
		else if ([scanner scanString:@"&Euml;" intoString:NULL])
			[result appendFormat:@"%C", 203];
		else if ([scanner scanString:@"&Igrave;" intoString:NULL])
			[result appendFormat:@"%C", 204];
		else if ([scanner scanString:@"&Iacute;" intoString:NULL])
			[result appendFormat:@"%C", 205];
		else if ([scanner scanString:@"&Icirc;" intoString:NULL])
			[result appendFormat:@"%C", 206];
		else if ([scanner scanString:@"&Iuml;" intoString:NULL])
			[result appendFormat:@"%C", 207];
		else if ([scanner scanString:@"&ETH;" intoString:NULL])
			[result appendFormat:@"%C", 208];
		else if ([scanner scanString:@"&Ntilde;" intoString:NULL])
			[result appendFormat:@"%C", 209];
		else if ([scanner scanString:@"&Ograve;" intoString:NULL])
			[result appendFormat:@"%C", 210];
		else if ([scanner scanString:@"&Oacute;" intoString:NULL])
			[result appendFormat:@"%C", 211];
		else if ([scanner scanString:@"&Ocirc;" intoString:NULL])
			[result appendFormat:@"%C", 212];
		else if ([scanner scanString:@"&Otilde;" intoString:NULL])
			[result appendFormat:@"%C", 213];
		else if ([scanner scanString:@"&Ouml;" intoString:NULL])
			[result appendFormat:@"%C", 214];
		else if ([scanner scanString:@"&times;" intoString:NULL])
			[result appendFormat:@"%C", 215];
		else if ([scanner scanString:@"&Oslash;" intoString:NULL])
			[result appendFormat:@"%C", 216];
		else if ([scanner scanString:@"&Ugrave;" intoString:NULL])
			[result appendFormat:@"%C", 217];
		else if ([scanner scanString:@"&Uacute;" intoString:NULL])
			[result appendFormat:@"%C", 218];
		else if ([scanner scanString:@"&Ucirc;" intoString:NULL])
			[result appendFormat:@"%C", 219];
		else if ([scanner scanString:@"&Uuml;" intoString:NULL])
			[result appendFormat:@"%C", 220];
		else if ([scanner scanString:@"&Yacute;" intoString:NULL])
			[result appendFormat:@"%C", 221];
		else if ([scanner scanString:@"&THORN;" intoString:NULL])
			[result appendFormat:@"%C", 222];
		else if ([scanner scanString:@"&szlig;" intoString:NULL])
			[result appendFormat:@"%C", 223];
		else if ([scanner scanString:@"&agrave;" intoString:NULL])
			[result appendFormat:@"%C", 224];
		else if ([scanner scanString:@"&aacute;" intoString:NULL])
			[result appendFormat:@"%C", 225];
		else if ([scanner scanString:@"&acirc;" intoString:NULL])
			[result appendFormat:@"%C", 226];
		else if ([scanner scanString:@"&atilde;" intoString:NULL])
			[result appendFormat:@"%C", 227];
		else if ([scanner scanString:@"&auml;" intoString:NULL])
			[result appendFormat:@"%C", 228];
		else if ([scanner scanString:@"&aring;" intoString:NULL])
			[result appendFormat:@"%C", 229];
		else if ([scanner scanString:@"&aelig;" intoString:NULL])
			[result appendFormat:@"%C", 230];
		else if ([scanner scanString:@"&ccedil;" intoString:NULL])
			[result appendFormat:@"%C", 231];
		else if ([scanner scanString:@"&egrave;" intoString:NULL])
			[result appendFormat:@"%C", 232];
		else if ([scanner scanString:@"&eacute;" intoString:NULL])
			[result appendFormat:@"%C", 233];
		else if ([scanner scanString:@"&ecirc;" intoString:NULL])
			[result appendFormat:@"%C", 234];
		else if ([scanner scanString:@"&euml;" intoString:NULL])
			[result appendFormat:@"%C", 235];
		else if ([scanner scanString:@"&igrave;" intoString:NULL])
			[result appendFormat:@"%C", 236];
		else if ([scanner scanString:@"&iacute;" intoString:NULL])
			[result appendFormat:@"%C", 237];
		else if ([scanner scanString:@"&icirc;" intoString:NULL])
			[result appendFormat:@"%C", 238];
		else if ([scanner scanString:@"&iuml;" intoString:NULL])
			[result appendFormat:@"%C", 239];
		else if ([scanner scanString:@"&eth;" intoString:NULL])
			[result appendFormat:@"%C", 240];
		else if ([scanner scanString:@"&ntilde;" intoString:NULL])
			[result appendFormat:@"%C", 241];
		else if ([scanner scanString:@"&ograve;" intoString:NULL])
			[result appendFormat:@"%C", 242];
		else if ([scanner scanString:@"&oacute;" intoString:NULL])
			[result appendFormat:@"%C", 243];
		else if ([scanner scanString:@"&ocirc;" intoString:NULL])
			[result appendFormat:@"%C", 244];
		else if ([scanner scanString:@"&otilde;" intoString:NULL])
			[result appendFormat:@"%C", 245];
		else if ([scanner scanString:@"&ouml;" intoString:NULL])
			[result appendFormat:@"%C", 246];
		else if ([scanner scanString:@"&divide;" intoString:NULL])
			[result appendFormat:@"%C", 247];
		else if ([scanner scanString:@"&oslash;" intoString:NULL])
			[result appendFormat:@"%C", 248];
		else if ([scanner scanString:@"&ugrave;" intoString:NULL])
			[result appendFormat:@"%C", 249];
		else if ([scanner scanString:@"&uacute;" intoString:NULL])
			[result appendFormat:@"%C", 250];
		else if ([scanner scanString:@"&ucirc;" intoString:NULL])
			[result appendFormat:@"%C", 251];
		else if ([scanner scanString:@"&uuml;" intoString:NULL])
			[result appendFormat:@"%C", 252];
		else if ([scanner scanString:@"&yacute;" intoString:NULL])
			[result appendFormat:@"%C", 253];
		else if ([scanner scanString:@"&thorn;" intoString:NULL])
			[result appendFormat:@"%C", 254];
		else if ([scanner scanString:@"&yuml;" intoString:NULL])
			[result appendFormat:@"%C", 255];
		else if ([scanner scanString:@"&OElig;" intoString:NULL])
			[result appendFormat:@"%C", 338];
		else if ([scanner scanString:@"&oelig;" intoString:NULL])
			[result appendFormat:@"%C", 339];
		else if ([scanner scanString:@"&Scaron;" intoString:NULL])
			[result appendFormat:@"%C", 352];
		else if ([scanner scanString:@"&scaron;" intoString:NULL])
			[result appendFormat:@"%C", 353];
		else if ([scanner scanString:@"&Yuml;" intoString:NULL])
			[result appendFormat:@"%C", 376];
		else if ([scanner scanString:@"&fnof;" intoString:NULL])
			[result appendFormat:@"%C", 402];
		else if ([scanner scanString:@"&circ;" intoString:NULL])
			[result appendFormat:@"%C", 710];
		else if ([scanner scanString:@"&tilde;" intoString:NULL])
			[result appendFormat:@"%C", 732];
		else if ([scanner scanString:@"&Alpha;" intoString:NULL])
			[result appendFormat:@"%C", 913];
		else if ([scanner scanString:@"&Beta;" intoString:NULL])
			[result appendFormat:@"%C", 914];
		else if ([scanner scanString:@"&Gamma;" intoString:NULL])
			[result appendFormat:@"%C", 915];
		else if ([scanner scanString:@"&Delta;" intoString:NULL])
			[result appendFormat:@"%C", 916];
		else if ([scanner scanString:@"&Epsilon;" intoString:NULL])
			[result appendFormat:@"%C", 917];
		else if ([scanner scanString:@"&Zeta;" intoString:NULL])
			[result appendFormat:@"%C", 918];
		else if ([scanner scanString:@"&Eta;" intoString:NULL])
			[result appendFormat:@"%C", 919];
		else if ([scanner scanString:@"&Theta;" intoString:NULL])
			[result appendFormat:@"%C", 920];
		else if ([scanner scanString:@"&Iota;" intoString:NULL])
			[result appendFormat:@"%C", 921];
		else if ([scanner scanString:@"&Kappa;" intoString:NULL])
			[result appendFormat:@"%C", 922];
		else if ([scanner scanString:@"&Lambda;" intoString:NULL])
			[result appendFormat:@"%C", 923];
		else if ([scanner scanString:@"&Mu;" intoString:NULL])
			[result appendFormat:@"%C", 924];
		else if ([scanner scanString:@"&Nu;" intoString:NULL])
			[result appendFormat:@"%C", 925];
		else if ([scanner scanString:@"&Xi;" intoString:NULL])
			[result appendFormat:@"%C", 926];
		else if ([scanner scanString:@"&Omicron;" intoString:NULL])
			[result appendFormat:@"%C", 927];
		else if ([scanner scanString:@"&Pi;" intoString:NULL])
			[result appendFormat:@"%C", 928];
		else if ([scanner scanString:@"&Rho;" intoString:NULL])
			[result appendFormat:@"%C", 929];
		else if ([scanner scanString:@"&Sigma;" intoString:NULL])
			[result appendFormat:@"%C", 931];
		else if ([scanner scanString:@"&Tau;" intoString:NULL])
			[result appendFormat:@"%C", 932];
		else if ([scanner scanString:@"&Upsilon;" intoString:NULL])
			[result appendFormat:@"%C", 933];
		else if ([scanner scanString:@"&Phi;" intoString:NULL])
			[result appendFormat:@"%C", 934];
		else if ([scanner scanString:@"&Chi;" intoString:NULL])
			[result appendFormat:@"%C", 935];
		else if ([scanner scanString:@"&Psi;" intoString:NULL])
			[result appendFormat:@"%C", 936];
		else if ([scanner scanString:@"&Omega;" intoString:NULL])
			[result appendFormat:@"%C", 937];
		else if ([scanner scanString:@"&alpha;" intoString:NULL])
			[result appendFormat:@"%C", 945];
		else if ([scanner scanString:@"&beta;" intoString:NULL])
			[result appendFormat:@"%C", 946];
		else if ([scanner scanString:@"&gamma;" intoString:NULL])
			[result appendFormat:@"%C", 947];
		else if ([scanner scanString:@"&delta;" intoString:NULL])
			[result appendFormat:@"%C", 948];
		else if ([scanner scanString:@"&epsilon;" intoString:NULL])
			[result appendFormat:@"%C", 949];
		else if ([scanner scanString:@"&zeta;" intoString:NULL])
			[result appendFormat:@"%C", 950];
		else if ([scanner scanString:@"&eta;" intoString:NULL])
			[result appendFormat:@"%C", 951];
		else if ([scanner scanString:@"&theta;" intoString:NULL])
			[result appendFormat:@"%C", 952];
		else if ([scanner scanString:@"&iota;" intoString:NULL])
			[result appendFormat:@"%C", 953];
		else if ([scanner scanString:@"&kappa;" intoString:NULL])
			[result appendFormat:@"%C", 954];
		else if ([scanner scanString:@"&lambda;" intoString:NULL])
			[result appendFormat:@"%C", 955];
		else if ([scanner scanString:@"&mu;" intoString:NULL])
			[result appendFormat:@"%C", 956];
		else if ([scanner scanString:@"&nu;" intoString:NULL])
			[result appendFormat:@"%C", 957];
		else if ([scanner scanString:@"&xi;" intoString:NULL])
			[result appendFormat:@"%C", 958];
		else if ([scanner scanString:@"&omicron;" intoString:NULL])
			[result appendFormat:@"%C", 959];
		else if ([scanner scanString:@"&pi;" intoString:NULL])
			[result appendFormat:@"%C", 960];
		else if ([scanner scanString:@"&rho;" intoString:NULL])
			[result appendFormat:@"%C", 961];
		else if ([scanner scanString:@"&sigmaf;" intoString:NULL])
			[result appendFormat:@"%C", 962];
		else if ([scanner scanString:@"&sigma;" intoString:NULL])
			[result appendFormat:@"%C", 963];
		else if ([scanner scanString:@"&tau;" intoString:NULL])
			[result appendFormat:@"%C", 964];
		else if ([scanner scanString:@"&upsilon;" intoString:NULL])
			[result appendFormat:@"%C", 965];
		else if ([scanner scanString:@"&phi;" intoString:NULL])
			[result appendFormat:@"%C", 966];
		else if ([scanner scanString:@"&chi;" intoString:NULL])
			[result appendFormat:@"%C", 967];
		else if ([scanner scanString:@"&psi;" intoString:NULL])
			[result appendFormat:@"%C", 968];
		else if ([scanner scanString:@"&omega;" intoString:NULL])
			[result appendFormat:@"%C", 969];
		else if ([scanner scanString:@"&thetasym;" intoString:NULL])
			[result appendFormat:@"%C", 977];
		else if ([scanner scanString:@"&upsih;" intoString:NULL])
			[result appendFormat:@"%C", 978];
		else if ([scanner scanString:@"&piv;" intoString:NULL])
			[result appendFormat:@"%C", 982];
		else if ([scanner scanString:@"&ensp;" intoString:NULL])
			[result appendFormat:@"%C", 8194];
		else if ([scanner scanString:@"&emsp;" intoString:NULL])
			[result appendFormat:@"%C", 8195];
		else if ([scanner scanString:@"&thinsp;" intoString:NULL])
			[result appendFormat:@"%C", 8201];
		else if ([scanner scanString:@"&zwnj;" intoString:NULL])
			[result appendFormat:@"%C", 8204];
		else if ([scanner scanString:@"&zwj;" intoString:NULL])
			[result appendFormat:@"%C", 8205];
		else if ([scanner scanString:@"&lrm;" intoString:NULL])
			[result appendFormat:@"%C", 8206];
		else if ([scanner scanString:@"&rlm;" intoString:NULL])
			[result appendFormat:@"%C", 8207];
		else if ([scanner scanString:@"&sbquo;" intoString:NULL])
			[result appendFormat:@"%C", 8218];
		else if ([scanner scanString:@"&bdquo;" intoString:NULL])
			[result appendFormat:@"%C", 8222];
		else if ([scanner scanString:@"&dagger;" intoString:NULL])
			[result appendFormat:@"%C", 8224];
		else if ([scanner scanString:@"&Dagger;" intoString:NULL])
			[result appendFormat:@"%C", 8225];
		else if ([scanner scanString:@"&permil;" intoString:NULL])
			[result appendFormat:@"%C", 8240];
		else if ([scanner scanString:@"&prime;" intoString:NULL])
			[result appendFormat:@"%C", 8242];
		else if ([scanner scanString:@"&Prime;" intoString:NULL])
			[result appendFormat:@"%C", 8243];
		else if ([scanner scanString:@"&lsaquo;" intoString:NULL])
			[result appendFormat:@"%C", 8249];
		else if ([scanner scanString:@"&rsaquo;" intoString:NULL])
			[result appendFormat:@"%C", 8250];
		else if ([scanner scanString:@"&oline;" intoString:NULL])
			[result appendFormat:@"%C", 8254];
		else if ([scanner scanString:@"&frasl;" intoString:NULL])
			[result appendFormat:@"%C", 8260];
		else if ([scanner scanString:@"&euro;" intoString:NULL])
			[result appendFormat:@"%C", 8364];
		else if ([scanner scanString:@"&image;" intoString:NULL])
			[result appendFormat:@"%C", 8465];
		else if ([scanner scanString:@"&weierp;" intoString:NULL])
			[result appendFormat:@"%C", 8472];
		else if ([scanner scanString:@"&real;" intoString:NULL])
			[result appendFormat:@"%C", 8476];
		else if ([scanner scanString:@"&trade;" intoString:NULL])
			[result appendFormat:@"%C", 8482];
		else if ([scanner scanString:@"&alefsym;" intoString:NULL])
			[result appendFormat:@"%C", 8501];
		else if ([scanner scanString:@"&larr;" intoString:NULL])
			[result appendFormat:@"%C", 8592];
		else if ([scanner scanString:@"&uarr;" intoString:NULL])
			[result appendFormat:@"%C", 8593];
		else if ([scanner scanString:@"&rarr;" intoString:NULL])
			[result appendFormat:@"%C", 8594];
		else if ([scanner scanString:@"&darr;" intoString:NULL])
			[result appendFormat:@"%C", 8595];
		else if ([scanner scanString:@"&harr;" intoString:NULL])
			[result appendFormat:@"%C", 8596];
		else if ([scanner scanString:@"&crarr;" intoString:NULL])
			[result appendFormat:@"%C", 8629];
		else if ([scanner scanString:@"&lArr;" intoString:NULL])
			[result appendFormat:@"%C", 8656];
		else if ([scanner scanString:@"&uArr;" intoString:NULL])
			[result appendFormat:@"%C", 8657];
		else if ([scanner scanString:@"&rArr;" intoString:NULL])
			[result appendFormat:@"%C", 8658];
		else if ([scanner scanString:@"&dArr;" intoString:NULL])
			[result appendFormat:@"%C", 8659];
		else if ([scanner scanString:@"&hArr;" intoString:NULL])
			[result appendFormat:@"%C", 8660];
		else if ([scanner scanString:@"&forall;" intoString:NULL])
			[result appendFormat:@"%C", 8704];
		else if ([scanner scanString:@"&part;" intoString:NULL])
			[result appendFormat:@"%C", 8706];
		else if ([scanner scanString:@"&exist;" intoString:NULL])
			[result appendFormat:@"%C", 8707];
		else if ([scanner scanString:@"&empty;" intoString:NULL])
			[result appendFormat:@"%C", 8709];
		else if ([scanner scanString:@"&nabla;" intoString:NULL])
			[result appendFormat:@"%C", 8711];
		else if ([scanner scanString:@"&isin;" intoString:NULL])
			[result appendFormat:@"%C", 8712];
		else if ([scanner scanString:@"&notin;" intoString:NULL])
			[result appendFormat:@"%C", 8713];
		else if ([scanner scanString:@"&ni;" intoString:NULL])
			[result appendFormat:@"%C", 8715];
		else if ([scanner scanString:@"&prod;" intoString:NULL])
			[result appendFormat:@"%C", 8719];
		else if ([scanner scanString:@"&sum;" intoString:NULL])
			[result appendFormat:@"%C", 8721];
		else if ([scanner scanString:@"&minus;" intoString:NULL])
			[result appendFormat:@"%C", 8722];
		else if ([scanner scanString:@"&lowast;" intoString:NULL])
			[result appendFormat:@"%C", 8727];
		else if ([scanner scanString:@"&radic;" intoString:NULL])
			[result appendFormat:@"%C", 8730];
		else if ([scanner scanString:@"&prop;" intoString:NULL])
			[result appendFormat:@"%C", 8733];
		else if ([scanner scanString:@"&infin;" intoString:NULL])
			[result appendFormat:@"%C", 8734];
		else if ([scanner scanString:@"&ang;" intoString:NULL])
			[result appendFormat:@"%C", 8736];
		else if ([scanner scanString:@"&and;" intoString:NULL])
			[result appendFormat:@"%C", 8743];
		else if ([scanner scanString:@"&or;" intoString:NULL])
			[result appendFormat:@"%C", 8744];
		else if ([scanner scanString:@"&cap;" intoString:NULL])
			[result appendFormat:@"%C", 8745];
		else if ([scanner scanString:@"&cup;" intoString:NULL])
			[result appendFormat:@"%C", 8746];
		else if ([scanner scanString:@"&int;" intoString:NULL])
			[result appendFormat:@"%C", 8747];
		else if ([scanner scanString:@"&there4;" intoString:NULL])
			[result appendFormat:@"%C", 8756];
		else if ([scanner scanString:@"&sim;" intoString:NULL])
			[result appendFormat:@"%C", 8764];
		else if ([scanner scanString:@"&cong;" intoString:NULL])
			[result appendFormat:@"%C", 8773];
		else if ([scanner scanString:@"&asymp;" intoString:NULL])
			[result appendFormat:@"%C", 8776];
		else if ([scanner scanString:@"&ne;" intoString:NULL])
			[result appendFormat:@"%C", 8800];
		else if ([scanner scanString:@"&equiv;" intoString:NULL])
			[result appendFormat:@"%C", 8801];
		else if ([scanner scanString:@"&le;" intoString:NULL])
			[result appendFormat:@"%C", 8804];
		else if ([scanner scanString:@"&ge;" intoString:NULL])
			[result appendFormat:@"%C", 8805];
		else if ([scanner scanString:@"&sub;" intoString:NULL])
			[result appendFormat:@"%C", 8834];
		else if ([scanner scanString:@"&sup;" intoString:NULL])
			[result appendFormat:@"%C", 8835];
		else if ([scanner scanString:@"&nsub;" intoString:NULL])
			[result appendFormat:@"%C", 8836];
		else if ([scanner scanString:@"&sube;" intoString:NULL])
			[result appendFormat:@"%C", 8838];
		else if ([scanner scanString:@"&supe;" intoString:NULL])
			[result appendFormat:@"%C", 8839];
		else if ([scanner scanString:@"&oplus;" intoString:NULL])
			[result appendFormat:@"%C", 8853];
		else if ([scanner scanString:@"&otimes;" intoString:NULL])
			[result appendFormat:@"%C", 8855];
		else if ([scanner scanString:@"&perp;" intoString:NULL])
			[result appendFormat:@"%C", 8869];
		else if ([scanner scanString:@"&sdot;" intoString:NULL])
			[result appendFormat:@"%C", 8901];
		else if ([scanner scanString:@"&lceil;" intoString:NULL])
			[result appendFormat:@"%C", 8968];
		else if ([scanner scanString:@"&rceil;" intoString:NULL])
			[result appendFormat:@"%C", 8969];
		else if ([scanner scanString:@"&lfloor;" intoString:NULL])
			[result appendFormat:@"%C", 8970];
		else if ([scanner scanString:@"&rfloor;" intoString:NULL])
			[result appendFormat:@"%C", 8971];
		else if ([scanner scanString:@"&lang;" intoString:NULL])
			[result appendFormat:@"%C", 9001];
		else if ([scanner scanString:@"&rang;" intoString:NULL])
			[result appendFormat:@"%C", 9002];
		else if ([scanner scanString:@"&loz;" intoString:NULL])
			[result appendFormat:@"%C", 9674];
		else if ([scanner scanString:@"&spades;" intoString:NULL])
			[result appendFormat:@"%C", 9824];
		else if ([scanner scanString:@"&clubs;" intoString:NULL])
			[result appendFormat:@"%C", 9827];
		else if ([scanner scanString:@"&hearts;" intoString:NULL])
			[result appendFormat:@"%C", 9829];
		else if ([scanner scanString:@"&diams;" intoString:NULL])
			[result appendFormat:@"%C", 9830];
		else {
			
			// Must be an isolated & with no space after
			NSString *amp;
			[scanner scanString:@"&" intoString:&amp]; // isolated & symbol
			[result appendString:amp];
			
		}
		
    } while (![scanner isAtEnd]);
	
	// Finish
	NSString *resultingString = [NSString stringWithString:result];
	return resultingString;
	
}
// Needs more work to encode more entities
- (NSString *)stringByEncodingXMLEntities {
	
	// Scanner
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *characters = [NSCharacterSet characterSetWithCharactersInString:@"&\"'<>"];
	[scanner setCharactersToBeSkipped:nil];
	
	// Scan
	while (![scanner isAtEnd]) {
		
		// Get non new line or whitespace characters
		temp = nil;
		[scanner scanUpToCharactersFromSet:characters intoString:&temp];
		if (temp) [result appendString:temp];
		
		// Replace with encoded entities
		if ([scanner scanString:@"&" intoString:NULL])
			[result appendString:@"&amp;"];
		else if ([scanner scanString:@"'" intoString:NULL])
			[result appendString:@"&apos;"];
		else if ([scanner scanString:@"\"" intoString:NULL])
			[result appendString:@"&quot;"];
		else if ([scanner scanString:@"<" intoString:NULL])
			[result appendString:@"&lt;"];
		else if ([scanner scanString:@">" intoString:NULL])
			[result appendString:@"&gt;"];
		
	}
	
	// Cleanup
	
	// Return
	NSString *retString = [NSString stringWithString:result];
	return retString;
	
}

- (NSString *)stringByStrippingTags {
	
	// Find first & and short-cut if we can
	NSUInteger ampIndex = [self rangeOfString:@"<" options:NSLiteralSearch].location;
	if (ampIndex == NSNotFound) {
		return [NSString stringWithString:self]; // return copy of string as no tags found
	}
	
	// Scan and find all tags
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableSet *tags = [[NSMutableSet alloc] init];
	NSString *tag;
	do {
		
		// Scan up to <
		tag = nil;
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&tag];
		
		// Add to set
		if (tag) {
			NSString *t = [[NSString alloc] initWithFormat:@"%@>", tag];
			[tags addObject:t];
		}
		
	} while (![scanner isAtEnd]);
	
	// Strings
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	NSString *finalString;
	
	// Replace tags
	NSString *replacement;
	for (NSString *t in tags) {
		
		// Replace tag with space unless it's an inline element
		replacement = @" ";
		if ([t isEqualToString:@"<a>"] ||
			[t isEqualToString:@"</a>"] ||
			[t isEqualToString:@"<span>"] ||
			[t isEqualToString:@"</span>"] ||
			[t isEqualToString:@"<strong>"] ||
			[t isEqualToString:@"</strong>"] ||
			[t isEqualToString:@"<em>"] ||
			[t isEqualToString:@"</em>"]) {
			replacement = @"";
		}
		
		// Replace
		[result replaceOccurrencesOfString:t 
								withString:replacement
								   options:NSLiteralSearch 
									 range:NSMakeRange(0, result.length)];
	}
	
	// Remove multi-spaces and line breaks
	//finalString = [result stringByRemovingNewLinesAndWhitespace];
	finalString = [NSString stringWithString:result];
	
	
	// Cleanup & return
    return finalString;
	
}

- (NSString *)stringByDecodingTags
{
	NSMutableString *temp = [self mutableCopy];
	[temp replaceOccurrencesOfString: @"&gt;"
						  withString:@">"
							 options:NSLiteralSearch
							   range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString: @"&lt;"
						  withString:@"<"
							 options:NSLiteralSearch
							   range:NSMakeRange(0, [temp length])];
	NSString * ret = [NSString stringWithString:temp];
	return ret;
}

- (NSString *)stringWithNewLinesAsBRs {
	
	// Strange New lines:
	//	Next Line, U+0085
	//	Form Feed, U+000C
	//	Line Separator, U+2028
	//	Paragraph Separator, U+2029
	
	// Scanner
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *newLineCharacters = [NSCharacterSet characterSetWithCharactersInString:
										 [NSString stringWithFormat:@"\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029,nil]];
	// Scan
	do {
		
		// Get non new line characters
		temp = nil;
		[scanner scanUpToCharactersFromSet:newLineCharacters intoString:&temp];
		if (temp) [result appendString:temp];
		temp = nil;
		
		// Add <br /> s
		if ([scanner scanString:@"\r\n" intoString:nil]) {
			
			// Combine \r\n into just 1 <br />
			[result appendString:@"<br />"];
			
		} else if ([scanner scanCharactersFromSet:newLineCharacters intoString:&temp]) {
			
			// Scan other new line characters and add <br /> s
			if (temp) {
				for (int i = 0; i < temp.length; i++) {
					[result appendString:@"<br />"];
				}
			}
			
		}
		
	} while (![scanner isAtEnd]);
	
	// Cleanup & return
	NSString *retString = [NSString stringWithString:result];
	return retString;
	
}

- (NSString *)stringByRemovingNewLinesAndWhitespace {
	
	// Strange New lines:
	//	Next Line, U+0085
	//	Form Feed, U+000C
	//	Line Separator, U+2028
	//	Paragraph Separator, U+2029
	
	// Scanner
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
													  [NSString stringWithFormat:@" \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029,nil]];
	// Scan
	while (![scanner isAtEnd]) {
		
		// Get non new line or whitespace characters
		temp = nil;
		[scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
		if (temp) [result appendString:temp];
		
		// Replace with a space
		if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
			if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
				[result appendString:@" "];
		}
		
	}
	
	// Cleanup
	
	// Return
	NSString *retString = [NSString stringWithString:result];
	return retString;
	
}

- (NSString *)ellipsisAt:(int) numChars withSuffix:(NSString*) suffix{
	if(!suffix){
		suffix = @"...";
	}
	
	if(numChars < [self length]){
		NSString * result = [NSString stringWithFormat:@"%@%@",[self substringToIndex:numChars],suffix,nil];
		return result;
	}
	return self;
	
}

- (NSString*) urlencode{
	return [NSString urlencode:self];
}
- (NSString*) urldecode{
	return [NSString urldecode:self];
}

+(NSString *) randomStringWithLength: (int) len 
{
	NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
	for (int i=0; i<len; i++) {
		[randomString appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
	}
		 
	return randomString;
}
		 
+ (NSString*) urldecode: (NSString *) url
{
    NSArray *replaceChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*",@" ", nil];
	
    NSArray *escapeChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A",@"%20", nil];
	
    int len = (int)[escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *ret = [NSString stringWithString: temp];
	
    return ret;
}

+ (NSString*) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*",@" ", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A",@"%20", nil];
	
    int len = (int)[escapeChars count];
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	NSString *ret = [NSString stringWithString: temp];
	
    return ret;
}
- (NSString*) toASCII
{
//	NSString *theString = [NSString stringWithFormat:@"To be continued%C", ellipsis];
	
	
	
	NSData *asciiData = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	NSString *asciiString = [[NSString alloc] initWithData:asciiData encoding:NSASCIIStringEncoding];
	return asciiString;
}
- (NSString *)substringFromChar:(char) from toChar:(char) to
{
//substringWithRange
    int startIndex=-1;
    int toIndex=-1;
    char * str = (char*)[self cStringUsingEncoding:NSUTF8StringEncoding];
    
    for(int i = 0 ; i < [self length];i++){
        ////NSLog(@"char %c ",str[i]);
        if(str[i]==from){
             //NSLog(@"start char found");
            startIndex = i+1;
            break;
        }
    }
    for(int i = startIndex ; i < [self length];i++){
        //NSLog(@"char %c %c",str[i],to);
        if(str[i]==to){
            //NSLog(@"stop char found");
            toIndex = i;
            break;
        }
    }
     //NSLog(@" range : %d, %d, %d",startIndex,toIndex,toIndex-startIndex);
    if(startIndex>0 && toIndex>0){
       
        return [self substringWithRange:NSMakeRange(startIndex, toIndex-startIndex)];
    }
    return nil;
}

+ (BOOL) isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (NSString *) addSlashes{
    NSArray *replaceChars = [NSArray arrayWithObjects:@"''" , nil];
	
    NSArray *escapeChars = [NSArray arrayWithObjects:@"'" , nil];
	
    int len = (int)[escapeChars count];
	 
    NSMutableString *temp = [self mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
    NSString *ret = [NSString stringWithString: temp];
	
    return ret;

}
- (NSInteger) toInt{
	
	return [[self toNumber] intValue];
}

- (NSNumber*) toNumber{
	NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
	NSNumber * i = [nf numberFromString:self];
	return i;
}

+(NSString*) timeFormat:(CGFloat) interval
{
	CGFloat eta = interval;
	NSString * suffix = @"sec.";
	//NSLog(@"%f",eta);
	if (eta > 90){
		eta = eta / 60;
		//NSLog(@"%f",eta);
		suffix = @"min.";
		if(eta > 90){
			eta = eta / 60;
			//NSLog(@"%f",eta);
			suffix = @"h";
		}
	}
	return [NSString stringWithFormat:@"%1.0f %@",eta,suffix,nil];
}

+(NSString*) stringTimeFromDate:(NSDate*) date {

    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"dd MMM HH:mm"];
    NSString * time = [timeFormat stringFromDate:date];
    
    return time;
}
-(NSString*) ucFirst{
	NSString* s1 = [self substringToIndex:1];
	NSString* s2 = [self substringFromIndex:1];
	return [NSString stringWithFormat:@"%@%@",[s1 capitalizedString],s2,nil];
}
@end


@implementation NSData (MyExtensions)
- (NSString*)md5
{
    unsigned char result[16];
    CC_MD5( self.bytes, (int)self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			,nil];  
}
- (NSString*) base64Encode
{
	return [NSData base64Encode:self];
}


+ (NSString*) base64Encode:(NSData*) rawBytes 
{
	return [self base64Encode:(const uint8_t*) rawBytes.bytes length:rawBytes.length];
}


+ (NSString*) base64Encode:(const uint8_t*) input length:(NSInteger) length
{
	[NSData initializeBase64];

	NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t* output = (uint8_t*)data.mutableBytes;

	for (NSInteger i = 0; i < length; i += 3) {
		NSInteger value = 0;
		for (NSInteger j = i; j < (i + 3); j++) {
			value <<= 8;
			
			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}
		
		NSInteger index = (i / 3) * 4;
		output[index + 0] =                    base64EncodingTable[(value >> 18) & 0x3F];
		output[index + 1] =                    base64EncodingTable[(value >> 12) & 0x3F];
		output[index + 2] = (i + 1) < length ? base64EncodingTable[(value >> 6)  & 0x3F] : '=';
		output[index + 3] = (i + 2) < length ? base64EncodingTable[(value >> 0)  & 0x3F] : '=';
	}

	return [[NSString alloc] initWithData:data
								  encoding:NSASCIIStringEncoding];

}




+ (void) initializeBase64
{
	if (self == [NSData class] && ! base64Initialized) {
		memset(base64DecodingTable, 0, ArrayLength(base64DecodingTable));
		for (NSInteger i = 0; i < ArrayLength(base64EncodingTable); i++) {
			base64DecodingTable[base64EncodingTable[i]] = i;
		}
		base64Initialized = YES;
	}
}


@end
