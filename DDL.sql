create database ElectionManagementSystem;
use ElectionManagementSystem;


CREATE TABLE Election (
    ElectionID VARCHAR(50) PRIMARY KEY,
    Year       YEAR NOT NULL,
    Type       VARCHAR(50) NOT NULL,          -- "Lok Sabha", "Vidhan Sabha", etc.
    StartDate  DATE NOT NULL,
    EndDate    DATE NOT NULL,
    NominationStartDate DATE NOT NULL,
    NominationEndDate DATE NOT NULL,
    CHECK (EndDate >= StartDate),
    CHECK (NominationEndDate >= NominationStartDate)
);

CREATE TABLE Party (
    PartyID       VARCHAR(50) PRIMARY KEY,
    Name          VARCHAR(100) UNIQUE,
    Abbreviation  VARCHAR(20) UNIQUE,
    Symbol        VARCHAR(100)
);

CREATE TABLE Voter (
    VoterID      VARCHAR(50) PRIMARY KEY,
    FirstName    VARCHAR(100) NOT NULL,
    MiddleName   VARCHAR(100),
    LastName     VARCHAR(100),
    Gender       VARCHAR(10) NOT NULL,
    DOB          DATE NOT NULL,
    PhoneNumber  VARCHAR(10) NOT NULL,
    is_Dead      BOOLEAN DEFAULT 0,
    AadhaarNo    VARCHAR(12) UNIQUE,
    StreetName   VARCHAR(100),
    City         VARCHAR(100) NOT NULL,
    District     VARCHAR(100),
    State        VARCHAR(100) NOT NULL,
    PinCode      INT NOT NULL,
    -- CHECK (TIMESTAMPDIFF(YEAR, DOB, CURDATE()) >= 18),
    CHECK (Gender IN ('Male','Female','Other'))
);

CREATE TABLE Constituency (
    ConstituencyID VARCHAR(50) PRIMARY KEY,
    Name           VARCHAR(100) UNIQUE,       -- no two constituencies share the same name
    Status         VARCHAR(100),
    CHECK (Status IN ('active', 'inactive'))
);

CREATE TABLE Locality (
    LocalityID    VARCHAR(50) PRIMARY KEY,
    State         VARCHAR(100),
    District      VARCHAR(100),
    Zone          VARCHAR(50),
    VillageOrCity VARCHAR(100)
);

CREATE TABLE ElectionConstituency (
    ElectionID     VARCHAR(50),
    ConstituencyID VARCHAR(50),
    PRIMARY KEY (ElectionID, ConstituencyID),
    FOREIGN KEY (ElectionID)     REFERENCES Election(ElectionID)
                     ON DELETE RESTRICT
                     ON UPDATE RESTRICT ,
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID)
                     ON DELETE RESTRICT
                     ON UPDATE RESTRICT
);

CREATE TABLE ConstituencyLocality (
    ConstituencyID VARCHAR(50),
    LocalityID     VARCHAR(50),
    PRIMARY KEY    (ConstituencyID, LocalityID),
    FOREIGN KEY    (ConstituencyID) REFERENCES Constituency(ConstituencyID)
                   ON DELETE RESTRICT
                   ON UPDATE RESTRICT ,
    FOREIGN KEY    (LocalityID)     REFERENCES Locality(LocalityID)
                    ON DELETE RESTRICT
                    ON UPDATE RESTRICT
);

CREATE TABLE PollingStation (
    PollingStationID VARCHAR(50) PRIMARY KEY, 
    Name             VARCHAR(100),
    Address          VARCHAR(200),
    LocalityID       VARCHAR(50) NOT NULL,
    FOREIGN KEY (LocalityID) REFERENCES Locality(LocalityID)
                   ON DELETE RESTRICT
                   ON UPDATE RESTRICT
);

CREATE TABLE Booth (
    BoothID          VARCHAR(50) PRIMARY KEY,
    PollingStationID VARCHAR(50) NOT NULL,
    FOREIGN KEY (PollingStationID) REFERENCES PollingStation(PollingStationID)
                        ON DELETE RESTRICT
                        ON UPDATE RESTRICT
);

CREATE TABLE Candidate (
    CandidateID  VARCHAR(50) PRIMARY KEY,
    VoterID  VARCHAR(50) NOT NULL,
    PropertyWorth  BIGINT , 
    FOREIGN KEY (VoterID) REFERENCES Voter(VoterID)
               ON DELETE RESTRICT
               ON UPDATE RESTRICT
);

CREATE TABLE ElectionOfficer (
    OfficerID VARCHAR(50) PRIMARY KEY,
    VoterID   VARCHAR(50) NOT NULL,        -- officers are voters
    Role      VARCHAR(50),
    FOREIGN KEY (VoterID) REFERENCES Voter(VoterID)
);

CREATE TABLE OfficerAssignment (
    OfficerID  VARCHAR(50),
    ElectionID VARCHAR(50),
    BoothID    VARCHAR(50),
    PRIMARY KEY (OfficerID, ElectionID, BoothID),
    FOREIGN KEY (OfficerID)  REFERENCES ElectionOfficer(OfficerID),
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID),
    FOREIGN KEY (BoothID)    REFERENCES Booth(BoothID)
);

CREATE TABLE VoterBoothMap (
    VoterID    VARCHAR(50),
    ElectionID VARCHAR(50),
    BoothID    VARCHAR(50) NOT NULL,
    PRIMARY KEY (VoterID, ElectionID),
    FOREIGN KEY (VoterID)    REFERENCES Voter(VoterID)
                ON DELETE RESTRICT
                ON UPDATE RESTRICT,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
                ON DELETE RESTRICT
                ON UPDATE RESTRICT,
    FOREIGN KEY (BoothID)    REFERENCES Booth(BoothID)
                ON DELETE RESTRICT
                ON UPDATE RESTRICT
);
	
CREATE TABLE VoterParticipation (
    VoterID         VARCHAR(50),
    ElectionID      VARCHAR(50),
    MethodName      VARCHAR(20) NOT NULL,
    TimeStamp       DATETIME,
    PRIMARY KEY(VoterID,ElectionID),
    FOREIGN KEY (VoterID)    REFERENCES Voter(VoterID),
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID),
    CHECK (MethodName IN ('ballot', 'proxy', 'electronic', 'postal'))
);

CREATE TABLE Vote (
    VoteID  INT PRIMARY KEY,
    CandidateID VARCHAR(50) NOT NULL,
    ElectionID VARCHAR(50) NOT NULL,
    BoothID     VARCHAR(50) NOT NULL,
    VoteTime    DATETIME,
    FOREIGN KEY (CandidateID) REFERENCES Candidate(CandidateID),
    FOREIGN KEY (BoothID)     REFERENCES Booth(BoothID)
);


CREATE TABLE CandidateNominations (
   CandidateID    VARCHAR(50) NOT NULL,
   PartyID        VARCHAR(50),
   ElectionID     VARCHAR(50) NOT NULL,
   ConstituencyID VARCHAR(50) NOT NULL,
   NominationDate  DATE NOT NULL,
   Position VARCHAR(100) NOT NULL,
   PropertyWorth   INT NOT NULL DEFAULT 0,
   FOREIGN KEY (CandidateID)     REFERENCES Candidate(CandidateID),
   FOREIGN KEY (PartyID)        REFERENCES Party(PartyID),
   FOREIGN KEY (ElectionID)     REFERENCES Election(ElectionID),
   FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID),
   PRIMARY KEY(ElectionID, ConstituencyID, CandidateID)
);

