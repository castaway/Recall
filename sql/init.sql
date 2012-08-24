/* SQLEditor (MySQL (2))*/

SHOW ENGINE INNODB STATUS;
SHOW INNODB STATUS;

SET foreign_key_checks = 0;


DROP TABLE IF EXISTS Document_Tags;

DROP TABLE IF EXISTS Tags;

DROP TABLE IF EXISTS Documents;

DROP TABLE IF EXISTS Versions;

SET foreign_key_checks = 1;



CREATE TABLE Versions
(
slug VARCHAR(255) NOT NULL,
edited DATETIME NOT NULL,
title VARCHAR(255),
source TEXT,
html TEXT,
PRIMARY KEY (slug,edited)
) ENGINE=InnoDB;

CREATE TABLE Documents
(
slug VARCHAR(255) UNIQUE,
published DATETIME,
edited DATETIME,
PRIMARY KEY (slug)
) ENGINE=InnoDB;

CREATE TABLE Tags
(
tag VARCHAR(255) UNIQUE,
about VARCHAR(255),
PRIMARY KEY (tag)
) ENGINE=InnoDB;

CREATE TABLE Document_Tags
(
tag VARCHAR(255) UNIQUE,
document VARCHAR(255),
PRIMARY KEY (tag)
) ENGINE=InnoDB;

CREATE INDEX slug_idx ON Versions(slug);
ALTER TABLE Versions ADD FOREIGN KEY slug_idxfk (slug) REFERENCES Documents (slug);

CREATE INDEX edited_idx ON Versions(edited);
CREATE INDEX slug_idx ON Documents(slug);
CREATE INDEX published_idx ON Documents(published);
ALTER TABLE Documents ADD FOREIGN KEY published_idxfk (published,slug) REFERENCES Versions (edited,slug);

CREATE INDEX edited_idx ON Documents(edited);
CREATE INDEX tag_idx ON Tags(tag);
ALTER TABLE Tags ADD FOREIGN KEY about_idxfk (about) REFERENCES Documents (slug);

CREATE INDEX tag_idx ON Document_Tags(tag);
ALTER TABLE Document_Tags ADD FOREIGN KEY tag_idxfk (tag) REFERENCES Tags (tag);

ALTER TABLE Document_Tags ADD FOREIGN KEY document_idxfk (document) REFERENCES Documents (slug);
