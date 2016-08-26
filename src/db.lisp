;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (C) 2016 Richard Bäck <richard.baeck@free-your-pc.com>
;;
;; This file is part of caveman2-widgets-blog.
;;
;; caveman2-widgets-blog is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by the Free
;; Software Foundation, either version 3 of the License, or (at your option) any
;; later version.
;;
;; caveman2-widgets-blog is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.
;;
;; You should have received a copy of the GNU General Public License along with
;; caveman2-widgets-blog.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :cl-user)
(defpackage caveman2-widgets-blog.db
  (:use :cl
        :crane
        :caveman2-widgets-blog.config)
  (:export :blogpost
           :id
           :date
           :title
           :text))
(in-package :caveman2-widgets-blog.db)

(setup
 :migrations-directory (merge-pathnames
                        *application-root*
                        #p"migrations")
 :databases
 (list :main
       (append
        (list
         :type (getf (config :database-connection-spec)
                     :database-type)
         :name (getf (config :database-connection-spec)
                     :database-name))
        (if (getf (config :database-connection-spec)
                  :username)
            (list
             :user (getf (config :database-connection-spec)
                         :username)

             :pass (getf (config :database-connection-spec)
                         :password))
            nil)))
 :debug (config :database-debug))

(connect)

(definflate (str 'string)
    ;; when the database attribute is NIL the string "NULL" is returned
    (if (string= str "NULL")
        nil
        str))
(defdeflate (string string) string)

;; Needed to retrieve rounded doubles
(definflate (dbl 'double) (read-from-string (format nil "~,4f" dbl)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ORM classes:
(crane:deftable blogpost ()
  (date :type string :nullp nil)
  (title :type string :nullp nil)
  (text :type string :nullp t))
