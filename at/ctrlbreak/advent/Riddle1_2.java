package at.ctrlbreak.advent;

public class Riddle1_2 extends Riddle1_1 {
    public static void main(String[] args) {
        new Riddle1_2();
    }

    @Override
    protected Integer solve() {
        Integer solution = null;
        for (int i = 0; i < data.size(); i++) {
            for (int j = i + 1; j < data.size(); j++) {
                if (sum(i, j)< 2020) {
                    for (int k = j + 1; k < data.size(); k++) {
                        if (sum(i, j, k)==2020) {
                            ensureNoOtherSolutionExists(solution);
                            solution =data.get(i) * data.get(j) * data.get(k);
                        }
                    }
                }
            }
        }
        return ensureSolutionExists(solution);
    }
}