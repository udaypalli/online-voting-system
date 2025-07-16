package com.votingsystem.util;

import java.sql.Connection;

import com.votingsystem.util.DBConnection;

public class TestDBConnection {
	 public static void main(String[] args) {
	        Connection connection = DBConnection.getConnection();
	        if (connection != null) {
	            System.out.println("Database connected successfully!");
	        } else {
	            System.out.println("Failed to connect to the database.");
	        }
	    }

}
