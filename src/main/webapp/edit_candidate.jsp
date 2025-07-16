<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Candidate</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
</head>
<body>

<%
    // Fetch candidate details from the database based on the provided candidate_id
    int candidateId = Integer.parseInt(request.getParameter("id"));
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();
        String sql = "SELECT * FROM candidates WHERE candidate_id = ?";
        pst = con.prepareStatement(sql);
        pst.setInt(1, candidateId);
        rs = pst.executeQuery();

        if (rs.next()) {
%>
    <div class="container">
        <h2>Edit Candidate</h2>
        <form method="post">
            <div class="mb-3">
                <label for="candidate_name" class="form-label">Candidate Name</label>
                <input type="text" class="form-control" id="candidate_name" name="candidate_name" value="<%= rs.getString("candidate_name") %>" required>
            </div>
            <div class="mb-3">
                <label for="age" class="form-label">Age</label>
                <input type="number" class="form-control" id="age" name="age" value="<%= rs.getInt("age") %>" required>
            </div>
            <div class="mb-3">
                <label for="gender" class="form-label">Gender</label>
                <select class="form-control" name="gender" required>
                    <option value="Male" <%= rs.getString("gender").equals("Male") ? "selected" : "" %>>Male</option>
                    <option value="Female" <%= rs.getString("gender").equals("Female") ? "selected" : "" %>>Female</option>
                    <option value="Other" <%= rs.getString("gender").equals("Other") ? "selected" : "" %>>Other</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="description" class="form-label">Description</label>
                <textarea class="form-control" id="description" name="description" required><%= rs.getString("description") %></textarea>
            </div>
            <div class="mb-3">
                <label for="mobile" class="form-label">Mobile Number</label>
                <input type="text" class="form-control" id="mobile" name="mobile" value="<%= rs.getString("mobile") %>" required>
            </div>
            <div class="d-grid">
                <button type="submit" class="btn btn-primary">Update Candidate</button>
            </div>
        </form>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (con != null) con.close();
        } catch (SQLException ex) {
            out.println("<div class='alert alert-danger'>Error closing resources: " + ex.getMessage() + "</div>");
        }
    }

    // Handle candidate update
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String candidate_name = request.getParameter("candidate_name");
        String age = request.getParameter("age");
        String gender = request.getParameter("gender");
        String description = request.getParameter("description");
        String mobile = request.getParameter("mobile");

        try {
            con = DBConnection.getConnection();
            String updateSql = "UPDATE candidates SET candidate_name = ?, age = ?, gender = ?, description = ?, mobile = ? WHERE candidate_id = ?";
            pst = con.prepareStatement(updateSql);
            pst.setString(1, candidate_name);
            pst.setInt(2, Integer.parseInt(age));
            pst.setString(3, gender);
            pst.setString(4, description);
            pst.setString(5, mobile);
            pst.setInt(6, candidateId);
            int result = pst.executeUpdate();

            if (result > 0) {
                out.println("<div class='alert alert-success'>Candidate updated successfully!</div>");
            } else {
                out.println("<div class='alert alert-danger'>Failed to update candidate!</div>");
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        } finally {
            try {
                if (pst != null) pst.close();
                if (con != null) con.close();
            } catch (SQLException ex) {
                out.println("<div class='alert alert-danger'>Error closing resources: " + ex.getMessage() + "</div>");
            }
        }
    }
%>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
