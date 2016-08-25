--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------

create table blogpost(
        id integer primary key,
        date char(21), -- e.g. 2015-05-14 - 21:14:40
        title varchar(50) not null,
        text varchar(50000),
        blog_categoryid int(11) not null
        );
