<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Voting System</title>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
</head>
<body>
    <!-- Header -->
    <header class="bg-primary text-white py-3">
        <div class="container d-flex justify-content-between align-items-center">
            <h1 class="h4 mb-0">Online Voting System</h1>
            <div>
                <a href="admin_login.jsp" class="btn btn-light btn-sm me-2">Admin Login</a>
                <a href="user_login.jsp" class="btn btn-light btn-sm">User Login</a>

            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="container text-center my-5">
        <h1 class="display-4 fw-bold">Welcome to the Online Voting System!</h1>
        <p class="mt-3">
            Our Website is designed to make the voting process for the Student Council Elections, MLA Elections, 
            Housing Society Elections easy and accessible for all. With just a few clicks, you can cast your vote and 
            make your voice heard in the decision-making process.
        </p>
        <img src="images/voting_image.jpg" alt="Voting" class="img-fluid mt-4" style="max-height: 300px;">
    </main>

    <!-- Footer -->
    <footer class="bg-light text-center py-3">
        <p class="mb-0">@ 2024 Online Voting System designed by Uday Palli</p>
    </footer>

    <script src="bootstrap/js/bootstrap.bundle.min.js"></script>
</body>
</html>
