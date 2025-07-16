<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voter Dashboard</title>
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

    <!-- Main Content -->
    <main class="container my-5">
        <div class="row">
            <div class="col-md-6">
                <h3>Ongoing Elections</h3>
                <ul class="list-group">
                    <% 
                        // Fetch and display ongoing elections
                        try (Connection con = DBConnection.getConnection()) {
                            String query = "SELECT election_name, description, start_date, end_date FROM elections WHERE CURDATE() BETWEEN start_date AND end_date";
                            PreparedStatement pst = con.prepareStatement(query);
                            ResultSet rs = pst.executeQuery();
                            if (!rs.isBeforeFirst()) {
                                out.println("<li class='list-group-item'>No ongoing elections currently.</li>");
                            }
                            while (rs.next()) {
                                out.println("<li class='list-group-item'>");
                                out.println("<strong>" + rs.getString("election_name") + "</strong><br>");
                                out.println(rs.getString("description") + "<br>");
                                out.println("<small>Ends on: " + rs.getDate("end_date") + "</small>");
                                out.println("</li>");
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<li class='list-group-item text-danger'>Error fetching elections.</li>");
                        }
                    %>
                </ul>
            </div>
            <div class="col-md-6">
                <h3>Elections You're Participating In</h3>
                <ul class="list-group">
                    <% 
                        // Fetch and display elections the user is approved to participate in
                        int userId = session.getAttribute("user_id") != null ? (int) session.getAttribute("user_id") : 0;
                        if (userId > 0) {
                            try (Connection con = DBConnection.getConnection()) {
                                String query = "SELECT e.election_name, e.description FROM elections e " +
                                               "JOIN user_approval ua ON e.election_id = ua.election_id " +
                                               "WHERE ua.user_id = ? AND ua.is_approved = TRUE";
                                PreparedStatement pst = con.prepareStatement(query);
                                pst.setInt(1, userId);
                                ResultSet rs = pst.executeQuery();
                                if (!rs.isBeforeFirst()) {
                                    out.println("<li class='list-group-item'>You are not participating in any elections currently.</li>");
                                }
                                while (rs.next()) {
                                    out.println("<li class='list-group-item'>");
                                    out.println("<strong>" + rs.getString("election_name") + "</strong><br>");
                                    out.println(rs.getString("description"));
                                    out.println("</li>");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<li class='list-group-item text-danger'>Error fetching your elections.</li>");
                            }
                        } else {
                            out.println("<li class='list-group-item text-warning'>Please log in to view your elections.</li>");
                        }
                    %>
                </ul>
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
