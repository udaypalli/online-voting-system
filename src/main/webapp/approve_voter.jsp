<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Approve Voter</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <style>
        .container {
            margin-top: 50px;
        }
    </style>
</head>
<body>
<div class="container">
    <% 
        String approvalId = request.getParameter("approval_id");
        String action = request.getParameter("action");
        boolean success = false;

        if (approvalId != null && action != null) {
            try (Connection con = DBConnection.getConnection()) {
                String sql;
                if ("approve".equalsIgnoreCase(action)) {
                    sql = "UPDATE user_approval SET is_approved = 1 WHERE approval_id = ?";
                } else if ("disapprove".equalsIgnoreCase(action)) {
                    sql = "UPDATE user_approval SET is_approved = 0 WHERE approval_id = ?";
                } else {
                    throw new IllegalArgumentException("Invalid action specified.");
                }

                PreparedStatement pst = con.prepareStatement(sql);
                pst.setInt(1, Integer.parseInt(approvalId));
                int rowsUpdated = pst.executeUpdate();
                success = rowsUpdated > 0;
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error processing request: " + e.getMessage() + "</div>");
            }
        } else {
            out.println("<div class='alert alert-danger'>Invalid request. Approval ID or action is missing.</div>");
        }
    %>

    <% if (success) { %>
        <div class="alert alert-success">Voter status updated successfully.</div>
    <% } else if (approvalId != null && action != null) { %>
        <div class="alert alert-danger">Failed to update voter status. Please try again.</div>
    <% } %>

    <a href="admin_voters.jsp?adminId=<%= session.getAttribute("adminId")%>" class="btn btn-primary">Back to Manage Voters</a>
</div>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
