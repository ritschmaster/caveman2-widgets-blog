-- -----------------------------------------------------------------------------
-- Copyright (C) 2016 Richard Bäck <richard.baeck@free-your-pc.com>
--
-- This file is part of caveman2-widgets-blog.
--
-- caveman2-widgets-blog is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option) any
-- later version.
--
-- caveman2-widgets-blog is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-- more details.
--
-- You should have received a copy of the GNU General Public License along with
-- caveman2-widgets-blog.  If not, see <http://www.gnu.org/licenses/>.
-- -----------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS `blog` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;

CREATE USER 'blog'@'localhost' IDENTIFIED BY 'blog';

    GRANT USAGE ON *.* TO 'blog'@'localhost'
    IDENTIFIED BY 'blog' WITH MAX_QUERIES_PER_HOUR 0
    MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS
    0;

    GRANT ALL PRIVILEGES ON `blog`.* TO
    'blog'@'localhost'WITH GRANT OPTION;

    USE `blog`;
-- -----------------------------------------------------------------------------

--
-- Table structure for table `blogpost`
--
CREATE TABLE blogpost (
        id int(11) NOT NULL auto_increment,
        date char(21) DEFAULT NULL,
        title varchar(50) NOT NULL,
        text_filename varchar(400) DEFAULT NULL,

        PRIMARY KEY (id)
        );
