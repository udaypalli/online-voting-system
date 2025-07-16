<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Elections</title>
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
    <h2>Manage Elections</h2>

    <!-- Back Button -->
    <div class="mb-3">
        <a href="admin_dashboard.jsp?adminId=<%= adminId %>" class="btn btn-secondary">Back to Dashboard</a>
    </div>

    <!-- Form to Add New Election -->
    <div class="card">
        <div class="card-header bg-primary text-white">Add New Election</div>
        <div class="card-body">
            <form action="admin_elections.jsp" method="post">
                <input type="hidden" name="action" value="add">
                <div class="mb-3">
                    <label for="election_name" class="form-label">Election Name</label>
                    <input type="text" id="election_name" name="election_name" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <textarea id="description" name="description" class="form-control" required></textarea>
                </div>
                <div class="mb-3">
                    <label for="start_date" class="form-label">Start Date</label>
                    <input type="date" id="start_date" name="start_date" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label for="end_date" class="form-label">End Date</label>
                    <input type="date" id="end_date" name="end_date" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-primary">Add Election</button>
            </form>
        </div>
    </div>

    <!-- Display Existing Elections -->
    <div class="card">
        <div class="card-header bg-success text-white">Elections Created by You</div>
        <div class="card-body">
            <% 
                String action = request.getParameter("action");
                if ("add".equals(action)) {
                    // Add new election
                    String electionName = request.getParameter("election_name");
                    String description = request.getParameter("description");
                    String startDate = request.getParameter("start_date");
                    String endDate = request.getParameter("end_date");
                    try (Connection con = DBConnection.getConnection()) {
                        String sql = "INSERT INTO elections (admin_id, election_name, description, start_date, end_date) VALUES (?, ?, ?, ?, ?)";
                        PreparedStatement pst = con.prepareStatement(sql);
                        pst.setInt(1, Integer.parseInt(adminId));
                        pst.setString(2, electionName);
                        pst.setString(3, description);
                        pst.setString(4, startDate);
                        pst.setString(5, endDate);
                        pst.executeUpdate();
                        out.println("<div class='alert alert-success'>Election added successfully!</div>");
                    } catch (Exception e) {
                        out.println("<div class='alert alert-danger'>Error adding election: " + e.getMessage() + "</div>");
                    }
                } else if ("delete".equals(action)) {
                    // Delete election
                    String electionId = request.getParameter("electionId");
                    try (Connection con = DBConnection.getConnection()) {
                        String sql = "DELETE FROM elections WHERE election_id = ? AND admin_id = ?";
                        PreparedStatement pst = con.prepareStatement(sql);
                        pst.setInt(1, Integer.parseInt(electionId));
                        pst.setInt(2, Integer.parseInt(adminId));
                        pst.executeUpdate();
                        out.println("<div class='alert alert-success'>Election deleted successfully!</div>");
                    } catch (Exception e) {
                        out.println("<div class='alert alert-danger'>Error deleting election: " + e.getMessage() + "</div>");
                    }
                }

                // Fetch elections created by this admin
                try (Connection con = DBConnection.getConnection()) {
                    String sql = "SELECT * FROM elections WHERE admin_id = ?";
                    PreparedStatement pst = con.prepareStatement(sql);
                    pst.setInt(1, Integer.parseInt(adminId));
                    ResultSet rs = pst.executeQuery();
                    if (rs.next()) {
            %>
                        <table class="table table-bordered">
    <thead>
        <tr>
            <th>Election ID</th> <!-- New column header -->
            <th>Election Name</th>
            <th>Description</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        <% do { %>
            <tr>
                <td><%= rs.getInt("election_id") %></td> <!-- Display Election ID -->
                <td><%= rs.getString("election_name") %></td>
                <td><%= rs.getString("description") %></td>
                <td><%= rs.getDate("start_date") %></td>
                <td><%= rs.getDate("end_date") %></td>
                <td>
                    <a href="admin_candidates.jsp?electionId=<%= rs.getInt("election_id") %>" class="btn btn-info btn-actions">Manage</a>
                    <a href="admin_elections.jsp?action=delete&electionId=<%= rs.getInt("election_id") %>&adminId=<%= adminId %>" class="btn btn-danger btn-actions">Delete</a>
                    <a href="admin_results.jsp?electionId=<%= rs.getInt("election_id") %>" class="btn btn-success btn-actions">Result</a>
                    
                </td>
            </tr>
        <% } while (rs.next()); %>
    </tbody>
</table>

            <%
                    } else {
                        out.println("<p>No elections created yet.</p>");
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Error fetching elections: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
</div>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
