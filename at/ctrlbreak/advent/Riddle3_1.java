package at.ctrlbreak.advent;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

public class Riddle3_1 extends AbstractRiddle<Riddle3_1.Data, Integer> {
    public static void main(String[] args) {
        new Riddle3_1();
    }

    @Override
    protected List<Data> loadData() {
        return new DataReader<Data>(Data::new).readData("input/3.data");
    }

    @Override
    protected Integer solve() {
        return solve(3, 1);
    }

    protected int solve(int x, int y) {
        List<Data> data = copyData();
        int trees = 0;
        while (!data.isEmpty()) {
            trees += data.get(0).getFirst().equals('#') ? 1 : 0;
            for (int i = 0; i < y; i++) {
                data.remove(0);
                if (data.isEmpty()){
                    break;
                }
            }
            rotateAll(x, data);    
        }
        return trees;
    }

    protected void rotateAll(int n, List<Data> data) {
        data.forEach(line -> line.rotate(n));
    }

    protected List<Data> copyData() {
        return data.stream().map(Data::new).collect(Collectors.toList());
    }

    protected static class Data extends LinkedList<Character> {
        static final long serialVersionUID = 1;

        public Data(String line) {
            for (char c: line.toCharArray()) {
                this.addLast(c);
            }
        }

        public Data(Data other) {
            this.addAll(other);
        }

        public void rotate(int n) {
            for (int i = 0; i < n; i++) {
                this.addLast(this.remove());
            }
        }
    }
}