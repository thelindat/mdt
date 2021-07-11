-- check if the table exists to prevent stopping the query from continuing if it does
CREATE  TABLE IF NOT EXISTS `user_mdt` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`notes` varchar(255) DEFAULT NULL,
	`mugshot_url` varchar(255) DEFAULT NULL,
	`bail` bit DEFAULT NULL,

	PRIMARY KEY (`id`)
);

-- check if the table exists to prevent stopping the query from continuing if it does
CREATE TABLE IF NOT EXISTS `vehicle_mdt` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`plate` varchar(255) DEFAULT NULL,
	`stolen` bit DEFAULT 0,
	`notes` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

-- check if the table exists to prevent stopping the query from continuing if it does
CREATE TABLE IF NOT EXISTS `user_convictions` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`offense` varchar(255) DEFAULT NULL,
	`count` int(11) DEFAULT NULL,
	
	PRIMARY KEY (`id`)
);

-- check if the table exists to prevent stopping the query from continuing if it does
CREATE TABLE IF NOT EXISTS `mdt_reports` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`title` varchar(255) DEFAULT NULL,
	`incident` longtext DEFAULT NULL,
    `charges` longtext DEFAULT NULL,
    `author` varchar(255) DEFAULT NULL,
	`name` varchar(255) DEFAULT NULL,
    `date` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

-- check if the table exists to prevent stopping the query from continuing if it does
CREATE TABLE IF NOT EXISTS `mdt_warrants` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) DEFAULT NULL,
	`char_id` int(11) DEFAULT NULL,
	`report_id` int(11) DEFAULT NULL,
	`report_title` varchar(255) DEFAULT NULL,
	`charges` longtext DEFAULT NULL,
	`date` varchar(255) DEFAULT NULL,
	`expire` varchar(255) DEFAULT NULL,
	`notes` varchar(255) DEFAULT NULL,
	`author` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

-- check if the table exists to prevent stopping the query from continuing if it does
CREATE TABLE IF NOT EXISTS `fine_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `jailtime` int(11) DEFAULT NULL,
	
       PRIMARY KEY (`id`)
);

-- If you dont truncate youre going to end up with errors or duplicate fine labels
-- TODO: implement unique uuids for fines so that truncate is no longer needed
TRUNCATE TABLE `fine_types`;

-- id values are removed
-- id is an autoincrement field, there is no need to predefine them. especially if theyre in order anyway
INSERT INTO `fine_types` (`label`, `amount`, `category`, `jailtime`) VALUES
('Murder', 25000, 0, 0),
('Involuntary Manslaughter', 10000, 0, 120),
('Vehicular Manslaughter', 7500, 0, 100),
('Attempted Murder on LEO', 1500, 0, 60),
('Attempted Murder', 1000, 0, 50),
('Assault w/ Deadly Weapon on LEO', 700, 0, 45),
('Assault w/ Deadly Weapon', 350, 0, 30),
('Assault on LEO', 150, 0, 15),
('Assault', 100, 0, 10),
('Kidnapping of an LEO', 400, 0, 40),
('Kidnapping / Hostage Taking', 200, 0, 20),
('Bank Robbery', 800, 0, 50),
('Armored Truck Robbery', 650, 0, 40),
('Jewelery Store Robbery ', 500, 0, 30),
('Store Robbery', 150, 0, 15),
('House Robbery', 100, 0, 10),
('Corruption', 10000, 0, 650),
('Felony Driving Under the Influence', 300, 0, 30),
('Grand Theft Auto', 300, 0, 20),
('Evading Arrest', 200, 0, 20),
('Driving Under the Influence', 150, 0, 15),
('Hit and Run', 150, 0, 15),
('Operating a Motor Vehicle without a License', 100, 0, 10),
('Criminal Speeding', 300, 0, 10),
('Excessive Speeding 4', 250, 0, 0),
('Excessive Speeding 3', 200, 0, 0),
('Excessive Speeding 2', 150, 0, 0),
('Excessive Speeding', 100, 0, 0),
('Operating an Unregisted Motor Vehicle', 100, 0, 5),
('Reckless Endangerment', 150, 0, 5),
('Careless Driving', 100, 0, 0),
('Operating a Non-Street Legal Vehicle', 200, 0, 5),
('Failure to Stop', 100, 0, 0),
('Obstructing Traffic', 150, 0, 0),
('Illegal Lane Change', 100, 0, 0),
('Failure to Yield to an Emergency Vehicle', 150, 0, 0),
('Illegal Parking', 100, 0, 0),
('Excessive Vehicle Noise', 100, 0, 0),
('Driving without Proper Use of Headlights', 100, 0, 0),
('Illegal U-Turn', 100, 0, 0),
('Drug Manufacturing/Cultivation', 550, 0, 40),
('Possession of Schedule 1 Drug', 150, 0, 15),
('Possession of Schedule 2 Drug', 250, 0, 20),
('Sale/Distribution of Schedule 1 Drug', 250, 0, 20),
('Sale/Distribution of Schedule 2 Drug', 400, 0, 30),
('Drug Trafficking', 500, 0, 40),
('Weapons Caching of Class 2s', 2500, 0, 120),
('Weapons Caching of Class 1s', 1250, 0, 60),
('Weapons Trafficking of Class 2s', 1700, 0, 80),
('Weapons Trafficking of Class 1s', 800, 0, 45),
('Possession of a Class 2 Firearm', 800, 0, 40),
('Possession of a Class 1 Firearm', 150, 0, 15),
('Brandishing a Firearm', 100, 0, 5),
('Unlawful discharge of a firearm', 150, 0, 10),
('Perjury', 1000, 0, 60),
('Arson', 500, 0, 30),
('False Impersonation of a Government Official', 200, 0, 25),
('Possession of Dirty Money', 200, 0, 25),
('Possession of Stolen Goods', 100, 0, 15),
('Unlawful Solicitation', 150, 0, 20),
('Larceny', 150, 0, 20),
('Felony Attempted Commision of an Offence/Crime', 350, 0, 20),
('Tampering With Evidence', 200, 0, 20),
('Illegal Gambling', 200, 0, 20),
('Bribery', 200, 0, 20),
('Stalking', 350, 0, 20),
('Organizing an illegal event', 150, 0, 15),
('Participating in an illegal event', 50, 0, 5),
('Criminal Mischief', 100, 0, 15),
('Prostitution', 250, 0, 15),
('Failure to Identify', 150, 0, 15),
('Obstruction of Justice', 150, 0, 15),
('Resisting Arrest', 100, 0, 10),
('Disturbing the Peace', 100, 0, 10),
('Threat to do Bodily Harm', 100, 0, 10),
('Terroristic Threat', 150, 0, 10),
('Damage to Government Property', 150, 0, 10),
('Contempt of Court', 250, 0, 10),
('Failure to Obey a Lawful Order', 150, 0, 10),
('False Report', 100, 0, 10),
('Trespassing', 100, 0, 10),
('Loitering', 100, 0, 0),
('Public Intoxication', 100, 0, 0),
('Indecent Exposure', 100, 0, 0),
('Verbal Harassment ', 100, 0, 0),
('Aiding and Abetting', 100, 0, 0),
('Incident Report', 0, 0, 0),
('Written Citation', 0, 0, 0),
('Verbal Warning', 0, 0, 0);
