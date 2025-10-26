DROP DATABASE gearmate;
CREATE DATABASE IF NOT EXISTS gearmate;
USE gearmate;

CREATE TABLE Department (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(150)
);


CREATE TABLE Station (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(150),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Department(id)
);


CREATE TABLE Firefighter (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ranks VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    station_id INT,
    department_id INT,
    FOREIGN KEY (station_id) REFERENCES Station(id),
    FOREIGN KEY (department_id) REFERENCES Department(id)
);


CREATE TABLE Gear (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    gear_name VARCHAR(100) NOT NULL,
    serial_number VARCHAR(100) UNIQUE,
    photo_url VARCHAR(255),
    equipment_type VARCHAR(100),
    purchase_date DATE,
    expiry_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES Station(id)
);


CREATE TABLE Inspection (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gear_id INT,
    inspection_date DATE,
    inspector_id INT,
    inspection_type VARCHAR(100),
    condition_notes TEXT,
    result VARCHAR(50),
    FOREIGN KEY (gear_id) REFERENCES Gear(id),
    FOREIGN KEY (inspector_id) REFERENCES Firefighter(id)
);


CREATE TABLE MaintenanceSchedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gear_id INT,
    scheduled_date DATE,
    scheduled_time TIME NOT NULL DEFAULT '00:00:00',
    FOREIGN KEY (gear_id) REFERENCES Gear(id)
);


CREATE TABLE MaintenanceReminder (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gear_id INT,
    schedule_id INT,
    reminder_date DATE,
    reminder_time TIME NOT NULL DEFAULT '00:00:00',
    message VARCHAR(255),
    sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (gear_id) REFERENCES Gear(id),
    FOREIGN KEY (schedule_id) REFERENCES MaintenanceSchedule(id)
);


CREATE TABLE DamageReport (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gear_id INT,
    reporter_id INT,
    report_date DATE,
    notes TEXT,
    photo_url VARCHAR(255),
    status VARCHAR(50),
    FOREIGN KEY (gear_id) REFERENCES Gear(id),
    FOREIGN KEY (reporter_id) REFERENCES Firefighter(id)
);

-- ===================================================================
-- Sample Data

-- Department
INSERT INTO Department (department_name, location)
VALUES 
('Sam Phran Fire Department', 'Bang Chang, Sam Phran District, Nakhon Pathom'),
('Nakhon Pathom Fire Department', 'Salaya District, Nakhon Pathom Province'),
('Bangkok Metropolitan Fire Department', 'Din Daeng District, Bangkok'),
('Nonthaburi Provincial Fire Department', 'Mueang Nonthaburi District, Nonthaburi Province'),
('Chonburi Fire & Rescue Department', 'Bang Lamung District, Chon Buri Province'),
('Phuket Fire & Rescue Department', 'Patong, Kathu District, Phuket Province'),
('Ayutthaya Fire Department', 'Phra Nakhon Si Ayutthaya City, Ayutthaya Province'),
('Chiang Mai Fire Department', 'Bumrung Buri Road, Mueang Chiang Mai District, Chiang Mai Province');

-- Station
INSERT INTO Station (name, location, department_id)
VALUES
('Rai Khing Station', 'Rai Khing, Sam Phran District, Nakhon Pathom 73210', 1),
('Taling Chan Fire Station', 'Salaya, Phutthamonthon District, Nakhon Pathom 73170', 2),
('Huai Khwang Station', '2000 Prachasongkhro Rd, Din Daeng, Bangkok 10400', 3),
('Sanambinnam Station', 'Tambon Tha Sai, Mueang Nonthaburi District, Nonthaburi 11000', 4),
('Bang Lamung Station', '261 Chaloem-Phrakiat Rd, Bang Lamung District, Chon Buri 20150', 5),
('Patong Station', '12 Ratprachanusorn Rd, Patong, Kathu District, Phuket Province 83130', 6),
('Bang Sai Fire Station', 'Bang Sai District, Phra Nakhon Si Ayutthaya Province, Thailand', 7),
('Chiang Mai City Station', 'Bumrung Buri Rd, Mueang Chiang Mai District, Chiang Mai Province', 8);

