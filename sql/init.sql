/* 
SHOW ENGINE INNODB STATUS;
SHOW INNODB STATUS;
*/

SET foreign_key_checks = 0;

DROP TABLE IF EXISTS Document_Tags;
DROP TABLE IF EXISTS Tags;
DROP TABLE IF EXISTS Documents;
DROP TABLE IF EXISTS Versions;
DROP TABLE IF EXISTS Permanent;

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

/*

22:27 < Dorward> I'm trying to deal with a couple of tables which have multiple 
                 relationships between them. The wrong key is being used when I 
                 try to set a value for one of those relationships. How can I 
                 make it use the right key? http://paste.scsys.co.uk/206360
22:30 < ilmari> Dorward: you have a relationship with the same name as the 
                column, so that'll overwrite the accessor
22:30 < ilmari> rename the relationship to first_published_version
22:31 < Dorward> ilmari: Is there a sane way to do that so it won't get 
                 overwritten again if I edit the SQL, rebuild the DB and 
                 automatically rebuild the schema files?
22:32 < ilmari> Dorward: change the name of the foreign key constraint
22:32 < purl> ilmari: that doesn't look right
22:32 < Dorward> ilmari: Ahh. I'll give that a try. Thanks v. much.

22:44 < Dorward> ilmari: I've been trying to change the name of the 
                 relationship, but haven't had any luck. Is this going to be 
                 one of those "Use pgsql instead of MySQL" things?
22:44 -!- cafe [~cafe@189.115.217.144] has quit []
22:45 <@frew> Dorward: how did you try to rename it?
22:45 <@frew> Dorward: some db's make you destroy and recreate it to rename it
22:45 < ilmari> Dorward: hang on. Schema::Loader doesn't look at the constraint 
                name at all. you need to add _id to the column name or provide 
                a col_accessor_map or rel_name_map
22:45 < Dorward> frew: Dropped all the tables, then rebuild it having changed 
                 the line to ALTER TABLE Documents ADD FOREIGN KEY 
                 first_published_version_idxfk (first_published) REFERENCES 
                 Versions (edited);
22:45 < ilmari> preferrably the latter, since having column names and accessors 
                not match up gets confusing
22:45 <@frew> Dorward: what ilmari said :)
22:46 -!- dpetrov_ [b21b747f@ircip2.mibbit.com] has joined #dbix-class
22:46 < Dorward> ilmari: Ahhh. I shall now go and try to find out what a 
                 rel_name_map is by RTFMing :)
22:46 <@frew> Dorward: _id is a better soln
22:46 <@frew> Dorward: but probably more of a big deal
22:47 < ilmari> especially since the column isn't an id, but a timestamp
22:47 < Dorward> Really early stages on this project. Major changes to the DB 
                 are not a big deal. :)
22:47 < ilmari> you'd better not have multiple edits in the same second!
22:47 <@frew> ouch
22:47 <@frew> lol
22:47 <@frew> so MSSQL allows you to have microsecond accuracy
22:47 <@frew> but
22:47 < ilmari> postgres too
22:47 <@frew> UC's think something within the same 99ms is the same
22:48 < ilmari> eeh?
22:48 <@frew> I know
22:48 <@frew> it's so silly
22:48  * ilmari falls over
22:48 < Dorward> hmm, good point. It would require multiple edits of the same 
                 document in the same second ... but that is possible. Time to 
                 go and add a version id field