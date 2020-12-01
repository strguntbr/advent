package at.ctrlbreak.advent;

class Riddle1_2 extends Riddle1_1 {
    public static void main(String[] args) {
        solve();
    }

    protected static void solve() {
        for (int i = 0; i < numbers.length; i++) {
            for (int j = i + 1; j < numbers.length; j++) {
                if (sum(i, j)< 2020) {
                    for (int k = j + 1; k < numbers.length; k++) {
                        if (sum(i, j, k)==2020) {
                            System.out.println(numbers[i] * numbers[j] * numbers[k]);
                        }
                    }
                }
            }
        }
    }
}