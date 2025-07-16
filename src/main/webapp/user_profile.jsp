<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        main {
            flex: 1;
        }
    </style>
</head>
<% 
    // Retrieve the user_id from the session
    Integer usserId = (Integer) session.getAttribute("user_id");
%>
<body>
    <header class="bg-primary text-white py-3">
    <div class="container d-flex justify-content-between align-items-center">
        <div>
            <!-- Passing userId as a query parameter -->
            <a href="user_election.jsp?userId=<%= usserId %>" class="btn btn-warning me-2">Elections</a>
            <a href="user_result.jsp?userId=<%= usserId %>" class="btn btn-success me-2">View Results</a>
            <a href="user_profile.jsp?userId=<%= usserId %>" class="btn btn-info">Profile</a>
        </div>
        <div>
            <a href="user_login.jsp" class="btn btn-danger">Logout</a>
        </div>
    </div>
</header>

    <!-- Main Content -->
    <main class="container my-5">
        <h2>User Profile</h2>

        <% 
            Integer userId = (Integer) session.getAttribute("user_id");
            if (userId == null) {
                out.println("<p class='text-danger'>You need to log in to view and edit your profile.</p>");
            } else {
                try (Connection con = DBConnection.getConnection()) {
                    // Fetch user details from the database
                    String query = "SELECT * FROM users WHERE user_id = ?";
                    PreparedStatement pst = con.prepareStatement(query);
                    pst.setInt(1, userId);
                    ResultSet rs = pst.executeQuery();
                    
                    if (rs.next()) {
                        String name = rs.getString("name");
                        String username = rs.getString("username");
                        String email = rs.getString("email");
                        String age = rs.getString("age");
                        String gender = rs.getString("gender");
                        String address = rs.getString("address");
                        String mobile = rs.getString("mobile");
        %>

        <!-- Profile Form -->
        <form action="user_profile.jsp" method="post">
            <div class="mb-3">
                <label for="name" class="form-label">Name</label>
                <input type="text" class="form-control" id="name" name="name" value="<%= name %>" required>
            </div>
            <div class="mb-3">
                <label for="username" class="form-label">Username</label>
                <input type="text" class="form-control" id="username" name="username" value="<%= username %>" required readonly>
            </div>
            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input type="email" class="form-control" id="email" name="email" value="<%= email %>" required>
            </div>
            <div class="mb-3">
                <label for="age" class="form-label">Age</label>
                <input type="text" class="form-control" id="age" name="age" value="<%= age %>" required>
            </div>
            <div class="mb-3">
                <label for="gender" class="form-label">Gender</label>
                <select class="form-control" id="gender" name="gender" required>
                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                    <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="address" class="form-label">Address</label>
                <textarea class="form-control" id="address" name="address" required><%= address %></textarea>
            </div>
            <div class="mb-3">
                <label for="mobile" class="form-label">Mobile</label>
                <input type="text" class="form-control" id="mobile" name="mobile" value="<%= mobile %>" required>
            </div>
            <button type="submit" class="btn btn-primary">Update Profile</button>
        </form>

        <% 
                    } else {
                        out.println("<p class='text-danger'>User not found.</p>");
                    }
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error retrieving user profile: " + e.getMessage() + "</p>");
                }
            }
        %>

        <% 
            // Handle profile update
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String newName = request.getParameter("name");
                String newEmail = request.getParameter("email");
                String newAge = request.getParameter("age");
                String newGender = request.getParameter("gender");
                String newAddress = request.getParameter("address");
                String newMobile = request.getParameter("mobile");

                try (Connection con = DBConnection.getConnection()) {
                    String updateQuery = "UPDATE users SET name = ?, email = ?, age = ?, gender = ?, address = ?, mobile = ? WHERE user_id = ?";
                    PreparedStatement pst = con.prepareStatement(updateQuery);
                    pst.setString(1, newName);
                    pst.setString(2, newEmail);
                    pst.setString(3, newAge);
                    pst.setString(4, newGender);
                    pst.setString(5, newAddress);
                    pst.setString(6, newMobile);
                    pst.setInt(7, userId);
                    int rowsUpdated = pst.executeUpdate();
                    if (rowsUpdated > 0) {
                        out.println("<div class='alert alert-success'>Profile updated successfully.</div>");
                    } else {
                        out.println("<div class='alert alert-danger'>Error updating profile.</div>");
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                }
            }
        %>
    </main>

    <!-- Footer -->
    <footer class="bg-dark text-white text-center py-3 mt-auto">
        <p class="mb-0">&copy; 2024 Online Voting System</p>
    </footer>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
