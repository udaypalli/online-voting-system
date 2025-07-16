<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Election Results</title>
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
    <h2>Election Results</h2>

    <!-- Back Button -->
    <div class="mb-3">
        <a href="admin_dashboard.jsp?adminId=<%= adminId %>" class="btn btn-secondary">Back to Dashboard</a>
    </div>

    <!-- Form to Select Election -->
    <div class="card">
        <div class="card-header bg-info text-white">Select Election to View Results</div>
        <div class="card-body">
            <form action="admin_results.jsp" method="get">
                <div class="mb-3">
                    <label for="election_id" class="form-label">Choose Election</label>
                    <select id="election_id" name="election_id" class="form-select" required>
                        <option value="">-- Select Election --</option>
                        <% 
                            // Fetch elections created by the admin
                            try (Connection con = DBConnection.getConnection()) {
                                String sql = "SELECT election_id, election_name FROM elections WHERE admin_id = ?";
                                PreparedStatement pst = con.prepareStatement(sql);
                                pst.setInt(1, Integer.parseInt(adminId)); // Admin ID from session
                                ResultSet rs = pst.executeQuery();
                                while (rs.next()) {
                        %>
                                    <option value="<%= rs.getInt("election_id") %>"><%= rs.getString("election_name") %></option>
                        <% 
                                }
                            } catch (Exception e) {
                                out.println("<div class='alert alert-danger'>Error fetching elections: " + e.getMessage() + "</div>");
                            }
                        %>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">View Results</button>
            </form>
        </div>
    </div>

    <% 
        // Fetch results for the selected election
        String electionId = request.getParameter("election_id");
        if (electionId != null && !electionId.isEmpty()) {
            try (Connection con = DBConnection.getConnection()) {
                // Fetch election details
                String electionSql = "SELECT election_name, start_date, end_date FROM elections WHERE election_id = ?";
                PreparedStatement pstElection = con.prepareStatement(electionSql);
                pstElection.setInt(1, Integer.parseInt(electionId));
                ResultSet rsElection = pstElection.executeQuery();

                if (rsElection.next()) {
                    String electionName = rsElection.getString("election_name");
                    Date startDate = rsElection.getDate("start_date");
                    Date endDate = rsElection.getDate("end_date");
    %>

                    <div class="card">
                        <div class="card-header bg-success text-white">Election: <%= electionName %></div>
                        <div class="card-body">
                            <p><strong>Start Date:</strong> <%= startDate %></p>
                            <p><strong>End Date:</strong> <%= endDate %></p>

                            <!-- Fetch and Display Candidates with Votes -->
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>Candidate Name</th>
                                        <th>Votes</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        String sqlVotes = "SELECT c.candidate_name, COUNT(v.vote_id) AS vote_count " +
                                                          "FROM candidates c " +
                                                          "LEFT JOIN votes v ON c.candidate_id = v.candidate_id " +
                                                          "WHERE c.election_id = ? " +
                                                          "GROUP BY c.candidate_name";
                                        PreparedStatement pstVotes = con.prepareStatement(sqlVotes);
                                        pstVotes.setInt(1, Integer.parseInt(electionId));
                                        ResultSet rsVotes = pstVotes.executeQuery();
                                        int maxVotes = 0;
                                        String winner = "";
                                        int winnerId =0;

                                        while (rsVotes.next()) {
                                            String candidateName = rsVotes.getString("candidate_name");
                                            int voteCount = rsVotes.getInt("vote_count");
                                           
                                            if (voteCount > maxVotes) {
                                                maxVotes = voteCount;
                                                winner = candidateName;
                                             
                                                
                                            }
                                    %>
                                            <tr>
                                                <td><%= candidateName %></td>
                                                <td><%= voteCount %></td>
                                            </tr>
                                    <% 
                                        }
                                    %>
                                </tbody>
                            </table>

                            <!-- Display Winner -->
                            <div class="alert alert-info">
                                <strong>Winner:</strong> <%= winner %> with <%= maxVotes %> votes.
                            </div>

                            <!-- Declare Winner Button -->
                            <form action="declare_winner.jsp" method="post">
                                <input type="hidden" name="election_id" value="<%= electionId %>">
                                <input type="hidden" name="winner" value="<%= winner %>">
                                <button type="submit" class="btn btn-success">Declare Winner</button>
                            </form>
                        </div>
                    </div>
    <% 
                } else {
                    out.println("<div class='alert alert-danger'>Election not found.</div>");
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error fetching election results: " + e.getMessage() + "</div>");
            }
        }
    %>
</div>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
