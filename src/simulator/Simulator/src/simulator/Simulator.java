package simulator;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class Simulator {

    // Trỏ vào đường dẫn Servlet của Project A (Check lại cổng Tomcat của ông, ở đây tôi giả sử là 8080)
    private static final String API_URL = "http://localhost:8080/ShopeeWeb/api/simulator-checkout";

    public static void main(String[] args) {
        System.out.println("[PROJECT B] Dang khoi dong Simulator...");
        System.out.println("Gui request thanh toan sang Project A (ShopeeWeb)...");

        try {
            URL url = new URL(API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            // Gửi request bằng phương thức POST
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");

            // Giả lập gửi 1 chuỗi JSON đi
            String jsonPayload = "{\"action\":\"checkout\"}";
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            // Nhận kết quả từ Project A trả về
            int responseCode = conn.getResponseCode();
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            String inputLine;
            StringBuilder response = new StringBuilder();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            System.out.println("[KET QUA TU PROJECT A] HTTP Status: " + responseCode);
            System.out.println("Du lieu tra ve: " + response.toString());

        } catch (Exception e) {
            System.err.println("Loi ket noi: Server Project A chua bat!");
        }
    }
}
