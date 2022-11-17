public class life {

    public static void main(String[] args){
	String[] dish= {
	    "1011",
	    "0011",
	    "1111",
	    "0000"};
	int gens = 4;
	for(int i= 0;i < gens;i++){
	    System.out.println("Generation " + i + ":");
	    print(dish);
	    dish= life(dish);
	}
    }
 
    public static String[] life(String[] dish){
	String[] newGen= new String[dish.length];
	//each row
	for (int row= 0; row < dish.length; row++){
	    newGen[row]= "";
	    // each char in the row
	    for (int i= 0; i < dish[row].length(); i++){
		// neighbors above
		String above= ""; 
		// neighbors in the same row
		String same= "";
		// neighbors below
		String below= "";
		// all the way on the left
		if (i == 0) {
		    // no one above if on the top row
		    // otherwise grab the neighbors from above
		    above = (row == 0) ? null : 
			dish[row - 1].substring(i,i + 2);
		    same = dish[row].substring(i + 1, i + 2);
		    // no one below if on the bottom row
		    // otherwise grab the neighbors from below
		    below= (row == dish.length - 1) ? null : 
			dish[row + 1].substring(i, i + 2);		    
		} 
		// right
		else if (i == dish[row].length() - 1) { 
		    // no one above if on the top row
		    // otherwise grab the neighbors from above
		    above= (row == 0) ? null : 
			dish[row - 1].substring(i - 1,i + 1);
		    same= dish[row].substring(i - 1, i);
		    // no one below if on the bottom row
		    // otherwise grab the neighbors from below
		    below= (row == dish.length - 1) ? null : 
			dish[row + 1].substring(i - 1, i + 1);
		} 
		// anywhere else
		else { 
		    // no one above if on the top row
		    // otherwise grab the neighbors from above
		    above= (row == 0) ? null : dish[row - 1].substring(i - 1,
								       i + 2);
		    same= dish[row].substring(i - 1, i)
			+ dish[row].substring(i + 1, i + 2);
		    // no one below if on the bottom row
		    // otherwise grab the neighbors from below
		    below= (row == dish.length - 1) ? null : dish[row + 1]
			.substring(i - 1, i + 2);
		}
		int neighbors= getNeighbors(above, same, below);
		if (neighbors < 2 || neighbors > 3) {
		    // <2 or >3 neighbors -> die
		    newGen[row]+= "0"; 
		} else if(neighbors == 3){
		    // 3 neighbors -> spawn/live
		    newGen[row]+= "1"; 
		} else{
		    // 2 neighbors -> stay
		    newGen[row]+= dish[row].charAt(i); 
		}
	    }
	}
	return newGen;
    }
 
    public static int getNeighbors(String above, String same, String below) {
	int ans= 0;
	// no one above
	if (above != null) { 
	    // each neighbor from above
	    for (char x: above.toCharArray()) { 
		// count it if someone is here
		if (x == '1') 
		    ans++; 
	    }
	}
	// two on either side
	for (char x: same.toCharArray()) { 
	    // count it if someone is here
	    if (x == '1') ans++;
	}
	if (below != null) { //no one below
	    // each neighbor below
	    for (char x: below.toCharArray()) { 
		// count it if someone is here
		if(x == '1') 
		    ans++; 
	    }
	}
	return ans;
    }
 
    public static void print(String[] dish){
	for(String s: dish){
	    System.out.println(s);
	}
    }
}
