<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Election Results</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            background-color: #f8f9fa;
        }
        main {
            flex: 1;
        }
        .winner-card {
            background-color: #28a745;
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        .winner-card h3 {
            font-weight: bold;
            font-size: 1.5em;
        }
        .winner-card p {
            font-size: 1.2em;
            font-weight: bold;
        }
        .candidate-row {
            background-color: #ffffff;
            margin-bottom: 5px;
            padding: 10px;
            border-radius: 5px;
        }
        .candidate-row:nth-child(even) {
            background-color: #f8f9fa;
        }
        .no-results {
            color: #ffc107;
            font-size: 1.2em;
        }
        .election-inactive {
            color: #dc3545;
            font-weight: bold;
            font-size: 1.5em;
            text-align: center;
            margin-bottom: 30px;
        }
        .table-header {
            background-color: #007bff;
            color: #ffffff;
            text-align: center;
        }
        .table th, .table td {
            vertical-align: middle;
        }
        .result-info {
            font-size: 1.2em;
            font-weight: bold;
            margin-top: 20px;
            text-align: center;
        }
    </style>
</head>
<% 
    // Retrieve the user_id from the session
    Integer userId = (Integer) session.getAttribute("user_id");
%>
<body>
    <header class="bg-primary text-white py-3">
        <div class="container d-flex justify-content-between align-items-center">
            <div>
                <!-- Passing userId as a query parameter -->
                <a href="user_election.jsp?userId=<%= userId %>" class="btn btn-warning me-2">Elections</a>
                <a href="user_result.jsp?userId=<%= userId %>" class="btn btn-success me-2">View Results</a>
                <a href="user_profile.jsp?userId=<%= userId %>" class="btn btn-info">Profile</a>
            </div>
            <div>
                <a href="user_login.jsp" class="btn btn-danger">Logout</a>
            </div>
        </div>
    </header>

    <!-- Search Box -->
    <div class="container my-4">
        <form action="user_result.jsp" method="get">
            <div class="input-group">
                <select name="electionId" class="form-control" required>
                    <option value="">Select Election</option>
                    <% 
                        if (userId != null) {
                            try (Connection con = DBConnection.getConnection()) {
                                String electionQuery = "SELECT e.election_id, e.election_name FROM elections e " +
                                                       "JOIN user_approval ua ON e.election_id = ua.election_id " +
                                                       "WHERE ua.user_id = ? AND ua.is_approved = TRUE";
                                PreparedStatement pst = con.prepareStatement(electionQuery);
                                pst.setInt(1, userId);
                                ResultSet rs = pst.executeQuery();
                                while (rs.next()) {
                                    int electionId = rs.getInt("election_id");
                                    String electionName = rs.getString("election_name");
                                    out.println("<option value='" + electionId + "'>" + electionName + "</option>");
                                }
                            } catch (Exception e) {
                                out.println("<option value=''>Error fetching elections.</option>");
                            }
                        }
                    %>
                </select>
                <button class="btn btn-primary" type="submit">Search</button>
            </div>
        </form>
    </div>

    <!-- Main Content -->
    <main class="container my-5">
        <h2>Election Results</h2>
        <% 
            String electionIdStr = request.getParameter("electionId");
            if (electionIdStr != null && !electionIdStr.isEmpty()) {
                int electionId = Integer.parseInt(electionIdStr);
                try (Connection con = DBConnection.getConnection()) {
                    // Check if election is active
                    String checkStatusQuery = "SELECT is_active FROM elections WHERE election_id = ?";
                    PreparedStatement pstStatus = con.prepareStatement(checkStatusQuery);
                    pstStatus.setInt(1, electionId);
                    ResultSet rsStatus = pstStatus.executeQuery();
                    
                    if (rsStatus.next()) {
                        boolean isActive = rsStatus.getBoolean("is_active");

                        if (isActive) {
                            out.println("<p class='election-inactive'>This election is still active. Results will be available once the election ends.</p>");
                        } else {
                            // Fetch all candidates for the selected election
                            String candidatesQuery = "SELECT c.candidate_id, c.candidate_name, COUNT(v.vote_id) AS vote_count " +
                                                      "FROM candidates c LEFT JOIN votes v ON c.candidate_id = v.candidate_id AND v.election_id = ? " +
                                                      "WHERE c.election_id = ? GROUP BY c.candidate_id";
                            // Change the PreparedStatement to allow scrolling
                            PreparedStatement pstCandidates = con.prepareStatement(candidatesQuery, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                            pstCandidates.setInt(1, electionId);
                            pstCandidates.setInt(2, electionId);
                            ResultSet rsCandidates = pstCandidates.executeQuery();

                            if (!rsCandidates.isBeforeFirst()) {
                                out.println("<p class='no-results'>No candidates found for this election.</p>");
                            } else {
                                int maxVotes = 0;
                                String winnerName = "";

                                while (rsCandidates.next()) {
                                    int voteCount = rsCandidates.getInt("vote_count");
                                    if (voteCount > maxVotes) {
                                        maxVotes = voteCount;
                                        winnerName = rsCandidates.getString("candidate_name");
                                    }
                                }

                                // Display winner in a separate card
                                out.println("<div class='winner-card'>");
                                out.println("<h3>Congratulations to the Winner!</h3>");
                                out.println("<p>The winner is: <strong>" + winnerName + "</strong></p>");
                                out.println("<p>Well done! This candidate received the most votes.</p>");
                                out.println("</div>");

                                // Rewind the ResultSet and display all candidates
                                rsCandidates.beforeFirst();
                                out.println("<table class='table table-bordered'>");
                                out.println("<thead class='table-header'><tr><th>Candidate Name</th><th>Vote Count</th></tr></thead>");
                                out.println("<tbody>");

                                while (rsCandidates.next()) {
                                    String candidateName = rsCandidates.getString("candidate_name");
                                    int voteCount = rsCandidates.getInt("vote_count");
                                    out.println("<tr class='candidate-row'><td>" + candidateName + "</td><td>" + voteCount + "</td></tr>");
                                }
                                out.println("</tbody>");
                                out.println("</table>");
                            }
                        }
                    }
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error fetching election results: " + e.getMessage() + "</p>");
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
