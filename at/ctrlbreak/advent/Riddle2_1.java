package at.ctrlbreak.advent;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Riddle2_1 extends AbstractRiddle<Riddle2_1.Data, Long> {
    public static void main(String[] args) {
        new Riddle2_1();
    }

    @Override
    protected List<Data> loadData() {
        return new DataReader<Data>(Data::parse).readData("input/2.data");
    }

    @Override
    protected Long solve() {
        return data.stream().filter(this::passwordOk).count();
    }

    protected boolean passwordOk(Data data) {
        long count = countChar(data.c, data.password);
        return count >= data.min && count <= data.max;
    }

    protected long countChar(char c, String password) {
        return password.chars().filter(v -> v == c).count();
    }

    protected static class Data {
        private final static Pattern pattern = Pattern.compile("^(\\d+)-(\\d+) (\\w): (\\w+)$");

        public final int min;
        public final int max;
        public final char c;
        public final String password;

        public Data(int min, int max, char c, String password) {
            this.min = min;
            this.max = max;
            this.c = c;
            this.password = password;
        }

        public static Data parse(String data) {
            Matcher matcher = pattern.matcher(data);
            if (matcher.matches()) {
                return new Data(
                    Integer.parseInt(matcher.group(1)),
                    Integer.parseInt(matcher.group(2)),
                    matcher.group(3).charAt(0),
                    matcher.group(4)
                );
            }
            throw new RuntimeException("Invalid data");
        }
    }
}