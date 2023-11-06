import java.util.Random;
import java.util.Scanner;

//
// A Simon Game in Java
//
public class simon {

    public static void main(String[] args) {
        char playAgain;
        Random generator = new Random();
        Scanner kb = new Scanner(System.in);

        int highScore = 0;
        int lowScore = 0;
        int scoreSum = 0;
        int gamesPlayed = 0;

        // Runs on each GAME
        do {
            gamesPlayed++;
            displayInstructions();
            kb.nextLine(); //User hits enter when ready to begin. This captures that enter.

            // initialize game info
            // gameNum must be a string because the game can
	    // easily exceed Java's maximum value for an int
            String gameNum = "";
            String userGuess;
            int score = 0;


            //// Runs on each GUESS
            do {
                // add onto game num
                gameNum = updateGameNum(gameNum, generator);

                // display game number and pause
                displayGameNum(gameNum);

                // make number disappear
                makeNumVanish();

                // get user's guess
                userGuess = getUsersGuess(kb);

                // increment score and scoreSum on each guess if the user got it right
                if (userGotItRight(userGuess, gameNum)) {
                    score++;
                    scoreSum++;
                }

            } while (userGotItRight(userGuess, gameNum));

            // Calculate the updated high and low scores after each game.
            if (highScore == 0 || score > highScore)
                highScore = score;
            if (lowScore == 0 || score < lowScore)
                lowScore = score;

            // Calculate the average after each game.
            double average = (double) scoreSum / gamesPlayed;

            // Display the statistics after each game.
            displayStats(userGuess, gameNum, highScore, lowScore, gamesPlayed, average);

            System.out.print("Do you want to play again? y/n ");
            try {
                playAgain = kb.nextLine().toLowerCase().charAt(0);
            } catch (Exception e) {
                playAgain = 'y';
            }

        } while (playAgain != 'n');

    }

    /**
     * If the user guess has the same number of digits as the game
       number, this method loops through the guess and
     * returns how many digits in the user guess differ from it.
     *
     * @param userGuess The user guess.
     * @param gameNum   The game number.
     * @return The number of digits in the guess that are different from the game number.
     */
    private static int getNumberOffBy(String userGuess, String gameNum) {
        int count = 0;
        for (int i = 0; i < userGuess.length(); i++) {
            if (userGuess.charAt(i) != gameNum.charAt(i)) {
                count++;
            }
        }
        return count;
    }

    /**
     * Adds commas to a String.
     *
     * @param number The number as a String
     * @return the number String with commas added
     */
    private static String addCommas(String number) {
        int count = 0;
        StringBuilder builder = new StringBuilder();
        for (int i = number.length() - 1; i >= 0; i--) {
            if (count > 0 && count % 3 == 0) {
                builder.append(",");
                builder.append(number.charAt(i));
                count++;
            } else {
                builder.append(number.charAt(i));
                count++;
            }
        }
        return builder.reverse().toString();
    }

    /**
     * Displays the stats for the game.
     *
     * @param userGuess  the user guess
     * @param gameNumber the game number
     * @param high       the high score
     * @param low        the low score
     * @param games      the number of games played
     * @param avg        the user's average score
     */
    private static void displayStats(String userGuess, String gameNumber, int high, int low, int games, double avg) {
        int gameNumberCount = gameNumber.length();
        int guessNumberCount = userGuess.length();

        System.out.println();
        System.out.println("WRONG! You lost when the number was " + gameNumberCount + " digits long.");

        switch (gameNumberCount) {
            case 1:
            case 2:
            case 3:
                System.out.println("Not very good. Keep Trying!");
                break;
            case 4:
            case 5:
            case 6:
                System.out.println("You could do better. Stick With it!");
                break;
            case 7:
            case 8:
            case 9:
                System.out.println("Not terrible. Could be better.");
                break;
            default:
                System.out.println("You're an expert!");
        }

        System.out.println("The correct number was " + addCommas(gameNumber) + ".");
        System.out.println("You guessed " + addCommas(userGuess) + ".");
        if (gameNumberCount != guessNumberCount)
            System.out.println("Your guess had " + guessNumberCount + " digits, but the answer had " + gameNumberCount + " digits.");
        else {
            int offBy = getNumberOffBy(userGuess, gameNumber);
            System.out.println("You were off by " + offBy);
        }
        System.out.println("Your HIGH SCORE is: " + high);
        System.out.println("Your LOW SCORE is: " + low);
        System.out.println("Your GAMES PLAYED is: " + games);
        System.out.println("Your AVERAGE SCORE is: " + avg);
        System.out.println();
    }

    /**
     * Returns a Boolean indicating if the user got the guess right.
     *
     * @param userGuess  The user guess
     * @param gameNumber The game number
     * @return boolean Did the user get the right answer.
     */
    private static boolean userGotItRight(String userGuess, String gameNumber) {
        return (userGuess.equals(gameNumber));
    }

    /**
     * Gets the user guess.
     *
     * @param kb The Scanner
     * @return The user guess
     */
    private static String getUsersGuess(Scanner kb) {
        System.out.println("What is your guess? ");
        while (!kb.hasNextLine()) {
            System.out.println("What is your guess? ");
            kb.nextLine();
        }
        return "" + kb.nextLine();
    }

    /**
     * Makes the number vanish.
     */
    private static void makeNumVanish() {
        for (int i = 0; i <= 300; i++) {
            System.out.println();
        }
    }

    /**
     * Displays the game number. If the game number is
       5 or greater, it only displays it for half a second.
     *
     * @param gameNumber The game number
     */
    private static void displayGameNum(String gameNumber) {
        System.out.println("The number is: " + addCommas(gameNumber));
        int time = (gameNumber.length() < 5) ? 1000 : 500;
        try {
            Thread.sleep(time);
        } catch (InterruptedException e) {
            System.out.println("ERROR in displayGameNum() method line 129");
        }
    }

    /**
     * Adds a number, 0-9, to the game number.
     *
     * @param gn  The game number
     * @param gen the Random generator
     * @return the new game number as a String
     */
    private static String updateGameNum(String gn, Random gen) {

        return gn + gen.nextInt(10);
    }

    /**
     * Display the game instructions
     */
    private static void displayInstructions() {
        System.out.println("\n" +
                "███████╗██╗███╗   ███╗ ██████╗ ███╗   ██╗\n" +
                "██╔════╝██║████╗ ████║██╔═══██╗████╗  ██║\n" +
                "███████╗██║██╔████╔██║██║   ██║██╔██╗ ██║\n" +
                "╚════██║██║██║╚██╔╝██║██║   ██║██║╚██╗██║\n" +
                "███████║██║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║\n" +
                "╚══════╝╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝\n" +
                "                                         \n");
        System.out.println("This is a game of Simon.");
        System.out.println("I'll flash a number on the screen.");
        System.out.println("The goal of the game is to remember the number.");
        System.out.println("I'll add one digit each time, so the game gets harder!");
        System.out.println("If the number is 5 or more digits, I'll only display it for half a second.");
        System.out.print("Press ENTER to begin ");  
    }
}
