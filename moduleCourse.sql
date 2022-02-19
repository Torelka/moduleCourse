
CREATE TABLE `course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom_course` varchar(25) NOT NULL,
  `waypoint` json NOT NULL,
  `id_createur` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

CREATE TABLE `participant_course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_player` varchar(100) NOT NULL,
  `id_course` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

CREATE TABLE `resultat_course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_player` varchar(100) NOT NULL,
  `id_course` int(11) NOT NULL,
  `place` int(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;