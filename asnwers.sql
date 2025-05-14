-- Enhanced Library Management System Database (MySQL)

-- ------------------------------------------------------------------------------------------------
-- 1. Database Creation
-- ------------------------------------------------------------------------------------------------
--    * Create the database if it doesn't exist.  This ensures a clean environment.
--    * We use a specific character set and collation for better internationalization support
--      and consistent string comparisons.
CREATE DATABASE IF NOT EXISTS LibraryManagementSystem
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

--    * Switch to the newly created database.  All subsequent operations will be performed
--      within this database.
USE LibraryManagementSystem;

-- ------------------------------------------------------------------------------------------------
-- 2. Table Creation
-- ------------------------------------------------------------------------------------------------
--    * We use DROP TABLE IF EXISTS before each CREATE TABLE to handle cases where the
--      script is run multiple times.  This prevents errors due to existing tables.
--    * Explicitly define the character set and collation for each table.
--    * Add comments to explain the purpose of each table and column.
-- ------------------------------------------------------------------------------------------------

-- 2.1 Author Table
--    * Stores information about authors.
DROP TABLE IF EXISTS Author;
CREATE TABLE Author (
    AuthorID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Use UNSIGNED for IDs
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Biography TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Audit trail
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Audit trail
    INDEX (LastName) -- Index for faster searching by last name
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2.2 Genre Table
--    * Stores information about book genres.
DROP TABLE IF EXISTS Genre;
CREATE TABLE Genre (
    GenreID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    GenreName VARCHAR(255) NOT NULL UNIQUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Audit trail
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Audit trail
    INDEX (GenreName)
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2.3 Publisher Table
--    * Stores information about book publishers
DROP TABLE IF EXISTS Publisher;
CREATE TABLE Publisher (
    PublisherID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    PublisherName VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Audit trail
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Audit trail
    INDEX (PublisherName)
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;


-- 2.4 Book Table
--    * Stores information about books.
DROP TABLE IF EXISTS Book;
CREATE TABLE Book (
    BookID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ISBN VARCHAR(13) NOT NULL UNIQUE, --  ISBN-13 is the standard
    PublicationYear SMALLINT UNSIGNED, --  Reasonable range for years
    PublisherID INT UNSIGNED,
    TotalCopies INT UNSIGNED NOT NULL,
    AvailableCopies INT UNSIGNED NOT NULL,
    GenreID INT UNSIGNED,
    CoverImageURL VARCHAR(2048), -- Store URL to cover image
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Audit trail
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Audit trail
    FOREIGN KEY (GenreID) REFERENCES Genre(GenreID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID),
    CONSTRAINT CHK_AvailableCopies CHECK (AvailableCopies <= TotalCopies), -- Constraint for data integrity
    INDEX (Title),       -- Index for faster searching
    INDEX (ISBN)
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2.5 BookAuthor Table
--    * Junction table for the many-to-many relationship between Book and Author.
DROP TABLE IF EXISTS BookAuthor;
CREATE TABLE BookAuthor (
    BookID INT UNSIGNED,
    AuthorID INT UNSIGNED,
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE, --  ON DELETE CASCADE
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID) ON DELETE CASCADE, -- ON DELETE CASCADE
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Audit trail
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Audit trail
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2.6 Member Table
--    * Stores information about library members.
DROP TABLE IF EXISTS Member;
CREATE TABLE Member (
    MemberID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    MembershipDate DATE NOT NULL,
    AccountStatus ENUM('Active', 'Suspended', 'Inactive') NOT NULL DEFAULT 'Active',
    DateOfBirth DATE,
    ProfilePictureURL VARCHAR(2048),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Audit trail
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Audit trail
    INDEX (LastName),
    INDEX (Email)
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2.7 Loan Table
--    * Stores information about book loans.
DROP TABLE IF EXISTS Loan;
CREATE TABLE Loan (
    LoanID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    MemberID INT UNSIGNED,
    BookID INT UNSIGNED,
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    LoanStatus ENUM('Active', 'Overdue', 'Returned', 'Lost') NOT NULL,
    FineAmount DECIMAL(10, 2) UNSIGNED DEFAULT 0.00,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Audit trail
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Audit trail
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE, -- ON DELETE CASCADE
    FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE RESTRICT,  -- ON DELETE RESTRICT
    CONSTRAINT CHK_ReturnDate CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate),
    CONSTRAINT CHK_DueDateAfterLoanDate CHECK (DueDate >= LoanDate),
    INDEX (MemberID),
    INDEX (BookID),
    INDEX (LoanStatus)
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2.8  Reservation Table
--     * Stores information about book reservations
DROP TABLE IF EXISTS Reservation;
CREATE TABLE Reservation (
    ReservationID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    MemberID INT UNSIGNED,
    BookID INT UNSIGNED,
    ReservationDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Pending', 'Available', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Pending',
    PickupDate DATE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE RESTRICT,
    INDEX (MemberID),
    INDEX (BookID),
    INDEX (Status)
)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
