<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Voters</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <style>
        .main-content {
            margin: 20px;
        }
        .card {
            margin-bottom: 20px;
        }
        .btn-actions {
            margin-right: 10px;
        }
    </style>
</head>
<body>
<%
    // Get adminId from session or redirect to login if not present
    String adminId = request.getParameter("adminId");
    if (adminId == null) {
        adminId = (String) session.getAttribute("adminId");
        if (adminId == null) {
            response.sendRedirect("admin_login.jsp");
            return;
        }
    } else {
        session.setAttribute("adminId", adminId); // Save adminId in session
    }
%>

<div class="container mt-5">
    <h2>Manage Voters</h2>

    <!-- Back Button -->
    <div class="mb-3">
        <a href="admin_dashboard.jsp?adminId=<%= adminId %>" class="btn btn-secondary">Back to Dashboard</a>
    </div>

    <!-- Display Pending Voter Approval Requests -->
    <div class="card">
        <div class="card-header bg-success text-white">Voter Approval Requests</div>
        <div class="card-body">
            <% 
                // Fetch voters pending approval for elections created by the admin
                try (Connection con = DBConnection.getConnection()) {
                    String sql = "SELECT ua.approval_id, u.user_id, u.name AS user_name, u.age, u.email, e.election_name, ua.is_approved " +
                                 "FROM user_approval ua " +
                                 "JOIN users u ON ua.user_id = u.user_id " +
                                 "JOIN elections e ON ua.election_id = e.election_id " +
                                 "WHERE e.admin_id = ?"; // Get voters for the specific admin
                    PreparedStatement pst = con.prepareStatement(sql);
                    pst.setInt(1, Integer.parseInt(adminId)); // Admin ID from session
                    ResultSet rs = pst.executeQuery();

                    if (rs.next()) {
            %>
                        <table class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>User ID</th>
                                    <th>Name</th>
                                    <th>Age</th>
                                    <th>Email</th>
                                    <th>Election</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% do { %>
                                    <tr>
                                        <td><%= rs.getInt("user_id") %></td>
                                        <td><%= rs.getString("user_name") %></td>
                                        <td><%= rs.getInt("age") %></td>
                                        <td><%= rs.getString("email") %></td>
                                        <td><%= rs.getString("election_name") %></td>
                                        <td><%= rs.getBoolean("is_approved") ? "Approved" : "Pending" %></td>
                                        <td>
                                            <a href="approve_voter.jsp?approval_id=<%= rs.getInt("approval_id") %>&action=approve" class="btn btn-success btn-actions">Approve</a>
                                            <a href="approve_voter.jsp?approval_id=<%= rs.getInt("approval_id") %>&action=disapprove" class="btn btn-danger btn-actions">Disapprove</a>
                                        </td>
                                    </tr>
                                <% } while (rs.next()); %>
                            </tbody>
                        </table>
            <% 
                    } else {
                        out.println("<p>No voter approval requests found.</p>");
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Error fetching voters: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
</div>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
