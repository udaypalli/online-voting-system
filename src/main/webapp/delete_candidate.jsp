<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.votingsystem.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Candidate</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-5">
        <div class="card">
            <div class="card-body">
                <% 
                    int candidateId = -1;
                    try {
                        candidateId = Integer.parseInt(request.getParameter("id"));
                    } catch (NumberFormatException e) {
                        out.println("<div class='alert alert-danger'>Invalid candidate ID!</div>");
                        response.sendRedirect("admin_candidates.jsp");
                        return;
                    }

                    Connection con = null;
                    PreparedStatement pst = null;

                    try {
                        con = DBConnection.getConnection();
                        String sql = "DELETE FROM candidates WHERE candidate_id = ?";
                        pst = con.prepareStatement(sql);
                        pst.setInt(1, candidateId);
                        int result = pst.executeUpdate();

                        if (result > 0) {
                            out.println("<div class='alert alert-success'>Candidate deleted successfully!</div>");
                        } else {
                            out.println("<div class='alert alert-danger'>No candidate found with the specified ID!</div>");
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
                %>
                <a href="admin_candidates.jsp" class="btn btn-primary mt-3">Back to Candidate List</a>
            </div>
        </div>
    </div>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
