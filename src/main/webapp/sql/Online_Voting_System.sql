-- Create the database
CREATE DATABASE OnlineVotingSystem;
USE OnlineVotingSystem;

-- Table to store Admin details
CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mobile VARCHAR(15),
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store User details
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age varchar(100),
    gender ENUM('Male', 'Female', 'Other'),
    address TEXT,
 
    mobile VARCHAR(15),
    registered_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store Elections created by Admins
CREATE TABLE elections (
    election_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL, -- Link to the admin who created this election
    election_name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    winner_id INT DEFAULT NULL,
    is_active TINYINT(1) DEFAULT 1
    
);

-- Table to store Candidates in each Election
CREATE TABLE candidates (
    candidate_id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT NOT NULL, -- Link to the election
    candidate_name VARCHAR(100) NOT NULL,
    age INT,
    gender ENUM('Male', 'Female', 'Other'),
    description TEXT, -- Candidate description instead of party name
    
    mobile VARCHAR(15)
);

-- Table to store Votes cast by Users in each Election
CREATE TABLE votes (
    vote_id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT NOT NULL, -- Link to the election
    candidate_id INT NOT NULL, -- Link to the chosen candidate
    user_id INT NOT NULL, -- Link to the user who voted
    vote_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (election_id, user_id) -- Ensures one vote per election per user
);

-- Table to manage User Approval for participating in each Election
CREATE TABLE user_approval (
    approval_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL, -- Link to the user
    election_id INT NOT NULL, -- Link to the election
    is_approved BOOLEAN DEFAULT FALSE, -- Admin approval status
    requested_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);