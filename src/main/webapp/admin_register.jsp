<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Registration</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
</head>
<body>
    <!-- Header -->
    <header class="bg-primary text-white py-3">
        <div class="container text-center">
            <h1 class="h4 mb-0">Online Voting System - Admin Registration</h1>
        </div>
    </header>

    <!-- Main Content -->
    <main class="container my-5">
        <h2 class="text-center mb-4">Register as an Admin</h2>

        <% 
            // Check if form is submitted
            String name = request.getParameter("name");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String email = request.getParameter("email");
            String mobile = request.getParameter("mobile");
            String successMessage = "";
            String errorMessage = "";

            if (name != null && username != null && password != null && email != null && mobile != null) {
                // Process the registration
                Connection con = null;
                PreparedStatement ps = null;
                try {
                    // Establish a connection
                    con = DBConnection.getConnection();

                    // Prepare SQL query
                    String query = "INSERT INTO admins (name, username, password, email, mobile) VALUES (?, ?, ?, ?, ?)";
                    ps = con.prepareStatement(query);

                    // Set parameters
                    ps.setString(1, name);
                    ps.setString(2, username);
                    ps.setString(3, password);
                    ps.setString(4, email);
                    ps.setString(5, mobile);

                    // Execute the query
                    int result = ps.executeUpdate();

                    if (result > 0) {
                        successMessage = "Registration successful! <a href='admin_login.jsp'>Click here to log in</a>.";
                    } else {
                        errorMessage = "Registration failed. Please try again.";
                    }
                } catch (Exception e) {
                    errorMessage = "An error occurred: " + e.getMessage();
                } finally {
                    try {
                        if (ps != null) ps.close();
                        if (con != null) con.close();
                    } catch (SQLException ex) {
                        errorMessage = "Error closing resources: " + ex.getMessage();
                    }
                }
            }
        %>

        <%-- Display success or error message if any --%>
        <div class="text-center mt-4">
            <% if (!successMessage.isEmpty()) { %>
                <div class="alert alert-success"><%= successMessage %></div>
            <% } else if (!errorMessage.isEmpty()) { %>
                <div class="alert alert-danger"><%= errorMessage %></div>
            <% } %>
        </div>

        <!-- Registration Form -->
        <form action="admin_register.jsp" method="post" class="needs-validation" novalidate>
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label for="name" class="form-label">Full Name</label>
                    <input type="text" name="name" id="name" class="form-control" required>
                    <div class="invalid-feedback">Please provide your full name.</div>
                </div>
                <div class="col-md-6 mb-3">
                    <label for="username" class="form-label">Username</label>
                    <input type="text" name="username" id="username" class="form-control" required>
                    <div class="invalid-feedback">Please provide a username.</div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" name="password" id="password" class="form-control" required>
                    <div class="invalid-feedback">Please provide a password.</div>
                </div>
                <div class="col-md-6 mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" name="email" id="email" class="form-control" required>
                    <div class="invalid-feedback">Please provide a valid email address.</div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label for="mobile" class="form-label">Mobile Number</label>
                    <input type="tel" name="mobile" id="mobile" class="form-control" required>
                    <div class="invalid-feedback">Please provide a valid mobile number.</div>
                </div>
            </div>
            <div class="text-center">
                <button type="submit" class="btn btn-primary">Register</button>
                <a href="admin_login.jsp" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </main>

    <!-- Footer -->
    <footer class="bg-dark text-white text-center py-3 mt-auto">
        <p class="mb-0">&copy; 2024 Online Voting System</p>
    </footer>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation script
        (function () {
            'use strict';
            const forms = document.querySelectorAll('.needs-validation');
            Array.prototype.slice.call(forms).forEach(function (form) {
                form.addEventListener('submit', function (event) {
                    if (!form.checkValidity()) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        })();
    </script>
</body>
</html>
