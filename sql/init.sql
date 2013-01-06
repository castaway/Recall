/* 
SHOW ENGINE INNODB STATUS;
SHOW INNODB STATUS;
*/

SET foreign_key_checks = 0;

DROP TABLE IF EXISTS Tags;
DROP TABLE IF EXISTS Documents;
DROP TABLE IF EXISTS Versions;
DROP TABLE IF EXISTS Permanent;
DROP TABLE IF EXISTS Documents_To_Tags;

SET foreign_key_checks = 1;

CREATE TABLE Documents
(
document_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
first_published_id INTEGER UNSIGNED,
live_id INTEGER UNSIGNED,
slug VARCHAR(255) NOT NULL,
PRIMARY KEY (document_id)
) ENGINE=InnoDB;

CREATE INDEX live_id_idx ON Documents(live_id);
CREATE INDEX slug_idx ON Documents(slug);

CREATE TABLE Versions
(
version_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
document_id INTEGER UNSIGNED NOT NULL,
edited DATETIME NOT NULL,
title VARCHAR(255),
source TEXT,
html TEXT,
PRIMARY KEY (version_id)
) ENGINE=InnoDB;

CREATE INDEX edited_idx ON Versions(edited);
/* Maybe create other indexes later, but I'm not going to worry about doing full text searches just now */

CREATE TABLE Permanent 
(
document_id INTEGER UNSIGNED NOT NULL,
url VARCHAR(255) NOT NULL,
PRIMARY KEY (document_id)
) ENGINE=InnoDB;

CREATE INDEX url_idx ON Permanent(url);

ALTER TABLE Versions ADD FOREIGN KEY document_id_idxfk (document_id) REFERENCES Documents (document_id);
ALTER TABLE Documents ADD FOREIGN KEY first_published_version_idxfk (first_published_id) REFERENCES Versions (version_id);
ALTER TABLE Documents ADD FOREIGN KEY live_version_idxfk (live_id) REFERENCES Versions (version_id);
ALTER TABLE Permanent ADD FOREIGN KEY document_id_idxfk (document_id) REFERENCES Documents (document_id);

CREATE TABLE Tags
(
name VARCHAR(255),
about_document_id INTEGER UNSIGNED UNIQUE,
PRIMARY KEY (name)
) ENGINE=InnoDB;

CREATE INDEX tag_id_idx ON Tags(name);
ALTER TABLE Tags ADD FOREIGN KEY about_document_idxfk (about_document_id) REFERENCES Documents (document_id);

CREATE TABLE Documents_To_Tags
(
tag_id VARCHAR(255),
document_id INTEGER UNSIGNED NOT NULL,
PRIMARY KEY (tag_id, document_id)
) ENGINE=InnoDB;

ALTER TABLE Documents_To_Tags ADD FOREIGN KEY tag_idxfk (tag_id) REFERENCES Tags (name);
ALTER TABLE Documents_To_Tags ADD FOREIGN KEY document_idxfk (document_id) REFERENCES Documents (document_id);


