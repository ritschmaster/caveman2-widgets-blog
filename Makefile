########################################################################
# Copyright (C) 2016 Richard Bäck <richard.baeck@free-your-pc.com>
#
# This file is part of freeyourpc-website.
#
# freeyourpc-website is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# freeyourpc-website is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with freeyourpc-website.  If not, see
# <http://www.gnu.org/licenses/>.
########################################################################

SQLITE_CMD = sqlite3

DB_FILE = blog.db

SQL_FILE = db/create-sqlite.sql

all:
  ifeq ($(wildcard $(DB_DEV_FILE)),)
	"$(SQLITE_CMD)" "$(DB_FILE)" < "$(SQL_FILE)"
  endif

clean:
	rm $(DB_FILE)