-- Firefighter
INSERT INTO Firefighter (name, ranks, email, phone, station_id, department_id)
VALUES
('Mark Johnson', 'Firefighter', 'Mark.johnson@gmail.com', '0800000000', 1, 1),
('Ton Danai', 'Technician', 'Ton.danai@gmail.com', '0899999999', 1, 1),
('Minnie Aleenta', 'Firefighter', 'Minnie.aleenta@gmail.com', '0888888888', 2, 2),
('Sang Nuntaphop', 'Firefighter', 'Sang.nuntaphop@gmail.com', '0888888888', 2, 2),
('P Pongpon', 'Firefighter', 'P.pongpon@gmail.com', '0888888888', 2, 2),
('Pon Phonlaphat', 'Firefighter', 'Pon.phonlaphat@gmail.com', '0888888888', 2, 2);
-- Gear
INSERT INTO Gear (station_id, gear_name, serial_number, photo_url, equipment_type, purchase_date, expiry_date, status)
VALUES
(1, 'Fire Helmet', 'FH-001', 'uploads/pic1.jpg', 'Helmet', '2023-01-10', '2028-01-10', 'OK'),
(1, 'Oxygen Tank', 'OT-002', 'uploads/pic1.jpg', 'Tank', '2022-11-15', '2027-11-15', 'Due Soon'),
(2, 'Fire Hose', 'FH-003', 'uploads/pic1.jpg', 'Hose', '2023-06-01', '2026-06-01', 'Needs Service'),
(2, 'Protective Gloves', 'PG-004', 'uploads/pic1.jpg', 'Gloves', '2024-02-20', '2027-02-20', 'OK'),
(3, 'Fire Extinguisher', 'FE-005', 'uploads/pic1.jpg', 'Extinguisher', '2023-03-01', '2028-03-01', 'OK'),
(3, 'Fire Extinguisher Ball', 'FEB-006', 'uploads/pic1.jpg', 'Extinguisher Ball', '2024-01-12', '2029-01-12', 'OK'),
(4, 'Hose Jet Nozzle', 'HJ-007', 'uploads/pic1.jpg', 'Hose Jet', '2023-05-08', '2027-05-08', 'OK'),
(4, 'Fire Bucket', 'FB-008', 'uploads/pic1.jpg', 'Bucket', '2022-09-25', '2026-09-25', 'OK'),
(5, 'Flamezorb Powder', 'FZ-009', 'uploads/pic1.jpg', 'Absorbent Agent', '2024-04-02', '2027-04-02', 'OK'),
(5, 'Fire Blanket', 'FBK-010', 'uploads/pic1.jpg', 'Blanket', '2023-08-10', '2028-08-10', 'OK'),
(6, 'Fire Suit', 'FS-011', 'uploads/pic1.jpg', 'Protective Suit', '2022-11-01', '2027-11-01', 'Due Soon'),
(6, 'Gas Tight Suit', 'GTS-012', 'uploads/pic1.jpg', 'Protective Suit', '2023-12-10', '2028-12-10', 'OK'),
(7, 'Breathing Apparatus', 'BA-013', 'uploads/pic1.jpg', 'Respirator', '2023-02-14', '2026-02-14', 'Needs Service'),
(7, 'Thermal Imaging Camera', 'TIC-014', 'uploads/pic1.jpg', 'Camera', '2024-01-20', '2029-01-20', 'OK'),
(8, 'Positive Pressure Ventilation Fan', 'PPV-015', 'uploads/pic1.jpg', 'Ventilation', '2023-06-25', '2028-06-25', 'OK'),
(8, 'Rescue Ladder', 'RL-016', 'uploads/pic1.jpg', 'Ladder', '2022-07-05', '2032-07-05', 'OK'),
(1, 'Firefighting Drone', 'DR-017', 'uploads/pic1.jpg', 'Drone', '2024-02-01', '2029-02-01', 'OK'),
(2, 'Firefighting Vehicle', 'FFV-018', 'uploads/pic1.jpg', 'Vehicle', '2020-09-01', '2035-09-01', 'OK');

-- Inspection
INSERT INTO Inspection (gear_id, inspection_date, inspector_id, inspection_type, condition_notes, result)
VALUES
(1, '2025-10-10', 2, 'Routine', 'Helmet clean and secure', 'Passed'),
(2, '2025-10-12', 2, 'Repair', 'Oxygen valve leaking', 'Needs Repair'),
(3, '2025-10-14', 1, 'Post-Service', 'Hose replaced and tested', 'Passed'),
(4, '2025-10-09', 2, 'Routine', 'Gloves slightly worn', 'Passed');

-- MaintenanceSchedule
INSERT INTO MaintenanceSchedule (gear_id, scheduled_date)
VALUES
(1, '2025-11-01'),
(2, '2025-10-20'),
(3, '2025-10-25'),
(4, '2025-11-15');

-- MaintenanceReminder
INSERT INTO MaintenanceReminder (gear_id, reminder_date, reminder_time, message, sent)
VALUES
(1, '2025-10-31', '08:00:00', 'Monthly check for Fire Helmet', FALSE),
(2, '2025-10-18', '09:00:00', 'Upcoming maintenance for Oxygen Tank', TRUE),
(3, '2025-10-24', '08:30:00', 'Hose needs inspection this week', FALSE);

-- DamageReport
INSERT INTO DamageReport (gear_id, reporter_id, report_date, notes, photo_url, status)
VALUES
(3, 1, '2025-10-15', 'Hose nozzle cracked during use', 'uploads/hose_damage_15oct.jpg', 'Pending'),
(2, 2, '2025-09-30', 'Tank strap worn out', 'uploads/tank_strap_issue.jpg', 'Resolved'),
(4, 3, '2025-10-13', 'Burn mark on gloves', 'uploads/gloves_burned.jpg', 'Under Review');
