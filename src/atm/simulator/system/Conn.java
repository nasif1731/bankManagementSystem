package atm.simulator.system;

import java.sql.*;

public class Conn {
	Connection c;
	Statement s;

	public Conn() {
		String host = System.getenv().getOrDefault("DB_HOST", "localhost");
		String port = System.getenv().getOrDefault("DB_PORT", "3306");
		String dbName = System.getenv().getOrDefault("DB_NAME", "bank_management_system");
		String username = System.getenv().getOrDefault("DB_USER", "root");
		String password = System.getenv().getOrDefault("DB_PASSWORD", "root");
		String jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + dbName + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
		try {
			c = DriverManager.getConnection(jdbcUrl, username, password);
			s = c.createStatement();
		} catch (Exception e) {
			System.out.println(e);
		}
	}

}