-- A. Total number of voters per constituency

SELECT 
  cl.ConstituencyID,
  c.Name AS ConstituencyName,
  COUNT(DISTINCT v.VoterID) AS TotalVoters
FROM 
  Voter v
JOIN 
  Locality l ON v.City = l.VillageOrCity
JOIN 
  ConstituencyLocality cl ON cl.LocalityID = l.LocalityID
JOIN 
  Constituency c ON c.ConstituencyID = cl.ConstituencyID
GROUP BY cl.ConstituencyID, c.Name
ORDER BY TotalVoters DESC;

-- B. Voter gender distribution per constituency
SELECT 
  cl.ConstituencyID,
  c.Name AS ConstituencyName,
  v.Gender,
  COUNT(*) AS GenderCount
FROM 
  Voter v
JOIN 
  Locality l ON v.City = l.VillageOrCity
JOIN 
  ConstituencyLocality cl ON cl.LocalityID = l.LocalityID
JOIN 
  Constituency c ON c.ConstituencyID = cl.ConstituencyID
GROUP BY cl.ConstituencyID, c.Name, v.Gender
ORDER BY cl.ConstituencyID;

-- C. Upcoming elections in next 6 months
SELECT * 
FROM Election
WHERE StartDate > '2023-01-24' AND StartDate <= DATE_ADD('2023-01-24', INTERVAL 6 MONTH);

-- D. Age group wise voter segmentation 
SELECT 
  CASE 
    WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 18 AND 25 THEN '18-25'
    WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 26 AND 35 THEN '26-35'
    WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 36 AND 50 THEN '36-50'
    ELSE '51+'
  END AS AgeGroup,
  COUNT(*) AS TotalVoters
FROM Voter
GROUP BY AgeGroup
ORDER BY AgeGroup;

-- E. Count of candidates by party in current election
SELECT 
  e.Year, 
  e.Type,
  p.Name AS PartyName,
  COUNT(DISTINCT cn.CandidateID) AS CandidateCount
FROM 
  CandidateNominations cn
JOIN 
  Party p ON cn.PartyID = p.PartyID
JOIN 
  Election e ON e.ElectionID = cn.ElectionID
GROUP BY e.Year, e.Type, p.Name
ORDER BY e.Year DESC, CandidateCount DESC;

	
-- F. Top 5 localities with the highest number of voters
SELECT 
  City, 
  COUNT(*) AS VoterCount
FROM Voter
GROUP BY City
ORDER BY VoterCount DESC
LIMIT 5;


-- G.Turnout Percentage per Constituency

SELECT 
  cl.ConstituencyID,
  c.Name AS ConstituencyName,
  ROUND(COUNT(DISTINCT vp.VoterID) * 100.0 / COUNT(DISTINCT vb.VoterID), 2) AS TurnoutPercentage
FROM 
  VoterBoothMap vb
LEFT JOIN 
  VoterParticipation vp 
    ON vb.VoterID = vp.VoterID AND vb.ElectionID = vp.ElectionID
JOIN 
  Booth b ON vb.BoothID = b.BoothID
JOIN 
  PollingStation ps ON b.PollingStationID = ps.PollingStationID
JOIN 
  Locality l ON ps.LocalityID = l.LocalityID
JOIN 
  ConstituencyLocality cl ON cl.LocalityID = l.LocalityID
JOIN 
  Constituency c ON c.ConstituencyID = cl.ConstituencyID
WHERE 
  vb.ElectionID = 'ELEC-2023-PAN-003'
GROUP BY cl.ConstituencyID
ORDER BY TurnoutPercentage DESC;

-- H. Candidate Property Worth Distribution
SELECT 
  c.Name AS Constituency,
  cn.PropertyWorth,
  ca.FirstName,
  ca.LastName,
  p.Name AS PartyName
FROM 
  CandidateNominations cn
JOIN 
  Constituency c ON c.ConstituencyID = cn.ConstituencyID
JOIN 
  Candidate cand ON cand.CandidateID = cn.CandidateID
JOIN 
  Voter ca ON ca.VoterID = cand.VoterID
LEFT JOIN 
  Party p ON p.PartyID = cn.PartyID
ORDER BY cn.PropertyWorth DESC;

-- I. Peak Voting Hours
SELECT 
  HOUR(TimeStamp) AS HourOfDay,
  COUNT(*) AS VotesCast
FROM VoterParticipation
GROUP BY HOUR(TimeStamp)
ORDER BY VotesCast DESC;

-- J. Most Popular Candidates by Vote Count
SELECT 
  v.FirstName,
  v.LastName,
  p.Name AS PartyName,
  COUNT(*) AS VoteCount
FROM Vote vt
JOIN Candidate c ON c.CandidateID = vt.CandidateID
JOIN Voter v ON v.VoterID = c.VoterID
LEFT JOIN CandidateNominations cn ON cn.CandidateID = c.CandidateID
LEFT JOIN Party p ON cn.PartyID = p.PartyID
GROUP BY vt.CandidateID,v.FirstName,v.LastName,PartyName
ORDER BY VoteCount DESC;

-- K.Winners per consistuency 
SELECT
  e.ElectionID,
  e.Type AS ElectionType,
  e.Year AS ElectionYear,
  c.ConstituencyID,
  c.Name AS ConstituencyName,
  cn.CandidateID,
  vtr.FirstName,
  vtr.LastName,
  COUNT(v.VoteID) AS VoteCount
FROM
  CandidateNominations AS cn
JOIN Election AS e
  ON e.ElectionID = cn.ElectionID
JOIN Constituency AS c
  ON c.ConstituencyID = cn.ConstituencyID
JOIN Candidate AS cand
  ON cand.CandidateID = cn.CandidateID
JOIN Voter AS vtr
  ON vtr.VoterID = cand.VoterID
LEFT JOIN Vote AS v
  ON v.CandidateID = cn.CandidateID
 AND v.ElectionID  = cn.ElectionID
GROUP BY
  e.ElectionID,
  e.Type,
  e.Year,
  c.ConstituencyID,
  c.Name,
  cn.CandidateID,
  vtr.FirstName,
  vtr.LastName
ORDER BY
  e.ElectionID,
  c.ConstituencyID,
  VoteCount DESC;
  
