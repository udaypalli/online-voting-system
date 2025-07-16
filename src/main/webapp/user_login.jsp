<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Login</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
</head>
<body>
    <!-- Header -->
    <header class="bg-primary text-white py-3">
        <div class="container d-flex justify-content-between align-items-center">
            <h1 class="h4 mb-0">Online Voting System</h1>
        </div>
    </header>

    <!-- Login Form -->
    <main class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <h2 class="text-center mb-4">User Login</h2>
                <form method="post">
                    <div class="mb-3">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" class="form-control" id="username" name="username" required>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" class="form-control" id="password" name="password" required>
                    </div>
                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary">Login</button>
                    </div>
                </form>
                <p class="text-center mt-3">
                    Don't have an account? <a href="user_register.jsp">Sign up here</a>.
                </p>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-dark text-white text-center py-3">
        <p class="mb-0">&copy; 2024 Online Voting System</p>
    </footer>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%
    // Database authentication logic
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
            PreparedStatement pst = con.prepareStatement(sql);
            pst.setString(1, username);
            pst.setString(2, password);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                // Valid user
                session.setAttribute("user_id", rs.getInt("user_id"));
                session.setAttribute("username", username);
                response.sendRedirect("user_dashboard.jsp?userId=" + rs.getInt("user_id"));
            } else {
                // Invalid user
                out.println("<div class='alert alert-danger text-center'>Invalid username or password!</div>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<div class='alert alert-danger text-center'>Error: " + e.getMessage() + "</div>");
        }
    }
%>
