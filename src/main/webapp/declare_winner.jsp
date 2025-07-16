<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Declare Winner</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
</head>
<body>
<%
    // Declare connection object outside try block
    Connection con = null;

    // Get election_id and winner_name from the form parameters
    String electionId = request.getParameter("election_id");
    String winnerName = request.getParameter("winner");

    if (electionId != null && winnerName != null) {
        try {
            con = DBConnection.getConnection(); // Get the connection here
            // Check if the election is already closed
            String checkElectionSql = "SELECT is_active FROM elections WHERE election_id = ?";
            PreparedStatement pstCheckElection = con.prepareStatement(checkElectionSql);
            pstCheckElection.setInt(1, Integer.parseInt(electionId));
            ResultSet rsCheck = pstCheckElection.executeQuery();

            if (rsCheck.next()) {
                int isActive = rsCheck.getInt("is_active");

                if (isActive == 0) {
                    // If election is closed, show message that results can't be modified
                    out.println("<div class='alert alert-warning'>Election results have already been declared. No further changes can be made.</div>");
                    return;
                }
            }

            // Turn off autocommit to manage transactions manually
            con.setAutoCommit(false);

            // Step 1: Fetch the candidate_id for the winner based on winner_name
            String sqlCandidate = "SELECT candidate_id FROM candidates WHERE candidate_name = ? AND election_id = ?";
            PreparedStatement pstCandidate = con.prepareStatement(sqlCandidate);
            pstCandidate.setString(1, winnerName); // Using winnerName to find candidate_id
            pstCandidate.setInt(2, Integer.parseInt(electionId)); // election_id for this specific election
            ResultSet rsCandidate = pstCandidate.executeQuery();

            if (rsCandidate.next()) {
                int winnerCandidateId = rsCandidate.getInt("candidate_id");

                // Step 2: Update the election to set the winner and mark it as inactive
                String updateElectionSql = "UPDATE elections SET winner_id = ?, is_active = 0 WHERE election_id = ?";
                PreparedStatement pstUpdateElection = con.prepareStatement(updateElectionSql);
                pstUpdateElection.setInt(1, winnerCandidateId); // Set the winner's candidate_id
                pstUpdateElection.setInt(2, Integer.parseInt(electionId)); // election_id

                int rowsAffected = pstUpdateElection.executeUpdate();

                if (rowsAffected > 0) {
                    // Commit the transaction after the update
                    con.commit();
                    out.println("<div class='alert alert-success'>Winner has been declared successfully and election results are locked.</div>");
                } else {
                    // Rollback if no rows were affected
                    con.rollback();
                    out.println("<div class='alert alert-danger'>Error declaring the winner. Please try again.</div>");
                }
            } else {
                out.println("<div class='alert alert-danger'>Error: Candidate not found.</div>");
            }
        } catch (SQLException e) {
            try {
                if (con != null) {
                    con.rollback(); // Rollback the transaction if something goes wrong
                }
            } catch (SQLException ex) {
                out.println("<div class='alert alert-danger'>Error rolling back transaction: " + ex.getMessage() + "</div>");
            }
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        } finally {
            // Ensure the connection is closed if it was opened
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException e) {
                    out.println("<div class='alert alert-danger'>Error closing connection: " + e.getMessage() + "</div>");
                }
            }
        }
    } else {
        out.println("<div class='alert alert-danger'>Invalid request. Please try again.</div>");
    }
%>

<!-- Back Button to go back to the election results page -->
<div class="mt-3">
    <a href="admin_results.jsp?election_id=<%= electionId %>" class="btn btn-secondary">Back to Election Results</a>
</div>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
