package at.ctrlbreak.advent;

import java.util.List;

public class Riddle1_1 extends AbstractRiddle<Integer, Integer> {
    public static void main(String[] args) {
        new Riddle1_1();
    }

    @Override
    protected List<Integer> loadData() {
        return new DataReader<Integer>(Integer::parseInt).readData("input/1.data");
    }

    @Override
    protected Integer solve() {
        Integer solution = null;
        for (int i = 0; i < data.size(); i++) {
            for (int j = i + 1; j < data.size(); j++) {
                if (sum(i, j)==2020) {
                    ensureNoOtherSolutionExists(solution);
                    solution = data.get(i) * data.get(j);
                }
            }
        }
        return ensureSolutionExists(solution);
    }

    protected int sum(int... indices) {
        int sum = 0;
        for (int i = 0; i < indices.length; i++) {
            sum += data.get(indices[i]);
        }
        return sum;
    }
}