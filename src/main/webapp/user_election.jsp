<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Elections</title>
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
        .card {
            margin-bottom: 20px;
        }
        .btn-actions {
            margin-right: 10px;
        }
    </style>
</head>
<% 
    // Retrieve the user_id from the session
    Integer usserId = (Integer) session.getAttribute("user_id");
%>
<body>
    <header class="bg-primary text-white py-3">
    <div class="container d-flex justify-content-between align-items-center">
        <div>
            <!-- Passing userId as a query parameter -->
            <a href="user_election.jsp?userId=<%= usserId %>" class="btn btn-warning me-2">Elections</a>
            <a href="user_result.jsp?userId=<%= usserId %>" class="btn btn-success me-2">View Results</a>
            <a href="user_profile.jsp?userId=<%= usserId %>" class="btn btn-info">Profile</a>
        </div>
        <div>
            <a href="user_login.jsp" class="btn btn-danger">Logout</a>
        </div>
    </div>
</header>

    <!-- Search Box -->
    <div class="container my-4">
        <form action="user_election.jsp" method="get">
            <div class="input-group">
                <input type="text" class="form-control" placeholder="Search by Election ID" name="searchElectionId" value="<%= request.getParameter("searchElectionId") != null ? request.getParameter("searchElectionId") : "" %>">
                <button class="btn btn-primary" type="submit">Search</button>
            </div>
        </form>
    </div>

    <!-- Main Content -->
    <main class="container my-5">
        <h2>Available Elections</h2>
        <div class="card">
            <div class="card-body">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Election ID</th>
                            <th>Election Name</th>
                            <th>Description</th>
                            <th>Start Date</th>
                            <th>End Date</th>
                            <th>Eligibility</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Integer userId = (Integer) session.getAttribute("user_id");
                            if (userId == null) {
                                response.sendRedirect("user_login.jsp");
                                return;
                            }

                            String searchElectionId = request.getParameter("searchElectionId");
                            String query = "SELECT * FROM elections";
                            if (searchElectionId != null && !searchElectionId.trim().isEmpty()) {
                                query += " WHERE election_id = ?";
                            }

                            try (Connection con = DBConnection.getConnection()) {
                                PreparedStatement pst = con.prepareStatement(query);

                                if (searchElectionId != null && !searchElectionId.trim().isEmpty()) {
                                    pst.setInt(1, Integer.parseInt(searchElectionId));
                                }

                                ResultSet rs = pst.executeQuery();

                                if (!rs.isBeforeFirst()) {
                                    out.println("<tr><td colspan='7' class='text-warning'>No elections found for the given ID.</td></tr>");
                                }

                                while (rs.next()) {
                                    int electionId = rs.getInt("election_id");
                                    String electionName = rs.getString("election_name");
                                    String description = rs.getString("description");
                                    Date startDate = rs.getDate("start_date");
                                    Date endDate = rs.getDate("end_date");

                                    // Check eligibility
                                    String eligibility = "Not Approved";
                                    boolean isEligible = false;
                                    String eligibilitySql = "SELECT is_approved FROM user_approval WHERE user_id = ? AND election_id = ?";
                                    try (PreparedStatement eligibilityPst = con.prepareStatement(eligibilitySql)) {
                                        eligibilityPst.setInt(1, userId);
                                        eligibilityPst.setInt(2, electionId);
                                        ResultSet eligibilityRs = eligibilityPst.executeQuery();
                                        if (eligibilityRs.next() && eligibilityRs.getBoolean("is_approved")) {
                                            eligibility = "Approved";
                                            isEligible = true;
                                        }
                                    }

                                    out.println("<tr>");
                                    out.println("<td>" + electionId + "</td>");
                                    out.println("<td>" + electionName + "</td>");
                                    out.println("<td>" + description + "</td>");
                                    out.println("<td>" + startDate + "</td>");
                                    out.println("<td>" + endDate + "</td>");
                                    out.println("<td>" + eligibility + "</td>");
                                    out.println("<td>");
                                    out.println("<a href='user_result.jsp?electionId=" + electionId + "&userId=" + userId + "' class='btn btn-success btn-actions'>View Result</a>");

                                    if (!isEligible) {
                                        out.println("<form action='user_election.jsp' method='post' style='display:inline;'>");
                                        out.println("<input type='hidden' name='action' value='apply'>");
                                        out.println("<input type='hidden' name='userId' value='" + userId + "'>");
                                        out.println("<input type='hidden' name='electionId' value='" + electionId + "'>");
                                        out.println("<button type='submit' class='btn btn-primary btn-actions'>Apply</button>");
                                        out.println("</form>");
                                    }

                                    if (isEligible) {
                                        out.println("<a href='user_vote.jsp?electionId=" + electionId + "&userId=" + userId + "' class='btn btn-warning btn-actions'>Cast Vote</a>");
                                    }

                                    out.println("</td>");
                                    out.println("</tr>");
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                            }

                            // Handle applying for election participation
                            String action = request.getParameter("action");
                            if ("apply".equals(action)) {
                                int electionId = Integer.parseInt(request.getParameter("electionId"));
                                try (Connection con = DBConnection.getConnection()) {
                                    String applySql = "INSERT INTO user_approval (user_id, election_id) VALUES (?, ?)";
                                    PreparedStatement applyPst = con.prepareStatement(applySql);
                                    applyPst.setInt(1, userId);
                                    applyPst.setInt(2, electionId);
                                    applyPst.executeUpdate();
                                    out.println("<div class='alert alert-success'>Application sent for approval!</div>");
                                } catch (Exception e) {
                                    out.println("<div class='alert alert-danger'>Error applying for election: " + e.getMessage() + "</div>");
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-dark text-white text-center py-3 mt-auto">
        <p class="mb-0">&copy; 2024 Online Voting System</p>
    </footer>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
