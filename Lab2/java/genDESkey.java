import java.lang.Math;
import javax.crypto.*;
import java.security.*;
import java.util.*;

public class genDESkey {

    public static void main (String[] args) throws NoSuchAlgorithmException,
						   NoSuchPaddingException,
						   BadPaddingException,
						   IllegalBlockSizeException,
						   InvalidKeyException {

	//Creating a KeyGenerator object
	KeyGenerator keyGen = KeyGenerator.getInstance("DES");	
	//Creating a SecureRandom object
	SecureRandom secRandom = new SecureRandom();	
	//Initializing the KeyGenerator
	keyGen.init(secRandom);
	//Creating/Generating a key
	Key key;
	int i, n;
	Scanner reader = new Scanner(System.in);
	byte [] bitMask = new byte[8];
	// Reading from System.in
	if(args.length == 0){
	    System.out.print("Enter the number of keys you wish to generate: ");
	    n = reader.nextInt();
	    bitMask = genMask(0xffffffffffffffffL);

	} else {
	    n = Integer.parseInt(args[0]);
	    long mask1 = (long) Integer.parseInt(args[1]);
	    //System.out.println(mask1);
	    bitMask = genMask(mask1);
	    //printByteString(bitMask);
	}
	for (i = 0; i < n; i++) {
	    key = keyGen.generateKey();
	    if(args.length == 0){
		System.out.println("key = " + Utils.toHex(key.getEncoded()));
	    }else{
		//System.out.println("key = " + Utils.toHex(key.getEncoded(), 0xfe, bitMask));
		System.out.println(Utils.toHex(key.getEncoded(), 0xfe, bitMask));
	    }
	}
	if(args.length == 0){
	    reader.close();
	}	
    }
    private static byte[] genMask (long mask) {
	int index;
	long temp = (long) Math.pow(2, mask) - 1;
	byte [] byteMask = {0, 0, 0, 0, 0, 0, 0, 0};
	for(index = 0; index < 8; index++){
	    long local;
	    local =  temp >> (8*index) & 0xff;
	    byteMask[7-index] = (byte) local;
	    //byteMask[7-index] =  (byte) ((long) (mask >> (3*index))) & (long) 0xff;
	}
	return byteMask;
    }
    private static void printByteString (byte [] bitMask){
	int i;
	for(i=0; i < bitMask.length; i++){
	    System.out.print(bitMask[i] + ", ");
	}
	System.out.println();
    }
}

class Utils {
    
    private static String digits = "0123456789abcdef";
    
    /**
     * Return length many bytes of the passed in byte array as a hex string.
     * 
     * @param data the bytes to be converted.
     * @param length the number of bytes in the data block to be converted.
     * @return a hex representation of length bytes of data.
     */
    public static String toHex(byte[] data, int length, int parityMask, byte[] bitMask)  {
        StringBuffer  buf = new StringBuffer();
        for (int i = 0; i != length; i++) {
            int v = data[i] & parityMask & bitMask[i];
	    // compute parity
	    int parity = 0;
	    for(int j = 0; j < 8; j++) {
		int bit = (v >> j) & 1;
		parity += bit;
	    }
	    parity = (parity+1) % 2;
	    v = v + parity;
	    // done compute parity
	    //int v = data[i] & parityMask;
            buf.append(digits.charAt(v >> 4));
            buf.append(digits.charAt(v & 0xf));
        }        
        return buf.toString();
    }

    
    /**
     * Return the passed in byte array as a hex string.
     * 
     * @param data the bytes to be converted.
     * @return a hex representation of data.
     */
    public static String toHex(byte[] data) {
	byte [] bitMask = {-1, -1, -1, -1, -1, -1, -1, -1};
        return toHex(data, data.length, 0xff, bitMask);
    }

    public static String toHex(byte[] data, int parityMask, byte[] bitMask) {
        return toHex(data, data.length, parityMask, bitMask);
    }
}

