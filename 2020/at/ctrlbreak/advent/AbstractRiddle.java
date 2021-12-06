package at.ctrlbreak.advent;

import java.util.List;

public abstract class AbstractRiddle<D, S> {
    protected final List<D> data;

    protected AbstractRiddle() {
        data = loadData();
        System.out.println(solve());
    }

    protected abstract List<D> loadData();

    protected abstract S solve();

    protected void ensureNoOtherSolutionExists(S previousSolution) {
        if (previousSolution != null) {
            throw new MultipleSolutionsException();
        }
    }

    protected S ensureSolutionExists(S solution) {
        if (solution == null) {
            throw new UnsolvableException();
        }
        return solution;
    }
}
