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
(defpackage caveman2-widgets-blog.config
  (:use :cl)
  (:import-from :envy
                :config-env-var
                :defconfig)
  (:export :config
           :*application-root*
           :*static-directory*
           :*template-directory*
           :*blog-directory*
           :*month-list*
           :*blog-entries-path*
           :appenv
           :developmentp
           :productionp))
(in-package :caveman2-widgets-blog.config)

(setf (config-env-var) "APP_ENV")

(defparameter *application-root*
  (asdf:system-source-directory :caveman2-widgets-blog))
(defparameter *static-directory* (merge-pathnames #P"static/"
                                                  *application-root*))
(defparameter *template-directory* (merge-pathnames #P"templates/"
                                                    *application-root*))
(defparameter *sqlite-db* (merge-pathnames #p"blog.db"
                                           *application-root*))
(defparameter *blog-directory* (merge-pathnames #P"blog/"
                                                *application-root*))

(defparameter *month-list*
  '((1 "January") (2 "February") (3 "March") (4 "April")
    (5 "May") (6 "June") (7 "July") (8 "August")
    (9 "September") (10 "October") (11 "November")
    (12 "December")))

(defparameter *blog-entries-path* "/"
  "Must include a starting and trailing slash.")

(defconfig :common
    (list ))

(defconfig |development|
    (list :debug t
          :database-debug nil
          :database-connection-spec
          (list
           :database-type :sqlite3
           :database-name *sqlite-db*)))

(defconfig |production|
    (list :debug nil
          :database-debug nil
          :database-connection-spec
          (list
           :database-type :mysql
           :database-name "blog"
           :username "blog"
           :password "blog")))

(defconfig |test|
    (list ))

(defun config (&optional key)
  (envy:config #.(package-name *package*) key))

(defun appenv ()
  (uiop:getenv (config-env-var #.(package-name *package*))))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (string= (appenv) "production"))
