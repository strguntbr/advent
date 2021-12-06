package at.ctrlbreak.advent;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class DataReader<T> {
    private final Function<String, T> converter;

    public DataReader(Function<String, T> converter) {
        this.converter = converter;
    }

    public List<T> readData(String file) {
        List<T> result = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line = reader.readLine();
            while (line != null) {
                result.add(converter.apply(line));
                line = reader.readLine();
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return result;
    }
}
