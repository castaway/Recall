/* SQLEditor (MySQL (2))*/

DROP TABLE IF EXISTS Versions;

DROP TABLE IF EXISTS Documents;

CREATE TABLE Documents
(
slug VARCHAR(255) UNIQUE,
published DATETIME,
PRIMARY KEY (slug)
) ENGINE=InnoDB;

CREATE TABLE Versions
(
slug VARCHAR(255) NOT NULL,
edited DATETIME NOT NULL,
title VARCHAR(255),
source TEXT,
PRIMARY KEY (slug,edited)
) ENGINE=InnoDB;

CREATE INDEX slug_idx ON Documents(slug);
CREATE INDEX published_idx ON Documents(published);
ALTER TABLE Documents ADD FOREIGN KEY published_idxfk (published,slug) REFERENCES Versions (edited,slug) ON DELETE SET NULL;

CREATE INDEX slug_idx ON Versions(slug);
ALTER TABLE Versions ADD FOREIGN KEY slug_idxfk (slug) REFERENCES Documents (slug) ON DELETE CASCADE;

CREATE INDEX edited_idx ON Versions(edited);