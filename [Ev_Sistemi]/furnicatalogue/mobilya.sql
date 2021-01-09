CREATE TABLE `savedobjects` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `home` varchar(45) DEFAULT NULL,
  `pos` longtext,
  `rot` longtext,
  `model` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=248 DEFAULT CHARSET=utf8;
