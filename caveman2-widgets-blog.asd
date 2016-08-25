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
(defpackage caveman2-widgets-blog-asd
  (:use :cl :asdf))
(in-package :caveman2-widgets-blog-asd)

(defsystem caveman2-widgets-blog
  :version "0.1"
  :author "Richard Paul Bäck"
  :license "GPLv3"
  :depends-on (:clack
               :lack
               :caveman2
               :caveman2-widgets
               :envy
               :cl-ppcre
               :uiop

               ;; for @route annotation
               :cl-syntax-annot

               ;; HTML Template
               :djula

               ;; for DB
               :datafly
               :sxql)
  :components ((:module "src"
                        :components
                        ((:file "main" :depends-on ("config" "view" "db"))
                         (:file "web" :depends-on ("view"))
                         (:file "view" :depends-on ("config"))
                         (:file "db" :depends-on ("config"))
                         (:file "config"))))
  :description ""
  :in-order-to ((test-op (load-op caveman2-widgets-blog-test))))
