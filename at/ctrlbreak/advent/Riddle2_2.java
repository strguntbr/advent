package at.ctrlbreak.advent;

class Riddle2_2 extends Riddle2_1 {
    public static void main(String[] args) {
        new Riddle2_2();
    }

    @Override
    protected boolean passwordOk(Data data) {
        return nthCharIs(data.password, data.min, data.c) ^ nthCharIs(data.password, data.max, data.c);
    }

    protected static boolean nthCharIs(String password, int n, char c) {
        return password.length() > n - 1 && password.charAt(n - 1) == c;
    }
}