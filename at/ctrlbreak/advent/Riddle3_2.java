package at.ctrlbreak.advent;

public class Riddle3_2 extends Riddle3_1 {
    public static void main(String[] args) {
        new Riddle3_2();
    }

    @Override
    protected Integer solve() {
        return solve(1, 1) * solve(3, 1) * solve(5, 1) * solve(7, 1) * solve(1, 2);
    }
}