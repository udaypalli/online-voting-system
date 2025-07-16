<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <style>
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: 220px;
            height: 100%;
            background-color: #343a40;
            padding-top: 20px;
        }
        .sidebar a {
            display: block;
            color: white;
            padding: 10px;
            text-decoration: none;
            margin: 5px 0;
            border-radius: 5px;
        }
        .sidebar a:hover {
            background-color: #007bff;
        }
        .main-content {
            margin-left: 240px;
            padding: 20px;
        }
        .card {
            margin-bottom: 20px;
        }
        .card-header {
            background-color: #007bff;
            color: white;
        }
        .card-body {
            background-color: #f8f9fa;
        }
        .btn {
            width: 100%;
            margin: 5px 0;
        }
    </style>
</head>
<body>
<%
    String adminId = request.getParameter("adminId");
    if (adminId == null) {
        adminId = (String) session.getAttribute("adminId"); // Try retrieving from session
        if (adminId == null) {
            response.sendRedirect("admin_login.jsp"); // Redirect if adminId is missing
            return;
        }
    }
%>


    <!-- Sidebar -->
    <div class="sidebar">
        <h4 class="text-white text-center">Admin Menu</h4>
       
        <a href="admin_elections.jsp?adminId=<%= adminId != null ? adminId : session.getAttribute("adminId") %>" class="btn btn-info">Elections</a>
        
        <a href="admin_results.jsp?adminId=<%= adminId != null ? adminId : session.getAttribute("adminId") %>" class="btn btn-success">Results</a>
        <a href="admin_voters.jsp?adminId=<%= adminId != null ? adminId : session.getAttribute("adminId") %>" class="btn btn-warning">Voter Lists</a>
        <a href="admin_candidates.jsp?adminId=<%= adminId != null ? adminId : session.getAttribute("adminId") %>" class="btn btn-danger">Candidate Lists</a>
        <a href="admin_login.jsp?adminId=<%= adminId != null ? adminId : session.getAttribute("adminId") %>" class="btn btn-secondary">Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <header>
            <h2>Welcome, <%= session.getAttribute("username") %></h2>
            <p>Manage ongoing elections and created elections</p>
        </header>

        <section>
            <!-- Ongoing Elections -->
            <div class="card">
                <div class="card-header">Ongoing Elections</div>
                <div class="card-body">
                    <% 
                        // Fetch ongoing elections from the database
                        Connection con = null;
                        PreparedStatement pst = null;
                        ResultSet rs = null;
                        try {
                            con = DBConnection.getConnection();
                            String sql = "SELECT * FROM elections WHERE start_date <= CURRENT_DATE AND end_date >= CURRENT_DATE";
;
                            pst = con.prepareStatement(sql);
                            rs = pst.executeQuery();
                            
                            if (rs.next()) {
                                do {
                    %>
                                    <div class="card mb-3">
                                        <div class="card-body">
                                            <h5 class="card-title"><%= rs.getString("election_name") %></h5>
                                            <p class="card-text"><%= rs.getString("description") %></p>
                                            <a href="election_details.jsp?id=<%= rs.getInt("election_id") %>" class="btn btn-primary">View Details</a>
                                        </div>
                                    </div>
                    <%          } while (rs.next()); 
                            } else {
                    %>
                                <p>No ongoing elections.</p>
                    <%          }
                        } catch (Exception e) {
                            out.println("Error: " + e.getMessage());
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (pst != null) pst.close();
                                if (con != null) con.close();
                            } catch (SQLException ex) {
                                out.println("Error closing resources: " + ex.getMessage());
                            }
                        }
                    %>
                </div>
            </div>

            <!-- Elections Created by Admin -->
            <div class="card">
                <div class="card-header">Elections Created by You</div>
                <div class="card-body">
                    <% 
                        // Fetch elections created by the admin from the database
                        try {
                            con = DBConnection.getConnection();
                            String sql = "SELECT * FROM elections WHERE admin_id = ?";

                            pst = con.prepareStatement(sql);
                            pst.setInt(1, (Integer) session.getAttribute("user_id"));
                            rs = pst.executeQuery();
                            
                            if (rs.next()) {
                                do {
                    %>
                                    <div class="card mb-3">
                                        <div class="card-body">
                                            <h5 class="card-title"><%= rs.getString("election_name") %></h5>
                                            <p class="card-text"><%= rs.getString("description") %></p>
                                            <a href="election_details.jsp?id=<%= rs.getInt("election_id") %>" class="btn btn-primary">View Details</a>
                                        </div>
                                    </div>
                    <%          } while (rs.next()); 
                            } else {
                    %>
                                <p>You haven't created any elections yet.</p>
                    <%          }
                        } catch (Exception e) {
                            out.println("Error: " + e.getMessage());
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (pst != null) pst.close();
                                if (con != null) con.close();
                            } catch (SQLException ex) {
                                out.println("Error closing resources: " + ex.getMessage());
                            }
                        }
                    %>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="bg-dark text-white text-center py-3">
            <p class="mb-0">&copy; 2024 Online Voting System | Admin - Uday Palli</p>
        </footer>
    </div>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
