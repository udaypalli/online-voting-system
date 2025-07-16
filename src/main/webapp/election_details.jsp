<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Election Details</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <style>
        .main-content {
            margin: 20px;
        }
        .card {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<%
    String electionId = request.getParameter("id");
    if (electionId == null || electionId.isEmpty()) {
        response.sendRedirect("admin_dashboard.jsp"); // Redirect if no election ID is provided
        return;
    }
%>

<div class="container mt-5">
    <h2>Election Details</h2>

    <div class="card">
        <div class="card-header bg-primary text-white">Election Information</div>
        <div class="card-body">
            <% 
                try (Connection con = DBConnection.getConnection()) {
                    // Fetch election details
                    String electionSql = "SELECT * FROM elections WHERE election_id = ?";
                    PreparedStatement pstElection = con.prepareStatement(electionSql);
                    pstElection.setInt(1, Integer.parseInt(electionId));
                    ResultSet rsElection = pstElection.executeQuery();

                    if (rsElection.next()) {
                        String electionName = rsElection.getString("election_name");
                        String description = rsElection.getString("description");
                        Date startDate = rsElection.getDate("start_date");
                        Date endDate = rsElection.getDate("end_date");
            %>
                        <p><strong>Election Name:</strong> <%= electionName %></p>
                        <p><strong>Description:</strong> <%= description %></p>
                        <p><strong>Start Date:</strong> <%= startDate %></p>
                        <p><strong>End Date:</strong> <%= endDate %></p>
            <%
                    } else {
                        out.println("<p class='text-danger'>Election not found.</p>");
                    }
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error fetching election details: " + e.getMessage() + "</p>");
                }
            %>
        </div>
    </div>

    <div class="card">
        <div class="card-header bg-secondary text-white">Candidates</div>
        <div class="card-body">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Candidate Name</th>
                        <th>Age</th>
                        <th>Gender</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        try (Connection con = DBConnection.getConnection()) {
                            String candidateSql = "SELECT candidate_name, age, gender, description FROM candidates WHERE election_id = ?";
                            PreparedStatement pstCandidates = con.prepareStatement(candidateSql);
                            pstCandidates.setInt(1, Integer.parseInt(electionId));
                            ResultSet rsCandidates = pstCandidates.executeQuery();

                            while (rsCandidates.next()) {
                                String candidateName = rsCandidates.getString("candidate_name");
                                int age = rsCandidates.getInt("age");
                                String gender = rsCandidates.getString("gender");
                                String description = rsCandidates.getString("description");
                    %>
                                <tr>
                                    <td><%= candidateName %></td>
                                    <td><%= age %></td>
                                    <td><%= gender %></td>
                                    <td><%= description %></td>
                                </tr>
                    <% 
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='4' class='text-danger'>Error fetching candidates: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <div class="card-header bg-success text-white">Statistics</div>
        <div class="card-body">
            <% 
                try (Connection con = DBConnection.getConnection()) {
                    // Count registered voters
                    String voterCountSql = "SELECT COUNT(*) AS total_voters FROM user_approval WHERE election_id = ?";
                    PreparedStatement pstVoterCount = con.prepareStatement(voterCountSql);
                    pstVoterCount.setInt(1, Integer.parseInt(electionId));
                    ResultSet rsVoterCount = pstVoterCount.executeQuery();
                    int totalVoters = 0;
                    if (rsVoterCount.next()) {
                        totalVoters = rsVoterCount.getInt("total_voters");
                    }

                    // Count votes cast
                    String voteCountSql = "SELECT COUNT(*) AS total_votes FROM votes WHERE election_id = ?";
                    PreparedStatement pstVoteCount = con.prepareStatement(voteCountSql);
                    pstVoteCount.setInt(1, Integer.parseInt(electionId));
                    ResultSet rsVoteCount = pstVoteCount.executeQuery();
                    int totalVotes = 0;
                    if (rsVoteCount.next()) {
                        totalVotes = rsVoteCount.getInt("total_votes");
                    }
            %>
                    <p><strong>Total Registered Voters:</strong> <%= totalVoters %></p>
                    <p><strong>Total Votes Cast:</strong> <%= totalVotes %></p>
            <%
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error fetching statistics: " + e.getMessage() + "</p>");
                }
            %>
        </div>
    </div>

    <div class="text-center">
        <a href="admin_dashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
    </div>
</div>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
