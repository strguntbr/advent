package at.ctrlbreak.advent;

import java.util.Optional;
import java.util.stream.Stream;

class Riddle2_2 extends Riddle2_1 {
    public static void main(String[] args) {
        solve();
    }

    protected static void solve() {
        System.out.println(Stream.of(data).map(Data::parse).filter(Optional::isPresent).map(Optional::get).filter(Riddle2_2::passwordOk).count());
    }

    protected static boolean passwordOk(Data data) {
        return nthCharIs(data.password, data.min, data.c) ^ nthCharIs(data.password, data.max, data.c);
    }

    protected static boolean nthCharIs(String password, int n, char c) {
        return password.length() > n && password.charAt(n) == c;
    }
}