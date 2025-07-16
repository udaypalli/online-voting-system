<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Candidates</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
</head>
<body>
    <% 
        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        String adminId = (String) session.getAttribute("adminId");

        if (adminId == null) {
            response.sendRedirect("admin_login.jsp");
            return;
        }
    %>

    <div class="container mt-4">
        <a href="admin_dashboard.jsp" class="btn btn-dark mb-3">Back to Dashboard</a>

        <h2 class="mb-4">Manage Candidates</h2>

        <!-- Add Candidate Form -->
        <div class="card mb-4">
            <div class="card-header">Add New Candidate</div>
            <div class="card-body">
                <% 
                    if (request.getMethod().equalsIgnoreCase("POST")) {
                        String electionId = request.getParameter("election_id");
                        String candidateName = request.getParameter("candidate_name");
                        String age = request.getParameter("age");
                        String gender = request.getParameter("gender");
                        String description = request.getParameter("description");
                        String mobile = request.getParameter("mobile");

                        try {
                            con = DBConnection.getConnection();
                            String sql = "INSERT INTO candidates (election_id, candidate_name, age, gender, description, mobile) VALUES (?, ?, ?, ?, ?, ?)";
                            pst = con.prepareStatement(sql);
                            pst.setInt(1, Integer.parseInt(electionId));
                            pst.setString(2, candidateName);
                            pst.setInt(3, Integer.parseInt(age));
                            pst.setString(4, gender);
                            pst.setString(5, description);
                            pst.setString(6, mobile);
                            pst.executeUpdate();
                            out.println("<div class='alert alert-success'>Candidate added successfully!</div>");
                        } catch (Exception e) {
                            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                        } finally {
                            if (pst != null) pst.close();
                            if (con != null) con.close();
                        }
                    }
                %>
                <form method="post">
                    <div class="mb-3">
                        <label for="election_id" class="form-label">Election</label>
                        <select class="form-control" id="election_id" name="election_id" required>
                            <option value="">Select Election</option>
                            <% 
                                try {
                                    con = DBConnection.getConnection();
                                    String sql = "SELECT election_id, election_name FROM elections WHERE admin_id = ?";
                                    pst = con.prepareStatement(sql);
                                    pst.setString(1, adminId);
                                    rs = pst.executeQuery();

                                    while (rs.next()) {
                            %>
                                <option value="<%= rs.getInt("election_id") %>"><%= rs.getString("election_name") %></option>
                            <% 
                                    }
                                } catch (Exception e) {
                                    out.println("Error: " + e.getMessage());
                                } finally {
                                    if (rs != null) rs.close();
                                    if (pst != null) pst.close();
                                    if (con != null) con.close();
                                }
                            %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="candidate_name" class="form-label">Candidate Name</label>
                        <input type="text" class="form-control" id="candidate_name" name="candidate_name" required>
                    </div>
                    <div class="mb-3">
                        <label for="age" class="form-label">Age</label>
                        <input type="number" class="form-control" id="age" name="age" required>
                    </div>
                    <div class="mb-3">
                        <label for="gender" class="form-label">Gender</label>
                        <select class="form-control" id="gender" name="gender" required>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label for="mobile" class="form-label">Mobile Number</label>
                        <input type="text" class="form-control" id="mobile" name="mobile" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Add Candidate</button>
                </form>
            </div>
        </div>

        <!-- Candidates List -->
        <div class="card">
            <div class="card-header">Existing Candidates</div>
            <div class="card-body">
                <% 
                    try {
                        con = DBConnection.getConnection();
                        String sql = "SELECT * FROM candidates WHERE election_id IN (SELECT election_id FROM elections WHERE admin_id = ?)";
                        pst = con.prepareStatement(sql);
                        pst.setString(1, adminId);
                        rs = pst.executeQuery();

                        if (!rs.isBeforeFirst()) {
                            out.println("<p>No candidates found.</p>");
                        } else {
                            while (rs.next()) {
                %>
                    <div class="card mb-3">
                        <div class="card-body">
                            <h5 class="card-title"><%= rs.getString("candidate_name") %> (Age: <%= rs.getInt("age") %>, <%= rs.getString("gender") %>)</h5>
                            <p class="card-text"><%= rs.getString("description") %></p>
                            <p><strong>Mobile:</strong> <%= rs.getString("mobile") %></p>
                            <a href="edit_candidate.jsp?id=<%= rs.getInt("candidate_id") %>" class="btn btn-warning">Edit</a>
                            <a href="delete_candidate.jsp?id=<%= rs.getInt("candidate_id") %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this candidate?');">Delete</a>
                        </div>
                    </div>
                <% 
                            }
                        }
                    } catch (Exception e) {
                        out.println("<p>Error: " + e.getMessage() + "</p>");
                    } finally {
                        if (rs != null) rs.close();
                        if (pst != null) pst.close();
                        if (con != null) con.close();
                    }
                %>
            </div>
        </div>
    </div>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
