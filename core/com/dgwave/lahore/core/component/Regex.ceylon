import org.joni { Regex, Matcher, Option {\iNONE} }
import java.lang { arrays, ByteArray}
import ceylon.io.charset { utf8, Decoder }
import ceylon.io.buffer { ByteBuffer, newByteBuffer, newByteBufferWithData, newCharacterBufferWithData }
import ceylon.collection { LinkedList }
import org.jcodings { Encoding {asciiToUpper}}

String? toString(ByteBuffer byteBuffer) {	
	Decoder decoder = utf8.newDecoder();
	decoder.decode(byteBuffer);
	return decoder.consumeAvailable();
}

ByteArray toBytes(String s) {
	ByteBuffer byteBuffer = newByteBuffer(s.size * 4); //max
	utf8.newEncoder().encode(newCharacterBufferWithData(s), byteBuffer);
	byteBuffer.flip();
	byteBuffer.resize(byteBuffer.limit);
	return arrays.asByteArray(byteBuffer.bytes());	
}

shared {String*} segments(String tosplit, String pattern) {
	variable {Character*} pat = pattern.characters;
	
	if (pattern.startsWith("/")) {
		pat = pat.skipping(1).takingWhile((Character c) => c != '/');
	}
	
	asciiToUpper(39); // trigger load of module
	
	Regex r = Regex(String(pat));
		
	value result = LinkedList<String>();

	ByteArray bytes = toBytes(tosplit);
    
    Integer begin = 0;
    Integer len = bytes.size;
    Integer range = begin + len;

	Matcher matcher = r.matcher(bytes, begin, range);

    Boolean captures = r.numberOfCaptures() != 0;

    variable Integer end = 0; variable Integer beg = 0;
    variable Boolean lastNull = false;
    variable Integer start = begin;
    while ((end = matcher.search(start, range, \iNONE)) >= 0) {
        if (start == end + begin && matcher.begin == matcher.end) {
            if (len == 0) {
                break;
            } else if (lastNull) {
                if (exists s = toString(newByteBufferWithData(*bytes.array.segment(beg, range - (begin + beg))))) {
                	result.add(s);
            	}
                beg = start - begin;
            } else {
                if (start == range) {
                    start +=1;
                } else {
                	start += range -start;
            	}
                lastNull = true;
                continue;
            }
        } else {
            if (exists s = toString(newByteBufferWithData(*bytes.array.segment(beg, end - beg)))) {
            	result.add(s);
        	}
            beg = matcher.end;
            start = begin + beg;
        }
        lastNull = false;

        if (captures) {
	        for (b->e in zip(matcher.region.beg.array.skipping(1), matcher.region.end.array.skipping(1))) {
	            if (b != -1) {
	            	if (exists s = toString(newByteBufferWithData(*bytes.array.segment(b, e - b)))) {
	            		result.add(s);
	            	}
	        	}
	        }
		}
    }

    if (len > 0 ) {
		if (exists s = toString(newByteBufferWithData(*bytes.array.segment(beg, len - beg)))) {
			result.add(s);
		}
	}

    return result;
}