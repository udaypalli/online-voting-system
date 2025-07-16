<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cast Your Vote</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <style>
    body {
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }
    main {
        flex: 1;
    }
    .candidate-card {
        border: 2px solid #ddd;
        padding: 20px;
        margin-bottom: 20px;
        border-radius: 10px;
        transition: transform 0.3s ease;
        background-color: #f9f9f9;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
    }
    .candidate-card:hover {
        transform: scale(1.05);
        box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.2);
    }
    .candidate-card input[type="radio"] {
        margin-right: 10px;
    }
    .candidate-info {
        margin-top: 15px;
    }
    .candidate-card label {
        font-size: 1.2em;
        font-weight: bold;
    }
    .candidate-name {
        font-size: 1.5em;
        color: #007bff;
    }
    .candidate-description {
        color: #555;
    }
    .btn {
        width: 100%;
        background-color: #007bff;
        color: white;
    }
    .btn:hover {
        background-color: #0056b3;
    }

    /* Border around the content container */
    .container {
        border: 2px solid #007bff; /* Blue border around the content */
        border-radius: 10px;
        padding: 20px;
    }
</style>

</head>
<body>

<%
    // Retrieve election ID and user ID from session
    String electionId = request.getParameter("electionId");
    int userId = session.getAttribute("user_id") != null ? (int) session.getAttribute("user_id") : 0;

    if (userId == 0) {
        out.println("<div class='alert alert-warning'>Please login to cast your vote.</div>");
        return;
    }

    // Fetch election details
    String electionName = "";
    String electionDescription = "";
    Date startDate = null;
    Date endDate = null;

    try (Connection con = DBConnection.getConnection()) {
        String sql = "SELECT election_name, description, start_date, end_date FROM elections WHERE election_id = ?";
        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, Integer.parseInt(electionId));
        ResultSet rs = pst.executeQuery();
        if (rs.next()) {
            electionName = rs.getString("election_name");
            electionDescription = rs.getString("description");
            startDate = rs.getDate("start_date");
            endDate = rs.getDate("end_date");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (electionName.isEmpty()) {
        out.println("<div class='alert alert-danger'>Election not found or has ended.</div>");
        return;
    }

    // Handle vote casting
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String candidateId = request.getParameter("candidate_id");

        // Check if the user has already voted in this election
        try (Connection con = DBConnection.getConnection()) {
            String checkVoteQuery = "SELECT * FROM votes WHERE election_id = ? AND user_id = ?";
            PreparedStatement checkVoteStmt = con.prepareStatement(checkVoteQuery);
            checkVoteStmt.setInt(1, Integer.parseInt(electionId));
            checkVoteStmt.setInt(2, userId);
            ResultSet checkVoteRs = checkVoteStmt.executeQuery();

            if (checkVoteRs.next()) {
                out.println("<div class='alert alert-warning'>You have already voted in this election.</div>");
            } else {
                // Insert the vote into the database
                String voteQuery = "INSERT INTO votes (election_id, candidate_id, user_id) VALUES (?, ?, ?)";
                PreparedStatement voteStmt = con.prepareStatement(voteQuery);
                voteStmt.setInt(1, Integer.parseInt(electionId));
                voteStmt.setInt(2, Integer.parseInt(candidateId));
                voteStmt.setInt(3, userId);
                int rowsInserted = voteStmt.executeUpdate();

                if (rowsInserted > 0) {
                    out.println("<div class='alert alert-success'>Vote cast successfully.</div>");
                } else {
                    out.println("<div class='alert alert-danger'>Error casting vote. Please try again later.</div>");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<div class='alert alert-danger'>Error processing your vote. Please try again later.</div>");
        }
    }
%>

<!-- Election Details -->
<div class="container mt-5">
    <h2 class="mb-4">Cast Your Vote for Election: <%= electionName %></h2>
    <p><strong>Description:</strong> <%= electionDescription %></p>
    <p><strong>Start Date:</strong> <%= startDate %></p>
    <p><strong>End Date:</strong> <%= endDate %></p>

    <h3 class="mt-4">Candidates</h3>
    <form action="user_vote.jsp?electionId=<%= electionId %>" method="POST">
        <div class="row">
            <%
                try (Connection con = DBConnection.getConnection()) {
                    String candidateQuery = "SELECT candidate_id, candidate_name, age, gender, description FROM candidates WHERE election_id = ?";
                    PreparedStatement candidateStmt = con.prepareStatement(candidateQuery);
                    candidateStmt.setInt(1, Integer.parseInt(electionId));
                    ResultSet candidateRs = candidateStmt.executeQuery();

                    while (candidateRs.next()) {
            %>
                        <div class="col-md-4">
                            <div class="candidate-card">
                                <input type="radio" name="candidate_id" value="<%= candidateRs.getInt("candidate_id") %>" id="candidate_<%= candidateRs.getInt("candidate_id") %>" required>
                                <label for="candidate_<%= candidateRs.getInt("candidate_id") %>" class="candidate-name"><%= candidateRs.getString("candidate_name") %></label>
                                
                                <div class="candidate-info">
                                    <p><strong>Age:</strong> <%= candidateRs.getInt("age") %></p>
                                    <p><strong>Gender:</strong> <%= candidateRs.getString("gender") %></p>
                                    <p><strong>Description:</strong> <%= candidateRs.getString("description") %></p>
                                </div>
                            </div>
                        </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
        </div>

        <button type="submit" class="btn btn-primary mt-3">Cast Vote</button>
    </form>
</div>

<%-- Redirect to dashboard after vote --%>
<script>
    setTimeout(function() {
        window.location.href = "user_dashboard.jsp";
    }, 3000000); // 3 seconds delay before redirect
</script>

<script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
