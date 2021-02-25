#!/bin/bash
: '
 * @author [Femi Awe]
 * @email [fawe@cisco.com] 
 * @desc [SE Hackathon - DNAC data into GrafanA]
'

mysql -uroot -p$dbPasswd << EOF
use mysql;
CREATE DATABASE IF NOT EXISTS DNA;
USE DNA;
CREATE TABLE IF NOT EXISTS devices_list (
  lastUpdated varchar(30) DEFAULT NULL,
  upTime varchar(30) DEFAULT NULL,
  collectionStatus varchar(30) DEFAULT NULL,
  hostname varchar(30) DEFAULT NULL,
  macAddress varchar(30) DEFAULT NULL,
  managementIpAddress varchar(30) DEFAULT NULL,
  role varchar(30) DEFAULT NULL,
  platformId varchar(30) DEFAULT NULL,
  softwareVersion varchar(20) DEFAULT NULL,
  datetime datetime DEFAULT CURRENT_TIMESTAMP,
  id INT NOT NULL AUTO_INCREMENT,
  primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS site_health (
    clientHealthWired INT DEFAULT NULL,
    networkHealthAccess INT DEFAULT NULL,
    networkHealthCore INT DEFAULT NULL,
    networkHealthDistribution INT DEFAULT NULL,
    networkHealthRouter INT DEFAULT NULL,
    siteName VARCHAR(255),
    siteType VARCHAR(255),
    clientHealthWireless INT DEFAULT NULL,
    networkHealthOthers INT DEFAULT NULL,
    networkHealthWireless INT DEFAULT NULL,
    datetime datetime DEFAULT CURRENT_TIMESTAMP,
    id INT NOT NULL AUTO_INCREMENT,
  primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS network_health (
  category VARCHAR(20) DEFAULT NULL,
  goodPercentage INT DEFAULT NULL,
  healthScore INT DEFAULT NULL,
  datetime datetime DEFAULT CURRENT_TIMESTAMP,
  id INT NOT NULL AUTO_INCREMENT,
  primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS client_health (
  category VARCHAR(20) DEFAULT NULL,
  scoreDetail INT DEFAULT NULL,
  datetime datetime DEFAULT CURRENT_TIMESTAMP,
  id INT NOT NULL AUTO_INCREMENT,
  primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
EOF
